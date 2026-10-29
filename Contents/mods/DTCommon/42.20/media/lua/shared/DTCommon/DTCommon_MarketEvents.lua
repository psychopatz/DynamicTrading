-- Generic, versioned settlement market event registry. Events are compact
-- typed data; this module resolves active scope and time, but never rewrites
-- trader stock or contains event-ID-specific economic branches.

DTCommon = DTCommon or {}

local Registry = DTCommon.MarketEvents or {}
DTCommon.MarketEvents = Registry

local Schema = DTCommon.MarketSchema
local Storage = DTCommon.Storage
local MAX_EVENTS = Schema and Schema.MAX_EVENTS or 128
local MAX_MODIFIERS = Schema and Schema.MAX_MODIFIERS or 16
local MAX_ID_LENGTH = Schema and Schema.MAX_ID_LENGTH or 192
local MAX_TIMESTAMP = Schema and Schema.MAX_TIMESTAMP or 2147483647
local MAX_REVISION = Schema and Schema.MAX_REVISION or 2147483647

Registry.VERSION = 1
Registry.MAX_EVENTS = MAX_EVENTS
Registry.MAX_MODIFIERS = MAX_MODIFIERS

local function authority()
    return Storage and type(Storage.IsAuthority) == "function"
        and Storage.IsAuthority() == true
end

local function number(value, fallback)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge
        or value == -math.huge
    then return fallback end
    return value
end

local function integer(value, fallback)
    return math.floor(number(value, fallback))
end

local function clamp(value, low, high, fallback)
    value = number(value, fallback)
    return math.max(low, math.min(high, value))
end

local function boundedID(value)
    value = tostring(value or "")
    if #value > MAX_ID_LENGTH then
        return string.sub(value, 1, MAX_ID_LENGTH)
    end
    return value
end

local function eventData()
    if not Storage or type(Storage.GetEventData) ~= "function" then
        return nil, "event_storage_unavailable"
    end
    return Storage.GetEventData()
end

local function sortedKeys(value)
    local keys = {}
    for key, _ in pairs(value or {}) do
        if type(key) == "string" and key ~= "" then
            keys[#keys + 1] = key
        end
    end
    table.sort(keys)
    return keys
end

local function copyEvent(eventID, value)
    local normalized
    local reason
    if not Schema or type(Schema.NewEvent) ~= "function" then
        return nil, "event_schema_unavailable"
    end
    normalized, reason = Schema.NewEvent(eventID, value)
    if not normalized then return nil, reason end
    normalized.eventID = eventID
    return normalized
end

local function gameTime()
    local getter = rawget(_G, "getGameTime")
    local time
    if type(getter) ~= "function" then return 0 end
    local ok
    ok, time = pcall(getter)
    if not ok or not time or type(time.getWorldAgeHours) ~= "function" then
        return 0
    end
    ok, time = pcall(time.getWorldAgeHours, time)
    return ok and clamp(time, 0, MAX_TIMESTAMP, 0) or 0
end

local function resolveNow(options)
    options = type(options) == "table" and options or {}
    if options.now ~= nil then
        return clamp(options.now, 0, MAX_TIMESTAMP, 0)
    end
    return gameTime()
end

local function communityRegion(settlementID)
    local pnc = rawget(_G, "PNC")
    local communities = pnc and pnc.Communities or nil
    local community
    if not settlementID or not communities
        or type(communities.Get) ~= "function"
    then
        return nil
    end
    local ok
    ok, community = pcall(communities.Get, settlementID)
    if not ok or type(community) ~= "table" then return nil end
    return community.regionID or community.regionId or community.region
end

local function contextIDs(settlementID, record, options)
    options = type(options) == "table" and options or {}
    record = type(record) == "table" and record or {}
    local factionID = options.factionID or options.factionId
        or record.factionID or record.factionId or record.g
    local regionID = options.regionID or options.regionId
        or record.regionID or record.regionId or record.region
    regionID = regionID or communityRegion(settlementID)
    return boundedID(settlementID), boundedID(regionID), boundedID(factionID)
end

local function isActive(event, now)
    if type(event) ~= "table" then return false end
    if now < number(event.startsAt, 0) then return false end
    return event.endsAt == nil or now < number(event.endsAt, now)
end

local function scopeMatches(event, settlementID, regionID, factionID)
    local scope = event and event.scope or {}
    local kind = scope.kind
    local id = tostring(scope.id or "")
    if kind == "global" then return true end
    if kind == "settlement" then return settlementID ~= ""
        and id == settlementID end
    if kind == "region" then return regionID ~= "" and id == regionID end
    if kind == "faction" then return factionID ~= "" and id == factionID end
    return false
end

local function addModifier(target, source, eventID)
    local marketTag = tostring(source.marketTag or "")
    local entry
    if marketTag == "" then return end
    entry = target[marketTag]
    if not entry then
        entry = {
            marketTag = marketTag,
            supplyDelta = 0,
            demandDelta = 0,
            availabilityMultiplier = 1,
            priceMultiplier = 1,
            eventID = eventID,
        }
        target[marketTag] = entry
    end
    entry.supplyDelta = clamp(entry.supplyDelta
        + clamp(source.supplyDelta, -1, 1, 0), -1, 1, 0)
    entry.demandDelta = clamp(entry.demandDelta
        + clamp(source.demandDelta, -1, 1, 0), -1, 1, 0)
    entry.availabilityMultiplier = clamp(entry.availabilityMultiplier
        * clamp(source.availabilityMultiplier, 0, 4, 1), 0, 4, 1)
    entry.priceMultiplier = clamp(entry.priceMultiplier
        * clamp(source.priceMultiplier, 0, 4, 1), 0, 4, 1)
end

local function hash(value)
    local result = 17
    for index = 1, #value do
        result = (result * 31 + string.byte(value, index)) % MAX_REVISION
    end
    return result
end

local function activeContext(settlementID, record, options)
    local data, reason = eventData()
    local now = resolveNow(options)
    local resolvedSettlement
    local regionID
    local factionID
    local activeIDs = {}
    local modifiersByTag = {}
    local keys
    if not data then return nil, reason end
    resolvedSettlement, regionID, factionID = contextIDs(
        boundedID(settlementID), record, options)
    keys = sortedKeys(data.events)
    for index = 1, math.min(#keys, MAX_EVENTS) do
        local eventID = keys[index]
        local event = data.events[eventID]
        if isActive(event, now)
            and scopeMatches(event, resolvedSettlement, regionID, factionID)
        then
            activeIDs[#activeIDs + 1] = eventID
            for modifierIndex = 1, math.min(#(event.modifiers or {}),
                MAX_MODIFIERS) do
                local source = event.modifiers[modifierIndex]
                addModifier(modifiersByTag, source, eventID)
            end
        end
    end
    keys = sortedKeys(modifiersByTag)
    local modifiers = {}
    for index = 1, math.min(#keys, MAX_MODIFIERS) do
        modifiers[#modifiers + 1] = modifiersByTag[keys[index]]
    end
    local signature = tostring(data.revision or 0) .. "|"
        .. resolvedSettlement .. "|" .. regionID .. "|" .. factionID .. "|"
        .. table.concat(activeIDs, ",")
    return {
        revision = hash(signature),
        storeRevision = math.max(0, integer(data.revision, 0)),
        settlementID = resolvedSettlement ~= "" and resolvedSettlement or nil,
        regionID = regionID ~= "" and regionID or nil,
        factionID = factionID ~= "" and factionID or nil,
        now = now,
        activeEventIDs = activeIDs,
        activeEventCount = #activeIDs,
        modifiers = modifiers,
    }
end

function Registry.Get(eventID)
    local data, reason = eventData()
    local id = boundedID(eventID)
    if not data then return nil, reason end
    if id == "" then return nil, "event_id_required" end
    if not data.events[id] then return nil, "event_not_found" end
    return copyEvent(id, data.events[id])
end

function Registry.List(options)
    local data, reason = eventData()
    local output = {}
    local keys
    local now
    options = type(options) == "table" and options or {}
    if not data then return output, reason end
    keys = sortedKeys(data.events)
    now = resolveNow(options)
    for index = 1, math.min(#keys, MAX_EVENTS) do
        local event = data.events[keys[index]]
        if options.activeOnly ~= true or isActive(event, now) then
            local copy = copyEvent(keys[index], event)
            if copy then output[#output + 1] = copy end
        end
    end
    return output
end

function Registry.Register(eventID, definition)
    local data
    local reason
    local id = boundedID(eventID
        or (type(definition) == "table" and definition.eventID))
    local normalized
    local previous
    local oldRevision
    local saved
    if not authority() then return nil, "server_authority_required" end
    if id == "" then return nil, "event_id_required" end
    normalized, reason = copyEvent(id, definition)
    if not normalized then return nil, reason end
    data, reason = eventData()
    if not data then return nil, reason end
    previous = data.events[id]
    if not previous then
        local count = 0
        for _ in pairs(data.events) do count = count + 1 end
        if count >= MAX_EVENTS then return nil, "event_limit" end
    end
    oldRevision = data.revision
    data.events[id] = normalized
    saved, reason = Storage.SaveEventData()
    if not saved then
        data.events[id] = previous
        data.revision = oldRevision
        return nil, reason or "event_save_failed"
    end
    return copyEvent(id, normalized), previous == nil
end

function Registry.Remove(eventID)
    local data
    local reason
    local id = boundedID(eventID)
    local previous
    local oldRevision
    local saved
    if not authority() then return false, "server_authority_required" end
    if id == "" then return false, "event_id_required" end
    data, reason = eventData()
    if not data then return false, reason end
    previous = data.events[id]
    if not previous then return false, "event_not_found" end
    oldRevision = data.revision
    data.events[id] = nil
    saved, reason = Storage.SaveEventData()
    if not saved then
        data.events[id] = previous
        data.revision = oldRevision
        return false, reason or "event_save_failed"
    end
    return true
end

function Registry.ResolveContext(settlementID, record, options)
    return activeContext(settlementID, record, options)
end

function Registry.GetRevision(settlementID, record, options)
    local context, reason = activeContext(settlementID, record, options)
    if not context then return nil, reason end
    return context.revision
end

function Registry.Diagnostics(options)
    local data, reason = eventData()
    local count = 0
    local active = 0
    if not data then return { reason = reason } end
    for _ in pairs(data.events) do count = count + 1 end
    for _, _ in ipairs(Registry.List({
        activeOnly = true,
        now = type(options) == "table" and options.now or nil,
    })) do
        active = active + 1
    end
    return {
        version = Registry.VERSION,
        storeRevision = math.max(0, integer(data.revision, 0)),
        eventCount = count,
        activeCount = active,
        maxEvents = MAX_EVENTS,
        maxModifiers = MAX_MODIFIERS,
    }
end

return Registry

-- Versioned, data-only contracts for the settlement market and event
-- registries. This module deliberately does not resolve MarketSense tags,
-- apply prices, recover pressure, or mutate trader stock.

DTCommon = DTCommon or {}

local Schema = DTCommon.MarketSchema or {}
DTCommon.MarketSchema = Schema

Schema.MARKET_SCHEMA_VERSION = 1
Schema.EVENT_SCHEMA_VERSION = 1
Schema.MARKET_STORE_SCHEMA_VERSION = 1
Schema.EVENT_STORE_SCHEMA_VERSION = 1

Schema.MAX_SETTLEMENTS = 256
Schema.MAX_EVENTS = 128
Schema.MAX_CATEGORIES = 32
Schema.MAX_MODIFIERS = 16
Schema.MAX_ID_LENGTH = 192
Schema.MAX_PROFILE_LENGTH = 96
Schema.MAX_TYPE_LENGTH = 96
Schema.MAX_CATEGORY_LENGTH = 96
Schema.MAX_PRESENTATION_KEY_LENGTH = 128
Schema.MAX_TIMESTAMP = 2147483647
Schema.MAX_REVISION = 2147483647
Schema.MAX_IMPORTANCE = 5
Schema.MAX_MULTIPLIER = 4
Schema.DEFAULT_PROFILE_ID = "default"
Schema.DEFAULT_WEALTH = 0.5
Schema.DEFAULT_CATEGORY_SUPPLY = 0.5
Schema.DEFAULT_CATEGORY_DEMAND = 0.5

Schema.SCOPE_KINDS = {
    global = true,
    region = true,
    faction = true,
    settlement = true,
}

local function number(value, fallback)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge
        or value == -math.huge
    then return fallback end
    return value
end

local function integer(value, fallback, maximum)
    value = math.floor(number(value, fallback))
    if maximum and value > maximum then return maximum end
    return value
end

local function text(value, maximum, fallback)
    if value == nil then return fallback end
    value = tostring(value)
    if value == "" then return fallback end
    if maximum and #value > maximum then
        return string.sub(value, 1, maximum)
    end
    return value
end

local function clamp(value, low, high, fallback)
    value = number(value, fallback)
    return math.max(low, math.min(high, value))
end

local function schemaVersion(value, current, name)
    value = math.floor(number(value, 1))
    if value > current then
        return nil, tostring(name) .. "_schema_version_unsupported"
    end
    return current
end

local function sortedStringKeys(value)
    local keys = {}
    if type(value) ~= "table" then return keys end
    for key, _ in pairs(value) do
        if type(key) == "string" and key ~= "" then
            keys[#keys + 1] = key
        end
    end
    table.sort(keys)
    return keys
end

local function normalizeCategories(value)
    local categories = {}
    local keys = sortedStringKeys(value)
    for index = 1, math.min(#keys, Schema.MAX_CATEGORIES) do
        local sourceKey = keys[index]
        local category = value[sourceKey]
        local categoryKey = text(sourceKey, Schema.MAX_CATEGORY_LENGTH, nil)
        if categoryKey and categories[categoryKey] == nil
            and type(category) == "table"
        then
            categories[categoryKey] = {
                supply = clamp(category.supply, 0, 1,
                    Schema.DEFAULT_CATEGORY_SUPPLY),
                demand = clamp(category.demand, 0, 1,
                    Schema.DEFAULT_CATEGORY_DEMAND),
            }
        end
    end
    return categories
end

local function normalizeMarket(value, fallbackSettlementID)
    local source = type(value) == "table" and value or {}
    local version, reason
    local settlementID
    version, reason = schemaVersion(
        source.schemaVersion, Schema.MARKET_SCHEMA_VERSION, "market")
    if not version then return nil, reason end
    settlementID = text(source.settlementID or source.communityID
        or fallbackSettlementID, Schema.MAX_ID_LENGTH, nil)
    if not settlementID then return nil, "settlement_id_required" end
    return {
        schemaVersion = version,
        settlementID = settlementID,
        profileID = text(source.profileID, Schema.MAX_PROFILE_LENGTH,
            Schema.DEFAULT_PROFILE_ID),
        revision = clamp(integer(source.revision, 0, Schema.MAX_REVISION),
            0, Schema.MAX_REVISION, 0),
        lastUpdateAt = clamp(source.lastUpdateAt, 0,
            Schema.MAX_TIMESTAMP, 0),
        wealth = clamp(source.wealth, 0, 1, Schema.DEFAULT_WEALTH),
        categories = normalizeCategories(source.categories),
    }
end

local function normalizeScope(source)
    local raw = type(source.scope) == "table" and source.scope or {}
    local kind = text(raw.kind or raw.type or source.scopeKind, 32, "global")
    if not Schema.SCOPE_KINDS[kind] then
        return nil, "event_scope_invalid"
    end
    local id = text(raw.id or raw.settlementID or raw.factionID
        or raw.regionID or source.scopeID, Schema.MAX_ID_LENGTH, nil)
    if kind ~= "global" and not id then
        return nil, "event_scope_id_required"
    end
    return { kind = kind, id = kind == "global" and nil or id }
end

local function normalizeModifiers(value)
    local modifiers = {}
    if type(value) ~= "table" then return modifiers end
    for index = 1, math.min(#value, Schema.MAX_MODIFIERS) do
        local source = value[index]
        if type(source) == "table" then
            local marketTag = text(source.marketTag or source.category
                or source.tag, Schema.MAX_CATEGORY_LENGTH, nil)
            if marketTag then
                modifiers[#modifiers + 1] = {
                    marketTag = marketTag,
                    supplyDelta = clamp(source.supplyDelta, -1, 1, 0),
                    demandDelta = clamp(source.demandDelta, -1, 1, 0),
                    availabilityMultiplier = clamp(
                        source.availabilityMultiplier, 0,
                        Schema.MAX_MULTIPLIER, 1),
                    priceMultiplier = clamp(source.priceMultiplier, 0,
                        Schema.MAX_MULTIPLIER, 1),
                }
            end
        end
    end
    return modifiers
end

local function normalizePresentation(value)
    if type(value) ~= "table" then return nil end
    return {
        headlineKey = text(value.headlineKey,
            Schema.MAX_PRESENTATION_KEY_LENGTH, nil),
        descriptionKey = text(value.descriptionKey,
            Schema.MAX_PRESENTATION_KEY_LENGTH, nil),
        importance = integer(value.importance, 0, Schema.MAX_IMPORTANCE),
    }
end

local function normalizeEvent(value, fallbackEventID)
    local source = type(value) == "table" and value or {}
    local version, reason
    local eventID
    local scope
    local startsAt
    local endsAt
    version, reason = schemaVersion(
        source.schemaVersion, Schema.EVENT_SCHEMA_VERSION, "event")
    if not version then return nil, reason end
    eventID = text(source.eventID or source.id or fallbackEventID,
        Schema.MAX_ID_LENGTH, nil)
    if not eventID then return nil, "event_id_required" end
    scope, reason = normalizeScope(source)
    if not scope then return nil, reason end
    startsAt = clamp(source.startsAt, 0, Schema.MAX_TIMESTAMP, 0)
    endsAt = number(source.endsAt, nil)
    if endsAt ~= nil then
        endsAt = clamp(endsAt, startsAt, Schema.MAX_TIMESTAMP, startsAt)
    end
    return {
        schemaVersion = version,
        eventID = eventID,
        type = text(source.type, Schema.MAX_TYPE_LENGTH, "generic"),
        startsAt = startsAt,
        endsAt = endsAt,
        scope = scope,
        modifiers = normalizeModifiers(source.modifiers),
        presentation = normalizePresentation(source.presentation),
    }
end

local function normalizeMarketStore(value)
    local source = type(value) == "table" and value or {}
    local version, reason
    local markets = {}
    local keys = sortedStringKeys(source.markets)
    version, reason = schemaVersion(source.schemaVersion,
        Schema.MARKET_STORE_SCHEMA_VERSION, "market_store")
    if not version then return nil, reason end
    for index = 1, math.min(#keys, Schema.MAX_SETTLEMENTS) do
        local key = keys[index]
        local market = normalizeMarket(source.markets[key], key)
        if market then
            markets[market.settlementID] = market
        end
    end
    return {
        schemaVersion = version,
        revision = clamp(integer(source.revision, 0, Schema.MAX_REVISION),
            0, Schema.MAX_REVISION, 0),
        markets = markets,
    }
end

local function normalizeEventStore(value)
    local source = type(value) == "table" and value or {}
    local version, reason
    local events = {}
    local keys = sortedStringKeys(source.events)
    version, reason = schemaVersion(source.schemaVersion,
        Schema.EVENT_STORE_SCHEMA_VERSION, "event_store")
    if not version then return nil, reason end
    for index = 1, math.min(#keys, Schema.MAX_EVENTS) do
        local key = keys[index]
        local event = normalizeEvent(source.events[key], key)
        if event then events[event.eventID] = event end
    end
    return {
        schemaVersion = version,
        revision = clamp(integer(source.revision, 0, Schema.MAX_REVISION),
            0, Schema.MAX_REVISION, 0),
        events = events,
    }
end

Schema.NormalizeMarket = normalizeMarket
Schema.NormalizeSettlementMarket = normalizeMarket
Schema.NormalizeEvent = normalizeEvent
Schema.NormalizeMarketStore = normalizeMarketStore
Schema.NormalizeEventStore = normalizeEventStore

function Schema.NewMarket(settlementID, value)
    if type(settlementID) == "table" and value == nil then
        return normalizeMarket(settlementID, nil)
    end
    return normalizeMarket(value, settlementID)
end

function Schema.NewSettlementMarket(settlementID, value)
    return Schema.NewMarket(settlementID, value)
end

function Schema.NewEvent(eventID, value)
    if type(eventID) == "table" and value == nil then
        return normalizeEvent(eventID, nil)
    end
    return normalizeEvent(value, eventID)
end

function Schema.NewMarketStore(value)
    return normalizeMarketStore(value)
end

function Schema.NewEventStore(value)
    return normalizeEventStore(value)
end

return Schema

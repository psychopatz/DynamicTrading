-- Server and client shared settlement directory.
--
-- DTCommon owns only the commercial settlement lookup facade. Canonical
-- settlement identity/position comes from registered world providers (normally
-- PsychopatzCore SurvivorWorld). The built-in Kentucky list below is an explicit
-- legacy/test bootstrap helper and is never activated automatically.

DTCommon = DTCommon or {}

local Directory = DTCommon.SettlementDirectory or {}
DTCommon.SettlementDirectory = Directory

Directory.SCHEMA_VERSION = 1
Directory.MAX_SETTLEMENTS = 256

local entries = {}
local providers = {}

local DEFAULT_SETTLEMENTS = {
    {
        settlementID = "settlement:muldraugh",
        name = "Muldraugh",
        position = { x = 10630, y = 9980, z = 0 },
        profileID = "default",
        provider = "DTCommon",
        enabled = true,
    },
    {
        settlementID = "settlement:westpoint",
        name = "West Point",
        position = { x = 11900, y = 6900, z = 0 },
        profileID = "default",
        provider = "DTCommon",
        enabled = true,
    },
    {
        settlementID = "settlement:rosewood",
        name = "Rosewood",
        position = { x = 8150, y = 11550, z = 0 },
        profileID = "default",
        provider = "DTCommon",
        enabled = true,
    },
    {
        settlementID = "settlement:riverside",
        name = "Riverside",
        position = { x = 6500, y = 5350, z = 0 },
        profileID = "default",
        provider = "DTCommon",
        enabled = true,
    },
    {
        settlementID = "settlement:marchridge",
        name = "March Ridge",
        position = { x = 10050, y = 12750, z = 0 },
        profileID = "default",
        provider = "DTCommon",
        enabled = true,
    },
    {
        settlementID = "settlement:fallaslake",
        name = "Fallas Lake",
        position = { x = 7250, y = 8350, z = 0 },
        profileID = "default",
        provider = "DTCommon",
        enabled = true,
    },
    {
        settlementID = "settlement:louisville",
        name = "Louisville",
        position = { x = 12600, y = 1450, z = 0 },
        profileID = "default",
        provider = "DTCommon",
        enabled = true,
    },
}

local function isFiniteNumber(value)
    if type(value) ~= "number" then return false end
    if value ~= value then return false end
    if value == math.huge or value == -math.huge then return false end
    return true
end

local function cleanText(value, fallback)
    if type(value) ~= "string" or value == "" then return fallback end
    if #value > 128 then return string.sub(value, 1, 128) end
    return value
end

local function clone(value)
    if type(value) ~= "table" then return value end
    local output = {}
    for k, v in pairs(value) do
        output[k] = type(v) == "table" and clone(v) or v
    end
    return output
end

local function validatePosition(pos)
    if type(pos) ~= "table" then return nil, "position_table_required" end
    local x = tonumber(pos.x)
    local y = tonumber(pos.y)
    local z = tonumber(pos.z or 0)
    if not isFiniteNumber(x) or not isFiniteNumber(y) or not isFiniteNumber(z) then
        return nil, "position_coordinates_invalid"
    end
    return { x = x, y = y, z = math.floor(z) }
end

function Directory.Validate(entry)
    if type(entry) ~= "table" then return nil, "entry_table_required" end
    local id = cleanText(entry.settlementID or entry.id, nil)
    if not id then return nil, "settlement_id_required" end
    local name = cleanText(entry.name or entry.displayName, id)
    local position, posReason = validatePosition(entry.position or entry.point)
    if not position then return nil, posReason end
    local provider = cleanText(entry.provider, "DTCommon")
    local profileID = cleanText(entry.profileID, "default")
    local enabled = entry.enabled ~= false

    local regionID = cleanText(
        entry.regionID or entry.regionId or entry.region, nil)
    return {
        settlementID = id,
        name = name,
        position = position,
        provider = provider,
        profileID = profileID,
        regionID = regionID,
        enabled = enabled,
    }
end

function Directory.Register(entry)
    local validated, reason = Directory.Validate(entry)
    if not validated then return nil, reason end

    local count = 0
    for _ in pairs(entries) do count = count + 1 end
    if count >= Directory.MAX_SETTLEMENTS and not entries[validated.settlementID] then
        return nil, "settlement_capacity_reached"
    end

    entries[validated.settlementID] = validated
    return clone(validated)
end

function Directory.Unregister(settlementID)
    local id = cleanText(settlementID, nil)
    if not id or not entries[id] then return false, "settlement_not_found" end
    entries[id] = nil
    return true
end

function Directory.Get(settlementID)
    local id = cleanText(settlementID, nil)
    if not id then return nil, "settlement_id_required" end

    -- Check direct registered entries
    local direct = entries[id]
    if direct then return clone(direct) end

    -- Check external providers (e.g. Hoomans community provider)
    for _, provider in pairs(providers) do
        if type(provider.Get) == "function" then
            local ok, item = pcall(provider.Get, id)
            if ok and item then
                local validated = Directory.Validate(item)
                if validated then return validated end
            end
        end
    end

    return nil, "settlement_not_found"
end

function Directory.ResolvePosition(settlementID)
    local settlement, reason = Directory.Get(settlementID)
    if not settlement then return nil, reason end
    return clone(settlement.position)
end

function Directory.List(options)
    options = type(options) == "table" and options or {}
    local includeDisabled = options.includeDisabled == true
    local list = {}
    local seen = {}

    for id, entry in pairs(entries) do
        if not seen[id] and (includeDisabled or entry.enabled) then
            seen[id] = true
            list[#list + 1] = clone(entry)
        end
    end

    for _, provider in pairs(providers) do
        if type(provider.List) == "function" then
            local ok, items = pcall(provider.List)
            if ok and type(items) == "table" then
                for i = 1, #items do
                    local validated = Directory.Validate(items[i])
                    if validated and not seen[validated.settlementID] and (includeDisabled or validated.enabled) then
                        seen[validated.settlementID] = true
                        list[#list + 1] = validated
                    end
                end
            end
        end
    end

    table.sort(list, function(a, b)
        return a.settlementID < b.settlementID
    end)
    return list
end

function Directory.Count()
    local count = 0
    for _ in pairs(entries) do count = count + 1 end
    return count
end

function Directory.RegisterProvider(providerID, provider)
    providerID = cleanText(providerID, nil)
    if not providerID or type(provider) ~= "table" then
        return false, "invalid_provider"
    end
    providers[providerID] = provider
    return true
end

function Directory.UnregisterProvider(providerID)
    providerID = cleanText(providerID, nil)
    if not providerID then return false end
    providers[providerID] = nil
    return true
end

function Directory.EnsureDefaults()
    for i = 1, #DEFAULT_SETTLEMENTS do
        local def = DEFAULT_SETTLEMENTS[i]
        if not entries[def.settlementID] then
            Directory.Register(def)
        end
    end
end

Directory.RegisterLegacyDefaultsForMigration =
    Directory.EnsureDefaults

function Directory.Reset()
    entries = {}
    providers = {}
end

-- No automatic fallback registration. Production standalone geography is
-- supplied by the Core SurvivorWorld provider.
return Directory

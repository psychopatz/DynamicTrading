-- Server-authoritative bounded settlement market registry. It persists only
-- category pressure and profile identity; exact item inventory remains owned by
-- DTCommon.TraderService and MarketSense remains the catalog authority.

DTCommon = DTCommon or {}

local Registry = DTCommon.SettlementMarket or {}
DTCommon.SettlementMarket = Registry

local Schema = DTCommon.MarketSchema
local Storage = DTCommon.Storage
local MAX_REVISION = Schema and Schema.MAX_REVISION or 2147483647
local MAX_SETTLEMENTS = Schema and Schema.MAX_SETTLEMENTS or 256

Registry.VERSION = 1

local function authority()
    return Storage and type(Storage.IsAuthority) == "function"
        and Storage.IsAuthority() == true
end

local function boundedID(value)
    value = tostring(value or "")
    if #value > 192 then return string.sub(value, 1, 192) end
    return value
end

local function resolveCanonicalID(settlementID)
    local id = boundedID(settlementID)
    local communities = PNC and PNC.Communities or nil
    local community
    if id == "" then return nil, "settlement_id_required" end
    if not communities or type(communities.Get) ~= "function" then
        return id, "settlement_identity_unverified"
    end
    community = communities.Get(id)
    if type(community) ~= "table"
        or tostring(community.id or "") ~= id
        or community.status ~= "active"
    then
        return nil, "settlement_not_found"
    end
    return id
end

local function marketData()
    if not Storage or type(Storage.GetMarketData) ~= "function" then
        return nil, "market_storage_unavailable"
    end
    return Storage.GetMarketData()
end

local function copyMarket(value, fallbackID)
    if not Schema or type(Schema.NormalizeMarket) ~= "function" then
        return nil, "market_schema_unavailable"
    end
    return Schema.NormalizeMarket(value, fallbackID)
end

local function nextRevision(value)
    value = math.max(0, math.floor(tonumber(value) or 0))
    return math.min(MAX_REVISION, value + 1)
end

function Registry.ResolveSettlementID(settlementID)
    return resolveCanonicalID(settlementID)
end

function Registry.Get(settlementID)
    local id = boundedID(settlementID)
    local data, reason
    local record
    if id == "" then return nil, "settlement_id_required" end
    data, reason = marketData()
    if not data then return nil, reason end
    record = data.markets and data.markets[id] or nil
    if not record then return nil, "market_not_found" end
    return copyMarket(record, id)
end

function Registry.GetOrCreate(settlementID, definition)
    local id
    local reason
    local data
    local existing
    local market
    local oldRevision
    local saved
    if type(definition) == "string" then
        definition = { profileID = definition }
    end
    definition = type(definition) == "table" and definition or {}
    id, reason = resolveCanonicalID(settlementID)
    if not id then return nil, reason end
    data, reason = marketData()
    if not data then return nil, reason end
    existing = data.markets and data.markets[id] or nil
    if existing then return copyMarket(existing, id), false end
    if not authority() then return nil, "server_authority_required" end
    if not Schema or type(Schema.NewSettlementMarket) ~= "function" then
        return nil, "market_schema_unavailable"
    end
    market, reason = Schema.NewSettlementMarket(id, definition)
    if not market then return nil, reason end
    oldRevision = data.revision
    data.markets[id] = market
    saved, reason = Storage.SaveMarketData()
    if not saved then
        data.markets[id] = nil
        data.revision = oldRevision
        return nil, reason or "market_save_failed"
    end
    return copyMarket(market, id), true
end

function Registry.Commit(settlementID, value, expectedRevision)
    local id
    local reason
    local data
    local existing
    local normalized
    local oldRevision
    local oldMarket
    local saved
    local incomingRevision
    if not authority() then return nil, "server_authority_required" end
    id, reason = resolveCanonicalID(settlementID)
    if not id then return nil, reason end
    data, reason = marketData()
    if not data then return nil, reason end
    existing = data.markets and data.markets[id] or nil
    if not existing then return nil, "market_not_found" end
    if expectedRevision ~= nil then
        incomingRevision = tonumber(expectedRevision)
        if not incomingRevision
            or math.floor(incomingRevision) ~= tonumber(existing.revision or 0)
        then
            return nil, "market_revision_conflict"
        end
    end
    normalized, reason = copyMarket(value, id)
    if not normalized then return nil, reason end
    normalized.settlementID = id
    normalized.revision = nextRevision(existing.revision)
    oldMarket = existing
    oldRevision = data.revision
    data.markets[id] = normalized
    saved, reason = Storage.SaveMarketData()
    if not saved then
        data.markets[id] = oldMarket
        data.revision = oldRevision
        return nil, reason or "market_save_failed"
    end
    return copyMarket(normalized, id)
end

function Registry.List(limit)
    local data, reason = marketData()
    local keys = {}
    local output = {}
    limit = math.floor(tonumber(limit) or MAX_SETTLEMENTS)
    limit = math.max(1, math.min(MAX_SETTLEMENTS, limit))
    if not data then return output, reason end
    for key, _ in pairs(data.markets or {}) do
        if type(key) == "string" then keys[#keys + 1] = key end
    end
    table.sort(keys)
    for index = 1, math.min(#keys, limit) do
        local market = copyMarket(data.markets[keys[index]], keys[index])
        if market then output[#output + 1] = market end
    end
    return output
end

function Registry.Diagnostics()
    local data, reason = marketData()
    local count = 0
    local categoryCount = 0
    local categories = {}
    if not data then return nil, reason end
    for _, market in pairs(data.markets or {}) do
        count = count + 1
        for category, _ in pairs(market.categories or {}) do
            categories[category] = true
        end
    end
    for _, _ in pairs(categories) do categoryCount = categoryCount + 1 end
    return {
        version = Registry.VERSION,
        schemaVersion = data.schemaVersion,
        revision = data.revision,
        marketCount = count,
        categoryCount = categoryCount,
    }
end

return Registry

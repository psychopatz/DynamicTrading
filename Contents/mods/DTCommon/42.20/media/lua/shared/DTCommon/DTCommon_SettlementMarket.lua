-- Server-authoritative bounded settlement market registry. It persists only
-- category pressure and profile identity; exact item inventory remains owned by
-- DTCommon.TraderService and MarketSense remains the catalog authority.

DTCommon = DTCommon or {}

local Registry = DTCommon.SettlementMarket or {}
DTCommon.SettlementMarket = Registry

local Schema = DTCommon.MarketSchema
local Storage = DTCommon.Storage
local Profiles = DTCommon.MarketProfiles
local MAX_REVISION = Schema and Schema.MAX_REVISION or 2147483647
local MAX_SETTLEMENTS = Schema and Schema.MAX_SETTLEMENTS or 256
local MAX_TIMESTAMP = Schema and Schema.MAX_TIMESTAMP or 2147483647

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

local function clamp(value, low, high, fallback)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge
        or value == -math.huge
    then value = fallback end
    return math.max(low, math.min(high, value))
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
    local profile
    local marketDefinition
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
    if Profiles and type(Profiles.BuildMarketDefinition) == "function" then
        marketDefinition, profile = Profiles.BuildMarketDefinition(
            definition.profileID, definition)
    else
        marketDefinition = definition
    end
    market, reason = Schema.NewSettlementMarket(id, marketDefinition)
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

function Registry.ApplyDelta(settlementID, delta, options)
    local id = boundedID(settlementID)
    local current
    local candidate
    local categories
    local keys
    local expectedRevision
    local changed = false
    local now
    local value
    local baseline
    local supply
    local demand
    local index
    local key
    local committed
    if not authority() then return nil, "server_authority_required" end
    options = type(options) == "table" and options or {}
    current = Registry.Get(id)
    if not current then return nil, "market_not_found" end
    delta = type(delta) == "table" and delta or {}
    categories = type(delta.categories) == "table"
        and delta.categories or delta
    candidate = {
        profileID = current.profileID,
        wealth = current.wealth,
        lastUpdateAt = current.lastUpdateAt,
        categories = {},
    }
    for key, value in pairs(current.categories or {}) do
        candidate.categories[key] = {
            supply = value.supply,
            demand = value.demand,
        }
    end
    keys = sortedKeys(categories)
    for index = 1, math.min(#keys, Schema.MAX_CATEGORIES) do
        key = keys[index]
        value = categories[key]
        if type(value) == "table" then
            baseline = candidate.categories[key]
                or (Profiles and Profiles.Baseline
                    and Profiles.Baseline(current.profileID, key))
                or { supply = 0.5, demand = 0.5 }
            supply = clamp(baseline.supply
                + clamp(value.supplyDelta, -1, 1, 0), 0, 1, 0.5)
            demand = clamp(baseline.demand
                + clamp(value.demandDelta, -1, 1, 0), 0, 1, 0.5)
            if supply ~= baseline.supply or demand ~= baseline.demand
            then changed = true end
            candidate.categories[key] = {
                supply = supply,
                demand = demand,
            }
        end
    end
    value = clamp(delta.wealthDelta, -1, 1, 0)
    candidate.wealth = clamp(candidate.wealth + value, 0, 1, 0.5)
    if candidate.wealth ~= current.wealth then changed = true end
    now = tonumber(options.now)
    if now then
        now = clamp(now, current.lastUpdateAt, MAX_TIMESTAMP,
            current.lastUpdateAt)
        if now ~= current.lastUpdateAt then changed = true end
        candidate.lastUpdateAt = now
    end
    if not changed then return current, false end
    expectedRevision = options.expectedRevision
    if expectedRevision == nil then expectedRevision = current.revision end
    committed, value = Registry.Commit(id, candidate, expectedRevision)
    if not committed then return nil, value end
    return committed, true
end

function Registry.Recover(settlementID, elapsedHours, options)
    local id = boundedID(settlementID)
    local current
    local candidate
    local profile
    local categories = {}
    local keys
    local hours
    local now
    local rate
    local factor
    local source
    local target
    local value
    local changed = false
    local key
    local committed
    local reason
    options = type(options) == "table" and options or {}
    current = Registry.Get(id)
    if not current then return nil, "market_not_found" end
    if Profiles and type(Profiles.Get) == "function" then
        profile = Profiles.Get(current.profileID)
    end
    profile = profile or {
        wealth = 0.5,
        categories = {},
    }
    hours = tonumber(elapsedHours or options.elapsedHours)
    now = tonumber(options.now)
    if hours == nil and now ~= nil then
        hours = math.max(0, now - current.lastUpdateAt)
    end
    hours = clamp(hours, 0, MAX_TIMESTAMP, 0)
    rate = clamp(options.recoveryRate, 0, 1,
        Profiles and Profiles.RECOVERY_RATE_PER_HOUR or 0.1)
    factor = math.min(1, hours * rate)
    if now == nil then now = current.lastUpdateAt + hours end
    now = clamp(now, current.lastUpdateAt, MAX_TIMESTAMP,
        current.lastUpdateAt)
    for key, value in pairs(current.categories or {}) do
        categories[key] = value
    end
    for key, value in pairs(profile.categories or {}) do
        categories[key] = categories[key] or value
    end
    candidate = {
        profileID = current.profileID,
        wealth = current.wealth + (profile.wealth - current.wealth) * factor,
        lastUpdateAt = now,
        categories = {},
    }
    if candidate.wealth ~= current.wealth then changed = true end
    keys = sortedKeys(categories)
    for index = 1, math.min(#keys, Schema.MAX_CATEGORIES) do
        key = keys[index]
        source = current.categories[key] or { supply = 0.5, demand = 0.5 }
        target = Profiles and Profiles.Baseline
            and Profiles.Baseline(current.profileID, key)
            or { supply = 0.5, demand = 0.5 }
        value = {
            supply = clamp(source.supply
                + (target.supply - source.supply) * factor, 0, 1, 0.5),
            demand = clamp(source.demand
                + (target.demand - source.demand) * factor, 0, 1, 0.5),
        }
        if value.supply ~= source.supply or value.demand ~= source.demand
        then changed = true end
        candidate.categories[key] = value
    end
    if now ~= current.lastUpdateAt then changed = true end
    if not changed then return current, false end
    committed, reason = Registry.Commit(id, candidate, current.revision)
    if not committed then return nil, reason end
    return committed, true
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

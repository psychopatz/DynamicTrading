-- Bounded in-memory adapter over MarketSense's public catalog. The catalog is
-- runtime cache only: settlement persistence stores category pressure, never
-- this item universe or duplicated intrinsic definitions.

DTCommon = DTCommon or {}

local Catalog = DTCommon.MarketCatalog or {}
DTCommon.MarketCatalog = Catalog

Catalog.VERSION = 1
Catalog.MAX_ITEMS = 4096
Catalog.MAX_TAGS_PER_ITEM = 32
Catalog.MAX_QUERY_RESULTS = 64
Catalog.MAX_CATEGORY_LENGTH = 96
Catalog.MAX_DYNAMIC_FACTS = 256

local function newState()
    return {
        built = false,
        buildCount = 0,
        scannedCount = 0,
        indexedCount = 0,
        byType = {},
        byCategory = {},
        dynamicByType = {},
        dynamicCount = 0,
    }
end

Catalog._state = Catalog._state or newState()
Catalog._state.dynamicByType = Catalog._state.dynamicByType or {}
Catalog._state.dynamicCount = math.max(0, math.min(
    Catalog.MAX_DYNAMIC_FACTS,
    math.floor(tonumber(Catalog._state.dynamicCount) or 0)))

local function api()
    return rawget(_G, "MarketSense")
end

local function boundedText(value, maximum)
    value = tostring(value or "")
    if value == "" then return nil end
    if #value > maximum then return string.sub(value, 1, maximum) end
    return value
end

local function copyArray(value, maximum)
    local output = {}
    if type(value) ~= "table" then return output end
    for index = 1, math.min(#value, maximum) do
        local item = boundedText(value[index], 192)
        if item then output[#output + 1] = item end
    end
    return output
end

local function sortedKeys(value)
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

local function availabilityStatus(value)
    if type(value) == "table" then
        return boundedText(value.status or value.state, 48)
    end
    return boundedText(value, 48)
end

local function tagsFor(fullType, entry, marketSense)
    local tags = type(entry) == "table" and entry.tags or nil
    local expandedTags = type(entry) == "table" and entry.expandedTags or nil
    local category = type(entry) == "table" and entry.category or nil
    local primary = type(entry) == "table" and entry.primary or nil
    local tagInfo
    if (not category or type(tags) ~= "table")
        and type(marketSense.GetTags) == "function"
    then
        local ok
        ok, tagInfo = pcall(marketSense.GetTags, fullType)
        if not ok then tagInfo = nil end
    end
    if type(tagInfo) == "table" then
        category = category or tagInfo.category
        primary = primary or tagInfo.primary
        tags = type(tags) == "table" and tags or tagInfo.tags
        expandedTags = type(expandedTags) == "table"
            and expandedTags or tagInfo.expandedTags
    end
    category = boundedText(category, Catalog.MAX_CATEGORY_LENGTH)
    if not category then return nil end
    return {
        category = category,
        primary = boundedText(primary, Catalog.MAX_CATEGORY_LENGTH),
        tags = copyArray(tags, Catalog.MAX_TAGS_PER_ITEM),
        expandedTags = copyArray(expandedTags, Catalog.MAX_TAGS_PER_ITEM),
    }
end

local function factFor(fullType, entry, marketSense)
    local tags = tagsFor(fullType, entry, marketSense)
    local availability = type(entry) == "table" and entry.availability or nil
    local status
    if not availability and type(marketSense.GetItemAvailability) == "function"
    then
        local ok
        ok, availability = pcall(
            marketSense.GetItemAvailability, fullType)
        if not ok then availability = nil end
    end
    if not tags then return nil end
    status = availabilityStatus(availability)
    return {
        fullType = fullType,
        category = tags.category,
        primary = tags.primary,
        tags = tags.tags,
        expandedTags = tags.expandedTags,
        availabilityStatus = status,
        obtainable = status == "obtainable",
        tradeable = tostring(fullType)
            ~= tostring(DTCommon.MONEY_FULL_TYPE or "Base.Money"),
        price = tonumber(type(entry) == "table" and entry.price or nil),
    }
end

local function addFact(state, fact)
    local categoryRows
    if not fact or state.byType[fact.fullType] then return false end
    state.byType[fact.fullType] = fact
    categoryRows = state.byCategory[fact.category]
    if not categoryRows then
        categoryRows = {}
        state.byCategory[fact.category] = categoryRows
    end
    categoryRows[#categoryRows + 1] = fact.fullType
    state.indexedCount = state.indexedCount + 1
    return true
end

function Catalog.Reset()
    Catalog._state = newState()
    return true
end

function Catalog.Build()
    local marketSense = api()
    local state = Catalog._state
    local known
    local keys
    local limit
    if state.built then return true, "already_built" end
    if type(marketSense) ~= "table"
        or type(marketSense.GetAllKnownItems) ~= "function"
    then
        return false, "marketsense_catalog_unavailable"
    end
    if type(marketSense.EnsureRuntimeRegistryLoaded) == "function" then
        pcall(marketSense.EnsureRuntimeRegistryLoaded, false)
    end
    local ok
    ok, known = pcall(marketSense.GetAllKnownItems)
    if not ok or type(known) ~= "table" then
        return false, "marketsense_catalog_unavailable"
    end
    keys = sortedKeys(known)
    limit = math.min(#keys, Catalog.MAX_ITEMS)
    state.scannedCount = limit
    for index = 1, limit do
        local key = keys[index]
        local entry = known[key]
        local fullType = type(entry) == "table"
            and (entry.fullType or entry.item or key) or key
        fullType = boundedText(fullType, 192)
        if fullType then addFact(state, factFor(fullType, entry, marketSense)) end
    end
    for _, rows in pairs(state.byCategory) do
        table.sort(rows)
    end
    state.built = true
    state.buildCount = state.buildCount + 1
    return true, "built"
end

function Catalog.Ensure()
    return Catalog.Build()
end

function Catalog.Invalidate()
    return Catalog.Reset()
end

function Catalog.Get(fullType)
    local state = Catalog._state
    local key = boundedText(fullType, 192)
    local fact = key and state.byType[key] or nil
    local marketSense
    local dynamic
    if fact then return fact end
    dynamic = key and state.dynamicByType[key] or nil
    if dynamic then return dynamic end
    marketSense = api()
    if not key or type(marketSense) ~= "table" then
        return nil, "marketsense_unavailable"
    end
    fact = factFor(key, {}, marketSense)
    if not fact then return nil, "market_tags_unavailable" end
    if state.dynamicCount < Catalog.MAX_DYNAMIC_FACTS then
        state.dynamicByType[key] = fact
        state.dynamicCount = state.dynamicCount + 1
    end
    return fact
end

function Catalog.Categories()
    local state = Catalog._state
    local categories = {}
    local ok, reason = Catalog.Ensure()
    if not ok then return categories, reason end
    for category, _ in pairs(state.byCategory) do
        categories[#categories + 1] = category
    end
    table.sort(categories)
    return categories
end

function Catalog.ListCategory(category, options)
    local state = Catalog._state
    local rows
    local output = {}
    local limit
    local availableOnly
    local ok, reason = Catalog.Ensure()
    category = boundedText(category, Catalog.MAX_CATEGORY_LENGTH)
    if not ok then return output, reason end
    if not category then return output, "category_required" end
    options = type(options) == "table" and options or {}
    limit = math.floor(tonumber(options.limit) or Catalog.MAX_QUERY_RESULTS)
    limit = math.max(1, math.min(Catalog.MAX_QUERY_RESULTS, limit))
    availableOnly = options.availableOnly == true
    rows = state.byCategory[category] or {}
    for index = 1, math.min(#rows, limit) do
        local fact = state.byType[rows[index]]
        if fact and (not availableOnly or fact.obtainable == true)
            and fact.tradeable ~= false
        then
            output[#output + 1] = rows[index]
        end
    end
    return output
end

function Catalog.GetCandidates(category, options)
    local request = {}
    options = type(options) == "table" and options or {}
    for key, value in pairs(options) do request[key] = value end
    if request.availableOnly == nil then request.availableOnly = true end
    return Catalog.ListCategory(category, request)
end

function Catalog.Diagnostics()
    local state = Catalog._state
    local categoryCount = 0
    for _, _ in pairs(state.byCategory) do categoryCount = categoryCount + 1 end
    return {
        version = Catalog.VERSION,
        built = state.built == true,
        buildCount = state.buildCount,
        scannedCount = state.scannedCount,
        indexedCount = state.indexedCount,
        dynamicCount = state.dynamicCount,
        dynamicLimit = Catalog.MAX_DYNAMIC_FACTS,
        categoryCount = categoryCount,
    }
end

if Events and Events.OnGameStart
    and type(Events.OnGameStart.Add) == "function"
    and not Catalog._startupHookRegistered
then
    Catalog._startupHookRegistered = true
    Events.OnGameStart.Add(function() Catalog.Ensure() end)
end

return Catalog

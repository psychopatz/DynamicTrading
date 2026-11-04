-- Stateless DynamicTrading dependency seam over canonical MarketSense APIs.
-- This module owns no item-universe state, taxonomy cache, or intrinsic price.

DTCommon = DTCommon or {}

local Gateway = DTCommon.MarketSenseGateway or {}
DTCommon.MarketSenseGateway = Gateway

Gateway.VERSION = 1
Gateway.MAX_QUERY_RESULTS = 64

local function api()
    local marketSense = rawget(_G, "MarketSense")
    return type(marketSense) == "table" and marketSense or nil
end

local function text(value, maximum)
    value = tostring(value or "")
    if value == "" then return nil end
    maximum = math.max(1, math.floor(tonumber(maximum) or 192))
    if #value > maximum then return string.sub(value, 1, maximum) end
    return value
end

local function unavailable()
    local marketSense = api()
    if not marketSense then return nil, "marketsense_unavailable" end
    if type(marketSense.QueryItems) ~= "function"
        or type(marketSense.GetCatalogItem) ~= "function"
    then
        return nil, "marketsense_query_unavailable"
    end
    if type(marketSense.IsCatalogReady) == "function"
        and marketSense.IsCatalogReady() ~= true
    then
        return nil, "marketsense_catalog_not_ready"
    end
    return marketSense
end

local function isCurrency(fullType)
    fullType = tostring(fullType or "")
    return fullType == tostring(DTCommon.MONEY_FULL_TYPE or "Base.Money")
        or fullType == "Base.MoneyBundle"
end

local function factFrom(row)
    if type(row) ~= "table" then return nil end
    local fullType = text(row.fullType, 192)
    local category = text(row.category, 96)
    if not fullType or not category then return nil end
    local availability = type(row.availability) == "table"
        and row.availability or nil
    return {
        fullType = fullType,
        category = category,
        primary = text(row.primary, 96),
        availabilityStatus = availability
            and text(availability.status, 48) or nil,
        obtainable = availability
            and availability.obtainable == true or false,
        tradeable = not isCurrency(fullType),
        sourceModId = text(row.sourceModId, 96),
        moduleName = text(row.moduleName, 96),
    }
end

function Gateway.IsReady()
    local marketSense = api()
    return marketSense ~= nil
        and type(marketSense.QueryItems) == "function"
        and type(marketSense.GetCatalogItem) == "function"
        and (type(marketSense.IsCatalogReady) ~= "function"
            or marketSense.IsCatalogReady() == true)
end

function Gateway.GetCatalogRevision()
    local marketSense = api()
    if marketSense
        and type(marketSense.GetCatalogRevision) == "function"
    then
        return math.max(0, math.floor(tonumber(
            marketSense.GetCatalogRevision()
        ) or 0))
    end
    return 0
end

function Gateway.GetPricingRevision()
    local marketSense = api()
    if marketSense
        and type(marketSense.GetPricingRevision) == "function"
    then
        return math.max(0, math.floor(tonumber(
            marketSense.GetPricingRevision()
        ) or 0))
    end
    return 0
end

function Gateway.Get(fullType)
    local marketSense, reason = unavailable()
    local key = text(fullType, 192)
    if not key then return nil, "item_required" end
    if not marketSense then return nil, reason end

    local ok, row, rowReason = pcall(
        marketSense.GetCatalogItem,
        key
    )
    if not ok then
        return nil, "marketsense_query_failed"
    end
    if type(row) ~= "table" then
        return nil, rowReason or "market_item_unavailable"
    end
    local fact = factFrom(row)
    if not fact then return nil, "market_category_unavailable" end
    return fact
end

function Gateway.GetCandidates(category, options)
    local marketSense, reason = unavailable()
    local output = {}
    category = text(category, 96)
    if not category then return output, "category_required" end
    if not marketSense then return output, reason end

    options = type(options) == "table" and options or {}
    local limit = math.max(1, math.min(
        Gateway.MAX_QUERY_RESULTS,
        math.floor(tonumber(options.limit) or 8)
    ))
    local ok, rows, queryReason = pcall(
        marketSense.QueryItems,
        {
            category = category,
            obtainableOnly = options.availableOnly ~= false,
            limit = limit,
        }
    )
    if not ok or type(rows) ~= "table" then
        return output, queryReason or "marketsense_query_failed"
    end
    for _, row in ipairs(rows) do
        local fullType = row and text(row.fullType, 192) or nil
        if fullType and not isCurrency(fullType) then
            output[#output + 1] = fullType
        end
    end
    return output
end

function Gateway.GetStockSeedCandidates(options)
    local marketSense, reason = unavailable()
    local output = {}
    local selected = {}
    if not marketSense then return output, reason end

    options = type(options) == "table" and options or {}
    local limit = math.max(1, math.min(
        Gateway.MAX_QUERY_RESULTS,
        math.floor(tonumber(options.limit) or 32)
    ))
    local defaults = type(options.defaults) == "table"
        and options.defaults or {}

    local function add(row, quantity, fixture)
        if #output >= limit or type(row) ~= "table" then return end
        local fact = factFrom(row)
        if not fact or fact.obtainable ~= true
            or fact.tradeable == false
            or selected[fact.fullType]
        then
            return
        end
        selected[fact.fullType] = true
        output[#output + 1] = {
            fullType = fact.fullType,
            quantity = quantity,
            fixture = fixture == true,
            workshop = tostring(fact.sourceModId or "") ~= "Vanilla"
                and tostring(fact.sourceModId or "") ~= "",
        }
    end

    for _, value in ipairs(defaults) do
        if #output >= limit then break end
        if type(value) == "table" and value.fullType then
            local ok, row = pcall(
                marketSense.GetCatalogItem,
                tostring(value.fullType)
            )
            if ok then add(row, value.quantity, true) end
        end
    end

    if #output < limit then
        local ok, rows = pcall(
            marketSense.QueryItems,
            {
                obtainableOnly = true,
                moddedOnly = true,
                limit = math.min(limit, 8),
            }
        )
        if ok and type(rows) == "table" then
            for _, row in ipairs(rows) do
                add(row, 1, false)
                if #output >= limit then break end
            end
        end
    end

    if #output < limit then
        local ok, rows = pcall(
            marketSense.QueryItems,
            {
                obtainableOnly = true,
                limit = limit,
            }
        )
        if ok and type(rows) == "table" then
            for _, row in ipairs(rows) do
                add(row, 1, false)
                if #output >= limit then break end
            end
        end
    end

    return output
end

function Gateway.Diagnostics()
    return {
        version = Gateway.VERSION,
        ready = Gateway.IsReady(),
        catalogRevision = Gateway.GetCatalogRevision(),
        pricingRevision = Gateway.GetPricingRevision(),
        persistentUniverseState = false,
    }
end

return Gateway

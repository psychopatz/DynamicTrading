DTCommon = DTCommon or {}
DTCommon.TraderStock = DTCommon.TraderStock or {}

local Stock = DTCommon.TraderStock
local Inventory = require "PsychopatzCore/Inventory/PsychopatzInventory"
local Storage = DTCommon.Storage
local Support = DTCommon.TraderSupport
local INITIAL_STOCK_LIMIT = 8

local function tradeAudit()
    local audit = rawget(DTCommon, "TradeAudit")
    return type(audit) == "table" and audit or nil
end

local function auditIsEnabled(audit)
    return audit and type(audit.IsEnabled) == "function"
        and audit.IsEnabled() == true
end

local function recordPrice(audit, enabled, fullType, inventoryItem,
    result, details)
    if enabled and audit and type(audit.RecordPrice) == "function" then
        audit.RecordPrice(fullType, inventoryItem, result, details)
    end
    return result
end

local function unavailable(fullType, reason)
    return {
        ok = false,
        status = "UNAVAILABLE",
        reason = reason,
        fullType = fullType,
    }
end

local function finitePositive(value)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge
        or value == -math.huge or value <= 0
    then
        return nil
    end
    return math.floor(value)
end

local function isCurrency(fullType)
    return tostring(fullType or "") == tostring(DTCommon.MONEY_FULL_TYPE)
        or tostring(fullType or "") == "Base.MoneyBundle"
end

local function itemValue(item, method, fallback)
    local fn = item and item[method]
    local ok
    local value
    if type(fn) ~= "function" then return fallback end
    ok, value = pcall(fn, item)
    if not ok or value == nil then return fallback end
    return value
end

-- The only price boundary used by DynamicTrading.  MarketSense owns both the
-- definition classification and concrete-instance valuation; DTCommon only
-- validates the returned primitive and applies its trade margin below.
function Stock.Price(fullType, inventoryItem)
    local api = rawget(_G, "MarketSense")
    local audit = tradeAudit()
    local auditEnabled = auditIsEnabled(audit)
    local details
    local ok
    local price
    local timer
    fullType = tostring(fullType or "")
    if fullType == "" then
        return recordPrice(audit, auditEnabled, fullType, inventoryItem,
            unavailable(fullType, "item_required"), nil)
    end
    if isCurrency(fullType) then
        return recordPrice(audit, auditEnabled, fullType, inventoryItem,
            unavailable(fullType, "currency_not_tradeable"), nil)
    end
    if type(api) ~= "table" then
        return recordPrice(audit, auditEnabled, fullType, inventoryItem,
            unavailable(fullType, "marketsense_unavailable"), nil)
    end
    if audit and type(audit.BeginTimer) == "function" then
        timer = audit.BeginTimer(audit.METRIC_MARKETSENSE_PRICE)
    end
    if inventoryItem ~= nil then
        if type(api.GetPriceDetailsForInstance) ~= "function" then
            if timer and type(audit.FinishTimer) == "function" then
                audit.FinishTimer(audit.METRIC_MARKETSENSE_PRICE, timer)
            end
            return recordPrice(audit, auditEnabled, fullType, inventoryItem,
                unavailable(fullType, "instance_price_api_unavailable"), nil)
        end
        ok, details = pcall(
            api.GetPriceDetailsForInstance,
            fullType,
            inventoryItem,
            auditEnabled
        )
    else
        if type(api.GetPriceDetails) ~= "function" then
            if timer and type(audit.FinishTimer) == "function" then
                audit.FinishTimer(audit.METRIC_MARKETSENSE_PRICE, timer)
            end
            return recordPrice(audit, auditEnabled, fullType, inventoryItem,
                unavailable(fullType, "definition_price_api_unavailable"), nil)
        end
        ok, details = pcall(api.GetPriceDetails, fullType, auditEnabled)
    end
    if timer and type(audit.FinishTimer) == "function" then
        audit.FinishTimer(audit.METRIC_MARKETSENSE_PRICE, timer)
    end
    if not ok or type(details) ~= "table" then
        return recordPrice(audit, auditEnabled, fullType, inventoryItem,
            unavailable(fullType, "price_details_unavailable"), details)
    end
    price = finitePositive(details.price)
    if not price or price < 1 then
        return recordPrice(audit, auditEnabled, fullType, inventoryItem,
            unavailable(fullType, "price_unavailable"), details)
    end
    return recordPrice(audit, auditEnabled, fullType, inventoryItem, {
        ok = true,
        status = "OK",
        fullType = fullType,
        intrinsicPrice = price,
        source = inventoryItem ~= nil and "instance" or "definition",
    }, details)
end

function Stock.Quote(fullType, operation, inventoryItem, pricingContext)
    local price = Stock.Price(fullType, inventoryItem)
    local audit = tradeAudit()
    local auditEnabled = auditIsEnabled(audit)
    local pricing = rawget(DTCommon, "MarketPricing")
    local itemContext
    local commercialBase
    local commercialMargin
    local relationshipFactor
    local marketModifier
    local eventPriceMultiplier
    local priceBeforeRounding
    local unitPrice
    operation = string.upper(tostring(operation or DTCommon.OP_BUY))
    if not price.ok then
        if auditEnabled and type(audit.RecordQuote) == "function" then
            audit.RecordQuote(fullType, operation, price)
        end
        return price
    end
    if operation == DTCommon.OP_SELL then
        unitPrice = math.floor(price.intrinsicPrice * 0.5)
        -- This floor applies only after a valid positive MarketSense price.
        unitPrice = math.max(1, unitPrice)
        commercialMargin = 0.5
    elseif operation == DTCommon.OP_BUY then
        unitPrice = price.intrinsicPrice
        commercialMargin = 1
    else
        local result = unavailable(price.fullType, "operation_not_supported")
        if auditEnabled and type(audit.RecordQuote) == "function" then
            audit.RecordQuote(fullType, operation, result)
        end
        return result
    end
    commercialBase = unitPrice
    local modifier = pricingContext
        and tonumber(pricingContext.relationshipModifier) or 0
    if not modifier or modifier ~= modifier then modifier = 0 end
    modifier = math.max(-0.25, math.min(0.25, modifier))
    relationshipFactor = operation == DTCommon.OP_BUY
        and (1 - modifier) or (1 + modifier)
    itemContext = {
        marketModifier = 0,
        eventPriceMultiplier = 1,
        eventCount = 0,
    }
    if pricing and type(pricing.GetItemContext) == "function" then
        local ok
        local resolved
        ok, resolved = pcall(pricing.GetItemContext, fullType,
            pricingContext)
        if ok and type(resolved) == "table" then itemContext = resolved end
    end
    marketModifier = tonumber(itemContext.marketModifier) or 0
    marketModifier = math.max(-0.25, math.min(0.25, marketModifier))
    eventPriceMultiplier = tonumber(itemContext.eventPriceMultiplier) or 1
    if eventPriceMultiplier ~= eventPriceMultiplier then
        eventPriceMultiplier = 1
    end
    eventPriceMultiplier = math.max(0, math.min(4, eventPriceMultiplier))
    priceBeforeRounding = commercialBase * (1 + marketModifier)
        * eventPriceMultiplier * relationshipFactor
    unitPrice = math.floor(priceBeforeRounding + 0.5)
    price.operation = operation
    price.unitPrice = math.max(1, unitPrice)
    price.relationshipModifier = modifier
    price.commercialMargin = commercialMargin
    price.marketModifier = marketModifier
    price.marketCategory = itemContext.category
    price.marketSupply = itemContext.marketSupply
    price.marketDemand = itemContext.marketDemand
    price.effectiveSupply = itemContext.effectiveSupply
    price.effectiveDemand = itemContext.effectiveDemand
    price.marketPressure = itemContext.marketPressure or 0
    price.marketApplied = itemContext.marketApplied == true
    price.marketRevision = itemContext.marketRevision
    price.eventRevision = itemContext.eventRevision
    price.availabilityMultiplier = itemContext.availabilityMultiplier or 1
    price.eventPriceMultiplier = eventPriceMultiplier
    price.eventCount = itemContext.eventCount or 0
    price.activeEventCount = itemContext.activeEventCount or 0
    price.settlementID = itemContext.settlementID
    price.explanation = {
        fullType = price.fullType,
        operation = operation,
        settlementID = itemContext.settlementID,
        marketRevision = itemContext.marketRevision,
        eventRevision = itemContext.eventRevision,
        marketCategory = itemContext.category,
        intrinsicPrice = price.intrinsicPrice,
        commercialMargin = commercialMargin,
        commercialBase = commercialBase,
        relationshipModifier = modifier,
        relationshipFactor = relationshipFactor,
        marketSupply = itemContext.marketSupply,
        marketDemand = itemContext.marketDemand,
        effectiveSupply = itemContext.effectiveSupply,
        effectiveDemand = itemContext.effectiveDemand,
        marketPressure = itemContext.marketPressure or 0,
        marketModifier = marketModifier,
        marketFactor = 1 + marketModifier,
        availabilityMultiplier = itemContext.availabilityMultiplier or 1,
        eventPriceMultiplier = eventPriceMultiplier,
        eventCount = itemContext.eventCount or 0,
        activeEventCount = itemContext.activeEventCount or 0,
        priceBeforeRounding = priceBeforeRounding,
        unitPrice = price.unitPrice,
        reason = itemContext.reason,
    }
    if auditEnabled and type(audit.RecordQuote) == "function" then
        audit.RecordQuote(fullType, operation, price)
    end
    return price
end

-- Compatibility helper for the old stock callers.  It deliberately returns
-- nil on an unavailable price; callers must carry the reason instead of
-- inventing a generic fallback amount.
function Stock.MarketPrice(fullType, inventoryItem, pricingContext)
    local quote = Stock.Quote(fullType, DTCommon.OP_BUY, inventoryItem,
        pricingContext)
    if not quote.ok then return nil, quote.reason end
    return quote.unitPrice
end

function Stock.EncodeItem(fullType, quantity)
    local item
    if InventoryItemFactory
        and type(InventoryItemFactory.CreateItem) == "function"
    then
        item = InventoryItemFactory.CreateItem(fullType)
    end
    if not item and type(instanceItem) == "function" then
        item = instanceItem(fullType)
    end
    if not item then return nil, "item_type_unavailable" end
    return Inventory.encodeItem(item, quantity)
end

local function seedQuantity(value)
    if Support and type(Support.PositiveInteger) == "function" then
        return Support.PositiveInteger(value, 1, 1000)
    end
    value = tonumber(value)
    if not value or value < 1 then return 1 end
    return math.min(1000, math.floor(value))
end

local function moduleName(fullType)
    local separator = string.find(tostring(fullType or ""), ".", 1, true)
    return separator and string.sub(fullType, 1, separator - 1) or ""
end

local function hasEntries(value)
    if type(value) ~= "table" then return false end
    for _ in pairs(value) do return true end
    return false
end

local function seedCandidates()
    local api = rawget(_G, "MarketSense")
    local known
    local defaults = {}
    local candidates = {}
    local ok
    local value
    if type(api) ~= "table"
        or type(api.GetAllKnownItems) ~= "function"
        or type(api.GetItemAvailability) ~= "function"
    then
        return candidates
    end
    if type(api.EnsureRuntimeRegistryLoaded) == "function" then
        pcall(api.EnsureRuntimeRegistryLoaded, false)
    end
    ok, known = pcall(api.GetAllKnownItems)
    if not ok or type(known) ~= "table" then return candidates end
    -- A fresh server can expose lazy definition pricing before the persisted
    -- known-item registry has been built.  Rebuild once at trader creation,
    -- never from a snapshot/window refresh, so the seed remains catalog-backed.
    if not hasEntries(known)
        and type(api.EnsureRuntimeRegistryLoaded) == "function"
    then
        pcall(api.EnsureRuntimeRegistryLoaded, true)
        ok, known = pcall(api.GetAllKnownItems)
        if not ok or type(known) ~= "table" then return candidates end
    end
    for _, value in ipairs(DTCommon.DEFAULT_STOCK or {}) do
        if type(value) == "table" and value.fullType then
            defaults[tostring(value.fullType)] = seedQuantity(value.quantity)
        end
    end
    for key, entry in pairs(known) do
        local fullType = type(entry) == "table"
            and (entry.fullType or entry.item or key) or key
        fullType = tostring(fullType or "")
        if fullType ~= "" and not isCurrency(fullType) then
            local available
            local availableOK
            local detailsQuote
            availableOK, available = pcall(api.GetItemAvailability, fullType)
            if availableOK and type(available) == "table"
                and available.status == "obtainable"
            then
                detailsQuote = Stock.Price(fullType)
                if detailsQuote.ok then
                    candidates[#candidates + 1] = {
                        fullType = fullType,
                        quantity = defaults[fullType] or 1,
                        workshop = moduleName(fullType) ~= "Base",
                        fixture = defaults[fullType] ~= nil,
                    }
                end
            end
        end
    end
    table.sort(candidates, function(left, right)
        return left.fullType < right.fullType
    end)
    return candidates
end

function Stock.New()
    local store = Inventory.createVirtualInventory({
        authority = "server",
        maxWeight = 500,
    })
    local candidates = seedCandidates()
    local selected = {}
    local selectedByType = {}
    local function addCandidate(candidate)
        if #selected >= INITIAL_STOCK_LIMIT
            or selectedByType[candidate.fullType]
        then
            return
        end
        selected[#selected + 1] = candidate
        selectedByType[candidate.fullType] = true
    end
    local index
    local candidate
    local record
    -- Keep configured fixture types when they are valid MarketSense catalog
    -- entries, but never let them bypass availability or quote validation.
    for index = 1, #candidates do
        candidate = candidates[index]
        if candidate.fixture then addCandidate(candidate) end
    end
    -- Prefer at least one non-Base installed item when the catalog provides
    -- one, so a fresh trader does not require manual Workshop registration.
    for index = 1, #candidates do
        candidate = candidates[index]
        if candidate.workshop then addCandidate(candidate) end
    end
    for index = 1, #candidates do addCandidate(candidates[index]) end
    for index = 1, #selected do
        candidate = selected[index]
        record = Stock.EncodeItem(candidate.fullType, seedQuantity(candidate.quantity))
        if record then store:add(record) end
    end
    return store
end

function Stock.SaveAndTransmit()
    Storage.Touch()
    Storage.Transmit()
end

function Stock.SnapshotItems(record, existingStore, pricingContext)
    local store = existingStore
    local reason
    local audit = tradeAudit()
    local auditEnabled = auditIsEnabled(audit)
    if not store then store, reason = Storage.LoadInventory(record) end
    if not store then return {}, reason end
    local items = {}
    local scanned = 0
    local accepted = 0
    local iterator = store:iterate()
    local itemRecord = iterator()
    while itemRecord do
        local fullType = Inventory.getItemFullType(itemRecord[1])
        if fullType then
            scanned = scanned + 1
            local buyQuote = Stock.Quote(fullType, DTCommon.OP_BUY, nil,
                pricingContext)
            local sellQuote = Stock.Quote(fullType, DTCommon.OP_SELL, nil,
                pricingContext)
            if buyQuote.ok and sellQuote.ok then
                accepted = accepted + 1
                items[#items + 1] = {
                    fullType = tostring(fullType),
                    quantity = math.max(1, math.floor(tonumber(itemRecord[2]) or 1)),
                    unitPrice = buyQuote.unitPrice,
                    sellPrice = sellQuote.unitPrice,
                    availabilityMultiplier = buyQuote.availabilityMultiplier,
                    buyExplanation = buyQuote.explanation,
                    sellExplanation = sellQuote.explanation,
                }
            end
        end
        itemRecord = iterator()
    end
    if auditEnabled and type(audit.RecordScan) == "function" then
        audit.RecordScan("trader_stock", scanned, accepted, #items)
    end
    return items
end

-- Build player-side sell rows independently from trader stock membership.  The
-- wire projection contains only primitive identity and quote data; concrete
-- InventoryItem objects never cross the client boundary.
function Stock.SnapshotSellRows(physical, pricingContext)
    local rows = {}
    local byKey = {}
    local audit = tradeAudit()
    local auditEnabled = auditIsEnabled(audit)
    local scanned = 0
    local accepted = 0
    local iterator
    local item
    if not physical or type(physical.iterate) ~= "function" then
        return rows, "inventory_unavailable"
    end
    iterator = physical:iterate()
    item = iterator()
    while item do
        scanned = scanned + 1
        local fullType = tostring(itemValue(item, "getFullType", "") or "")
        local itemID = tostring(itemValue(item, "getID", "") or "")
        if fullType ~= "" and itemID ~= "" and not isCurrency(fullType) then
            local quote = Stock.Quote(fullType, DTCommon.OP_SELL, item,
                pricingContext)
            if quote.ok then
                accepted = accepted + 1
                local quantity = math.max(1, math.floor(
                    tonumber(itemValue(item, "getCount", 1)) or 1))
                local key = fullType .. "\031" .. tostring(quote.unitPrice)
                local row = byKey[key]
                if not row then
                    row = {
                        fullType = fullType,
                        itemIDs = {},
                        itemIDQuantities = {},
                        quantity = 0,
                        unitPrice = quote.unitPrice,
                        availabilityMultiplier = quote.availabilityMultiplier,
                        explanation = quote.explanation,
                    }
                    byKey[key] = row
                    rows[#rows + 1] = row
                end
                row.itemIDs[#row.itemIDs + 1] = itemID
                row.itemIDQuantities[#row.itemIDQuantities + 1] = quantity
                row.quantity = row.quantity + quantity
            end
        end
        item = iterator()
    end
    if auditEnabled and type(audit.RecordScan) == "function" then
        audit.RecordScan("player_sell_rows", scanned, accepted, #rows)
    end
    return rows
end

return Stock

DTCommon = DTCommon or {}
DTCommon.TraderStock = DTCommon.TraderStock or {}

local Stock = DTCommon.TraderStock
local Inventory = require "PsychopatzCore/Inventory/PsychopatzInventory"
local Storage = DTCommon.Storage
local Support = DTCommon.TraderSupport

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
    local details
    local ok
    local price
    fullType = tostring(fullType or "")
    if fullType == "" then return unavailable(fullType, "item_required") end
    if isCurrency(fullType) then
        return unavailable(fullType, "currency_not_tradeable")
    end
    if type(api) ~= "table" then
        return unavailable(fullType, "marketsense_unavailable")
    end
    if inventoryItem ~= nil then
        if type(api.GetPriceDetailsForInstance) ~= "function" then
            return unavailable(fullType, "instance_price_api_unavailable")
        end
        ok, details = pcall(
            api.GetPriceDetailsForInstance,
            fullType,
            inventoryItem,
            false
        )
    else
        if type(api.GetPriceDetails) ~= "function" then
            return unavailable(fullType, "definition_price_api_unavailable")
        end
        ok, details = pcall(api.GetPriceDetails, fullType, false)
    end
    if not ok or type(details) ~= "table" then
        return unavailable(fullType, "price_details_unavailable")
    end
    price = finitePositive(details.price)
    if not price or price < 1 then
        return unavailable(fullType, "price_unavailable")
    end
    return {
        ok = true,
        status = "OK",
        fullType = fullType,
        intrinsicPrice = price,
        source = inventoryItem ~= nil and "instance" or "definition",
    }
end

function Stock.Quote(fullType, operation, inventoryItem)
    local price = Stock.Price(fullType, inventoryItem)
    local unitPrice
    operation = string.upper(tostring(operation or DTCommon.OP_BUY))
    if not price.ok then return price end
    if operation == DTCommon.OP_SELL then
        unitPrice = math.floor(price.intrinsicPrice * 0.5)
        -- This floor applies only after a valid positive MarketSense price.
        unitPrice = math.max(1, unitPrice)
    elseif operation == DTCommon.OP_BUY then
        unitPrice = price.intrinsicPrice
    else
        return unavailable(price.fullType, "operation_not_supported")
    end
    price.operation = operation
    price.unitPrice = unitPrice
    return price
end

-- Compatibility helper for the old stock callers.  It deliberately returns
-- nil on an unavailable price; callers must carry the reason instead of
-- inventing a generic fallback amount.
function Stock.MarketPrice(fullType, inventoryItem)
    local quote = Stock.Quote(fullType, DTCommon.OP_BUY, inventoryItem)
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

function Stock.New()
    local store = Inventory.createVirtualInventory({
        authority = "server",
        maxWeight = 500,
    })
    local defaults = DTCommon.DEFAULT_STOCK or {}
    local index
    local entry
    local record
    for index = 1, #defaults do
        entry = defaults[index]
        record = Stock.EncodeItem(
            entry.fullType, Support.PositiveInteger(entry.quantity, 1, 1000))
        if record then store:add(record) end
    end
    return store
end

function Stock.SaveAndTransmit()
    Storage.Touch()
    Storage.Transmit()
end

function Stock.SnapshotItems(record, existingStore)
    local store = existingStore
    local reason
    if not store then store, reason = Storage.LoadInventory(record) end
    if not store then return {}, reason end
    local items = {}
    local iterator = store:iterate()
    local itemRecord = iterator()
    while itemRecord do
        local fullType = Inventory.getItemFullType(itemRecord[1])
        if fullType then
            local buyQuote = Stock.Quote(fullType, DTCommon.OP_BUY)
            local sellQuote = Stock.Quote(fullType, DTCommon.OP_SELL)
            if buyQuote.ok and sellQuote.ok then
                items[#items + 1] = {
                    fullType = tostring(fullType),
                    quantity = math.max(1, math.floor(tonumber(itemRecord[2]) or 1)),
                    unitPrice = buyQuote.unitPrice,
                    sellPrice = sellQuote.unitPrice,
                }
            end
        end
        itemRecord = iterator()
    end
    return items
end

-- Build player-side sell rows independently from trader stock membership.  The
-- wire projection contains only primitive identity and quote data; concrete
-- InventoryItem objects never cross the client boundary.
function Stock.SnapshotSellRows(physical)
    local rows = {}
    local byKey = {}
    local iterator
    local item
    if not physical or type(physical.iterate) ~= "function" then
        return rows, "inventory_unavailable"
    end
    iterator = physical:iterate()
    item = iterator()
    while item do
        local fullType = tostring(itemValue(item, "getFullType", "") or "")
        local itemID = tostring(itemValue(item, "getID", "") or "")
        if fullType ~= "" and itemID ~= "" and not isCurrency(fullType) then
            local quote = Stock.Quote(fullType, DTCommon.OP_SELL, item)
            if quote.ok then
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
    return rows
end

return Stock

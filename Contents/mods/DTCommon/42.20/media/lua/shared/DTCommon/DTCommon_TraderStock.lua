DTCommon = DTCommon or {}
DTCommon.TraderStock = DTCommon.TraderStock or {}

local Stock = DTCommon.TraderStock
local Inventory = require "PsychopatzCore/Inventory/PsychopatzInventory"
local Storage = DTCommon.Storage
local Support = DTCommon.TraderSupport

function Stock.MarketPrice(fullType)
    local api = rawget(_G, "MarketSense")
    local ok
    local value
    local details
    -- MarketSense is an addon-owned API boundary. Keep failures explicit and
    -- use a small foundation fallback while the market rules are redesigned.
    if type(api) == "table" and type(api.GetPrice) == "function" then
        ok, value = pcall(api.GetPrice, fullType)
        if ok and type(value) == "number" and value > 0 then
            return math.max(1, math.floor(value))
        end
    end
    if type(api) == "table" and type(api.GetPriceDetails) == "function" then
        ok, details = pcall(api.GetPriceDetails, fullType)
        if ok and type(details) == "table" and details.price ~= nil then
            return math.max(1, math.floor(tonumber(details.price) or 10))
        end
    end
    return 10
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

function Stock.SnapshotItems(record)
    local store, reason = Storage.LoadInventory(record)
    if not store then return {}, reason end
    local items = {}
    local iterator = store:iterate()
    local itemRecord = iterator()
    while itemRecord do
        local fullType = Inventory.getItemFullType(itemRecord[1])
        if fullType then
            local unitPrice = Stock.MarketPrice(fullType)
            items[#items + 1] = {
                fullType = tostring(fullType),
                quantity = math.max(1, math.floor(tonumber(itemRecord[2]) or 1)),
                unitPrice = unitPrice,
                sellPrice = math.max(1, math.floor(unitPrice * 0.5)),
            }
        end
        itemRecord = iterator()
    end
    return items
end

return Stock

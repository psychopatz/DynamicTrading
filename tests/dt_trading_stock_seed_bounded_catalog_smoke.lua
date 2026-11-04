local T = require "tests/support/test"
T.addPackagePaths()

local stores = {}
local inventoryAPI = {
    createVirtualInventory = function()
        local store = { records = {} }
        function store:add(record)
            self.records[#self.records + 1] = record
            return true
        end
        stores[#stores + 1] = store
        return store
    end,
    encodeItem = function(item, quantity)
        return {
            fullType = item.fullType,
            quantity = quantity,
        }
    end,
}
package.preload[
    "PsychopatzCore/Inventory/PsychopatzInventory"
] = function()
    return inventoryAPI
end

DTCommon = {
    OP_BUY = "BUY",
    OP_SELL = "SELL",
    MONEY_FULL_TYPE = "Base.Money",
    DEFAULT_STOCK = {
        { fullType = "Base.Item0001", quantity = 2 },
        { fullType = "Base.Item0002", quantity = 2 },
    },
    Storage = {},
    TraderSupport = {
        PositiveInteger = function(value, minimum, maximum)
            value = math.floor(tonumber(value) or minimum)
            return math.max(minimum, math.min(maximum, value))
        end,
    },
    TraderStock = {},
}

local known = {}
for index = 1, 4412 do
    local prefix = index == 4000 and "WorkshopMod." or "Base."
    local fullType = prefix .. "Item" .. string.format("%04d", index)
    known[fullType] = {
        fullType = fullType,
        category = "misc",
        tags = { "misc" },
    }
end

local availabilityCalls = 0
local priceCalls = 0
MarketSense = {
    EnsureRuntimeRegistryLoaded = function() return true end,
    GetAllKnownItems = function() return known end,
    GetItemAvailability = function()
        availabilityCalls = availabilityCalls + 1
        return { status = "obtainable" }
    end,
    GetPriceDetails = function()
        priceCalls = priceCalls + 1
        return { price = 100 }
    end,
}

InventoryItemFactory = {
    CreateItem = function(fullType)
        return { fullType = fullType }
    end,
}

local Catalog = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_MarketCatalog.lua"
)
local Stock = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_TraderStock.lua"
)

local first = Stock.New()
T.equal(#first.records, 8,
    "first trader did not seed bounded 8-slot stock")
T.equal(availabilityCalls, Catalog.MAX_ITEMS,
    "first trader catalog build exceeded bounded catalog scan")
T.truthy(priceCalls <= 8,
    "first trader priced more items than initial stock limit")
local firstPriceCalls = priceCalls
local firstAvailabilityCalls = availabilityCalls

local second = Stock.New()
T.equal(#second.records, 8,
    "second trader did not seed bounded 8-slot stock")
T.equal(availabilityCalls, firstAvailabilityCalls,
    "second trader rebuilt/rescanned MarketSense catalog")
T.truthy(priceCalls - firstPriceCalls <= 8,
    "second trader repriced the MarketSense universe")
T.equal(Catalog.Diagnostics().buildCount, 1,
    "MarketSense catalog cache rebuilt per trader")

T.finish("dt_trading_stock_seed_bounded_catalog_smoke")

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
    local prefix = index == 4300 and "WorkshopMod." or "Base."
    local fullType = prefix .. "Item" .. string.format("%04d", index)
    known[fullType] = {
        fullType = fullType,
        moduleName = prefix == "Base." and "Base" or "WorkshopMod",
        sourceModId = prefix == "Base." and "Vanilla" or "WorkshopMod",
        category = "Misc",
        primary = "Misc",
        availability = {
            status = "obtainable",
            obtainable = true,
        },
    }
end

local MarketSenseStub = require "tests/support/market_sense_stub"
local priceCalls = 0
MarketSense = MarketSenseStub.New(known, {
    getPriceDetails = function()
        priceCalls = priceCalls + 1
        return { price = 100 }
    end,
})

InventoryItemFactory = {
    CreateItem = function(fullType)
        return { fullType = fullType }
    end,
}

DTCommon.MarketSenseGateway = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_MarketSenseGateway.lua"
)
local Stock = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_TraderStock.lua"
)

local first = Stock.New()
T.equal(#first.records, 8,
    "first trader did not seed bounded 8-slot stock")
T.equal(MarketSense._allKnownCalls, 0,
    "first trader requested forbidden full MarketSense catalog")
T.truthy(MarketSense._queryCalls <= 3,
    "first trader exceeded bounded canonical query count")
T.truthy(priceCalls <= 8,
    "first trader priced more items than initial stock limit")

local foundBeyondFormerCap = false
for _, record in ipairs(first.records) do
    if record.fullType == "WorkshopMod.Item4300" then
        foundBeyondFormerCap = true
        break
    end
end
T.truthy(foundBeyondFormerCap,
    "eligible modded item beyond former 4096 boundary was excluded")

local firstPriceCalls = priceCalls
local firstQueryCalls = MarketSense._queryCalls

local second = Stock.New()
T.equal(#second.records, 8,
    "second trader did not seed bounded 8-slot stock")
T.equal(MarketSense._allKnownCalls, 0,
    "second trader requested forbidden full MarketSense catalog")
T.truthy(MarketSense._queryCalls - firstQueryCalls <= 3,
    "second trader exceeded bounded canonical query count")
T.truthy(priceCalls - firstPriceCalls <= 8,
    "second trader repriced the MarketSense universe")
T.falsy(DTCommon.MarketSenseGateway.Diagnostics().persistentUniverseState,
    "DT gateway unexpectedly owns persistent catalog state")

T.finish("dt_trading_stock_seed_bounded_catalog_smoke")

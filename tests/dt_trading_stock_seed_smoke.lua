local T = require "tests/support/test"

local store = { records = {} }
function store:add(record)
    self.records[#self.records + 1] = record
    return true
end

local inventoryAPI = {
    createVirtualInventory = function() return store end,
    encodeItem = function(item, quantity)
        return { fullType = item.fullType, quantity = quantity }
    end,
}
package.preload["PsychopatzCore/Inventory/PsychopatzInventory"] =
    function() return inventoryAPI end

DTCommon = {
    OP_BUY = "BUY",
    OP_SELL = "SELL",
    MONEY_FULL_TYPE = "Base.Money",
    DEFAULT_STOCK = {
        { fullType = "Base.Bandage", quantity = 5 },
        { fullType = "Base.CannedBeans", quantity = 5 },
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

local availability = {
    ["Base.Bandage"] = "obtainable",
    ["Base.CannedBeans"] = "obtainable",
    ["WorkshopMod.RareThing"] = "obtainable",
    ["WorkshopMod.Unavailable"] = "not_obtainable",
    ["Base.Money"] = "obtainable",
}
local definitionRequests = 0
MarketSense = {
    EnsureRuntimeRegistryLoaded = function() return true end,
    GetAllKnownItems = function()
        return {
            ["Base.Bandage"] = { fullType = "Base.Bandage" },
            ["Base.CannedBeans"] = { fullType = "Base.CannedBeans" },
            ["WorkshopMod.RareThing"] = { fullType = "WorkshopMod.RareThing" },
            ["WorkshopMod.Unavailable"] = { fullType = "WorkshopMod.Unavailable" },
            ["Base.Money"] = { fullType = "Base.Money" },
        }
    end,
    GetItemAvailability = function(fullType)
        return { status = availability[fullType] }
    end,
    GetPriceDetails = function(fullType)
        definitionRequests = definitionRequests + 1
        if fullType == "WorkshopMod.Unavailable" then return { price = 100 } end
        return { price = 100 }
    end,
}

InventoryItemFactory = {
    CreateItem = function(fullType) return { fullType = fullType } end,
}

local Stock = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_TraderStock.lua"
)

local seeded = Stock.New()
T.equal(seeded, store, "stock seed uses one Core virtual inventory")
T.equal(#store.records, 3,
    "seed is bounded and includes configured plus Workshop candidates")
T.equal(store.records[1].fullType, "Base.Bandage",
    "valid configured fixture is seeded first")
T.equal(store.records[2].fullType, "Base.CannedBeans",
    "second valid configured fixture is seeded")
T.equal(store.records[3].fullType, "WorkshopMod.RareThing",
    "eligible Workshop item is seeded without DT registration")
T.equal(store.records[3].quantity, 1,
    "non-fixture seed quantity is deterministic")
T.equal(definitionRequests, 3,
    "only eligible non-currency candidates are valued")

T.finish("dt_trading_stock_seed")

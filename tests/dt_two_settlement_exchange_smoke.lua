local T = require "tests/support/test"
local loadSource = T.load

local function cloneRecord(record, quantity)
    return {
        [1] = record[1],
        [2] = quantity == nil and record[2] or quantity,
    }
end

local function newStore(rows)
    local store = { rows = {} }
    for index = 1, #(rows or {}) do
        store.rows[#store.rows + 1] = cloneRecord(rows[index])
    end

    function store:iterate()
        local index = 0
        return function()
            index = index + 1
            local record = self.rows[index]
            return record and cloneRecord(record) or nil
        end
    end

    function store:count(fullType)
        local typeID = ({
            ["Base.CannedBeans"] = 1,
            ["Base.Unrelated"] = 2,
        })[fullType]
        local total = 0
        for index = 1, #self.rows do
            if self.rows[index][1] == typeID then
                total = total + self.rows[index][2]
            end
        end
        return total
    end

    function store:remove(fullType, quantity)
        local typeID = ({
            ["Base.CannedBeans"] = 1,
            ["Base.Unrelated"] = 2,
        })[fullType]
        local remaining = math.floor(tonumber(quantity) or 0)
        local removed = {}
        if self:count(fullType) < remaining then
            return false, "insufficient_quantity"
        end
        for index = #self.rows, 1, -1 do
            local record = self.rows[index]
            if record[1] == typeID and remaining > 0 then
                local take = math.min(remaining, record[2])
                removed[#removed + 1] = cloneRecord(record, take)
                record[2] = record[2] - take
                remaining = remaining - take
                if record[2] <= 0 then table.remove(self.rows, index) end
            end
        end
        return true, removed
    end

    function store:add(record)
        for index = 1, #self.rows do
            if self.rows[index][1] == record[1] then
                self.rows[index][2] = self.rows[index][2] + record[2]
                return true
            end
        end
        self.rows[#self.rows + 1] = cloneRecord(record)
        return true
    end

    return store
end

local function near(actual, expected, label)
    T.truthy(math.abs(actual - expected) < 0.000001, label)
end

local modData = {}
local transmissions = {}
local authority = true
local record = {
    v = 0,
    b = 20,
    i = { rows = { { [1] = 2, [2] = 3 } } },
}

local Inventory = {
    getItemFullType = function(typeID)
        if typeID == 1 then return "Base.CannedBeans" end
        if typeID == 2 then return "Base.Unrelated" end
        return nil
    end,
}
Inventory.Serializer = {
    serialize = function(store)
        local rows = {}
        local iterator = store:iterate()
        local item = iterator()
        while item do
            rows[#rows + 1] = cloneRecord(item)
            item = iterator()
        end
        return { rows = rows }
    end,
    deserialize = function(payload)
        return newStore(payload and payload.rows or {})
    end,
}
Inventory.createVirtualInventory = function() return newStore() end

DTCommon = {
    MODDATA_KEY = "DTCommon.Traders",
    MARKET_MODDATA_KEY = "DTCommon.SettlementMarkets",
    OP_BUY = "BUY",
    OP_SELL = "SELL",
    MONEY_FULL_TYPE = "Base.Money",
    MarketSchema = loadSource(
        "DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua"),
    MarketProfiles = loadSource(
        "DTCommon", "shared", "DTCommon/DTCommon_MarketProfiles.lua"),
}
PsychopatzCore = {
    RuntimeRole = { AllowsServerCode = function() return authority end },
}
ModData = {
    getOrCreate = function(key)
        modData[key] = modData[key] or {}
        return modData[key]
    end,
    transmit = function(key) transmissions[#transmissions + 1] = key end,
}
PNC = {
    Communities = {
        Get = function(id)
            if id == "settlement_a" or id == "settlement_b" then
                return { id = id, status = "active" }
            end
            return nil
        end,
    },
}

local savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    error("unexpected module in two-settlement storage: " .. tostring(moduleName))
end
local Storage = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
require = savedRequire
DTCommon.Storage = Storage
local Registry = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")
DTCommon.SettlementMarket = Registry

MarketSense = {
    GetAllKnownItems = function()
        return {
            ["Base.CannedBeans"] = {
                fullType = "Base.CannedBeans",
                category = "Food",
                availability = { status = "obtainable" },
            },
        }
    end,
    GetTags = function(fullType)
        if fullType == "Base.CannedBeans" then
            return { category = "Food", tags = { "food" } }
        end
        return nil
    end,
}
local Catalog = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketCatalog.lua")
Catalog.Reset()
DTCommon.MarketCatalog = Catalog
DTCommon.TraderSupport = {}
DTCommon.CoreActorPolicy = {
    PriceContext = function() return { relationshipModifier = 0 } end,
}
DTCommon.TraderStock = {
    Quote = function(_, operation)
        return { ok = true, unitPrice = operation == "BUY" and 10 or 5 }
    end,
    EncodeItem = function(fullType, quantity)
        if fullType == "Base.CannedBeans" then
            return { [1] = 1, [2] = quantity }
        end
        return nil, "item_type_unavailable"
    end,
    SaveAndTransmit = function() end,
}
DTCommon.TraderService = {
    GetRecord = function() return record end,
}

local savedExchangeRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventoryConstants" then
        return { TYPE_ID = 1, QUANTITY = 2 }
    end
    if moduleName == "DTCommon/DTCommon_SettlementExchangePlan" then
        return loadSource(
            "DTCommon", "shared",
            "DTCommon/DTCommon_SettlementExchangePlan.lua")
    end
    if moduleName == "DTCommon/DTCommon_SettlementExchangeCandidates" then
        return loadSource(
            "DTCommon", "shared",
            "DTCommon/DTCommon_SettlementExchangeCandidates.lua")
    end
    error("unexpected module in two-settlement exchange: " .. tostring(moduleName))
end
local Exchange = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementExchange.lua")
require = savedExchangeRequire

local farm, farmCreated = Registry.GetOrCreate("settlement_a", "farm")
local military, militaryCreated = Registry.GetOrCreate("settlement_b", "military")
local catalogReady, catalogReason = Catalog.Ensure()
T.truthy(catalogReady, catalogReason)
T.truthy(farm, "farm market is created")
T.truthy(military, "military market is created")
T.equal(farmCreated, true, "farm market creation is persisted")
T.equal(militaryCreated, true, "military market creation is persisted")
T.equal(Catalog.Diagnostics().indexedCount, 1,
    "exchange catalog contains only the bounded MarketSense item")

local arrivedFarm, farmReason = Exchange.Execute(
    "trader:two-settlement", "settlement_a", { now = 10 })
T.truthy(arrivedFarm, farmReason)
T.equal(arrivedFarm.changed, true, "farm visit acquires food")
T.equal(record.v, 1, "farm visit increments stock once")
T.equal(record.b, 10, "farm acquisition uses the trader budget")
local afterFarm = Storage.LoadInventory(record)
T.equal(afterFarm:count("Base.CannedBeans"), 1,
    "farm visit adds one food unit")
T.equal(afterFarm:count("Base.Unrelated"), 3,
    "farm visit preserves unrelated stock")
local farmAfter = Registry.Get("settlement_a")
near(farmAfter.categories.Food.supply, 0.8,
    "farm visit lowers local food surplus")
near(farmAfter.categories.Food.demand, 0.27,
    "farm visit raises local food demand")

local arrivedMilitary, militaryReason = Exchange.Execute(
    "trader:two-settlement", "settlement_b", { now = 20 })
T.truthy(arrivedMilitary, militaryReason)
T.equal(arrivedMilitary.changed, true, "military visit disposes carried food")
T.equal(record.v, 2, "military visit increments stock once")
T.equal(record.b, 15, "military disposal credits the trader")
local afterMilitary = Storage.LoadInventory(record)
T.equal(afterMilitary:count("Base.CannedBeans"), 0,
    "military visit disposes the carried food")
T.equal(afterMilitary:count("Base.Unrelated"), 3,
    "military visit preserves unrelated stock")
local militaryAfter = Registry.Get("settlement_b")
near(militaryAfter.categories.Food.supply, 0.4,
    "military visit raises local food supply")
near(militaryAfter.categories.Food.demand, 0.73,
    "military visit lowers local food demand")

local savedReloadRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    error("unexpected module during two-settlement reload: " .. tostring(moduleName))
end
local reloadedStorage = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
DTCommon.Storage = reloadedStorage
local reloadedRegistry = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")
require = savedReloadRequire
DTCommon.SettlementMarket = reloadedRegistry
local reloadedFarm = reloadedRegistry.Get("settlement_a")
local reloadedMilitary = reloadedRegistry.Get("settlement_b")
T.truthy(reloadedFarm, "farm market survives a storage reload")
T.truthy(reloadedMilitary, "military market survives a storage reload")
near(reloadedFarm.categories.Food.supply, farmAfter.categories.Food.supply,
    "reloaded farm pressure remains exact")
near(reloadedMilitary.categories.Food.supply,
    militaryAfter.categories.Food.supply,
    "reloaded military pressure remains exact")
local reloadedStock = reloadedStorage.LoadInventory(record)
T.equal(reloadedStock:count("Base.CannedBeans"), 0,
    "reloaded trader stock keeps the exchanged result")
T.equal(reloadedStock:count("Base.Unrelated"), 3,
    "reloaded trader stock keeps unrelated goods")
T.truthy(#transmissions > 0, "market persistence transmitted both profiles")

T.finish("dt_two_settlement_exchange")

local T = require "tests/support/test"
local loadSource = T.load

local TYPE_BY_ID = {
    [1] = "Base.CannedBeans",
    [2] = "Base.Unrelated",
}
local ID_BY_TYPE = {
    ["Base.CannedBeans"] = 1,
    ["Base.Unrelated"] = 2,
}

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
        local typeID = ID_BY_TYPE[fullType]
        local total = 0
        for index = 1, #self.rows do
            if self.rows[index][1] == typeID then
                total = total + self.rows[index][2]
            end
        end
        return total
    end

    function store:remove(fullType, quantity)
        local typeID = ID_BY_TYPE[fullType]
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

local authority = true
local modData = {}
local transmissions = {}
local travelStarts = {}
local registered = {}
local traderID = "trader:two-settlement-lifecycle"
local npcID = "npc:two-settlement-lifecycle"
local record = {
    v = 0,
    b = 200,
    s = "AWAY",
    p = npcID,
    g = "faction:caravan",
    i = { rows = { { [1] = 2, [2] = 3 } } },
}

local Inventory = {
    getItemFullType = function(typeID) return TYPE_BY_ID[typeID] end,
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
    EVENT_MODDATA_KEY = "DTCommon.MarketEvents",
    OP_BUY = "BUY",
    OP_SELL = "SELL",
    MONEY_FULL_TYPE = "Base.Money",
    DEFAULT_STOCK = {},
}
PsychopatzCore = {
    RuntimeRole = { AllowsServerCode = function() return authority end },
}
modData[DTCommon.MODDATA_KEY] = {
    t = { [traderID] = record },
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
            if id == "settlement_a" then
                return { id = id, status = "active", siteID = "site:a" }
            end
            if id == "settlement_b" then
                return { id = id, status = "active", siteID = "site:b" }
            end
            return nil
        end,
        GetForFaction = function(id)
            if id == "faction:caravan" then
                return {
                    { id = "settlement_a", status = "active" },
                }
            end
            return {}
        end,
    },
    API = {
        Travel = {
            RegisterArrivalHandler = function(actionType, handler)
                registered[actionType] = handler
                return true
            end,
            Start = function(physicalNPC, request)
                travelStarts[#travelStarts + 1] = {
                    npcID = physicalNPC,
                    request = request,
                }
                return { journeyId = "journey:started" }, "started"
            end,
        },
    },
    Travel = { Arrivals = { StrictActionTypes = {} } },
}

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
    GetPriceDetails = function(fullType)
        if fullType == "Base.CannedBeans" then return { price = 100 } end
        return nil
    end,
}

local savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    error("unexpected module in logistics storage: " .. tostring(moduleName))
end
DTCommon.MarketSchema = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua")
DTCommon.MarketProfiles = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketProfiles.lua")
local Storage = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
require = savedRequire
DTCommon.Storage = Storage

DTCommon.TraderSupport = {}
local Support = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderSupport.lua")
DTCommon.TraderSupport = Support
local Policy = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
DTCommon.CoreActorPolicy = Policy

local Catalog = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketCatalog.lua")
Catalog.Reset()
DTCommon.MarketCatalog = Catalog
local Registry = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")
DTCommon.SettlementMarket = Registry
local Pricing = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketPricing.lua")
DTCommon.MarketPricing = Pricing

DTCommon.TraderStock = {}
savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    error("unexpected module in logistics stock: " .. tostring(moduleName))
end
local Stock = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderStock.lua")
require = savedRequire
DTCommon.TraderStock = Stock
Stock.EncodeItem = function(fullType, quantity)
    local typeID = ID_BY_TYPE[fullType]
    if not typeID then return nil, "item_type_unavailable" end
    return { [1] = typeID, [2] = quantity }
end
Stock.SaveAndTransmit = function() end

DTCommon.TraderService = {}
savedRequire = require
require = function(moduleName)
    if moduleName == "DTCommon/DTCommon_CoreActorPolicy" then
        return Policy
    end
    error("unexpected module in logistics registry: " .. tostring(moduleName))
end
local TraderRegistry = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderRegistry.lua")
require = savedRequire
DTCommon.TraderService = TraderRegistry

savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventoryConstants" then
        return { TYPE_ID = 1, QUANTITY = 2 }
    end
    if moduleName == "PsychopatzCore/Economy/PsychopatzCurrency" then
        return {}
    end
    if moduleName == "DTCommon/DTCommon_CoreActorPolicy" then
        return Policy
    end
    error("unexpected module in logistics service: " .. tostring(moduleName))
end
local Service = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderService.lua")
require = savedRequire
DTCommon.TraderService = Service

savedRequire = require
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
    error("unexpected module in logistics exchange: " .. tostring(moduleName))
end
local Exchange = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementExchange.lua")
require = savedRequire
DTCommon.SettlementExchange = Exchange

local farm, farmCreated = Registry.GetOrCreate("settlement_a", "farm")
local military, militaryCreated = Registry.GetOrCreate(
    "settlement_b", "military")
local catalogReady, catalogReason = Catalog.Ensure()
T.truthy(catalogReady, catalogReason)
T.truthy(farm, "farm market is created")
T.truthy(military, "military market is created")
T.equal(farmCreated, true, "farm market creation is persisted")
T.equal(militaryCreated, true, "military market creation is persisted")
T.equal(Catalog.Diagnostics().indexedCount, 1,
    "logistics catalog is bounded to the MarketSense item")

local farmBefore = Registry.Get("settlement_a")
local farmBeforeQuote = Stock.Quote(
    "Base.CannedBeans", DTCommon.OP_BUY, nil,
    Pricing.BuildContext(record, nil, { settlementID = "settlement_a" }))
local militaryBefore = Registry.Get("settlement_b")
local militaryBeforeQuote = Stock.Quote(
    "Base.CannedBeans", DTCommon.OP_BUY, nil,
    Pricing.BuildContext(record, nil, { settlementID = "settlement_b" }))
T.truthy(farmBeforeQuote.ok, "farm quote resolves from intrinsic value")
T.truthy(militaryBeforeQuote.ok, "military quote resolves from intrinsic value")
T.truthy(militaryBeforeQuote.unitPrice > farmBeforeQuote.unitPrice,
    "shortage settlement quote is locally higher before logistics")

DTHoomans = {}
local Settlement = loadSource(
    "DTHoomans", "server", "DTHoomans/DTHoomans_SettlementVisit.lua")
local handler = registered[Settlement.ARRIVAL_ACTION]
T.truthy(handler, "Hoomans registers the settlement arrival action")
T.truthy(PNC.Travel.Arrivals.StrictActionTypes[Settlement.ARRIVAL_ACTION],
    "settlement arrival remains strict")

local startedA, startedAReason = Settlement.StartTraderTravel(
    traderID, "settlement_a", {
        destination = { x = 10, y = 20, z = 0 },
        arrivalAction = { visitID = "arrival:a" },
    })
T.truthy(startedA, startedAReason)
T.equal(travelStarts[1].npcID, npcID,
    "farm travel delegates the physical Hoomans NPC")
T.equal(travelStarts[1].request.arrivalAction.settlementID, "settlement_a",
    "farm travel carries the canonical settlement ID")
T.equal(travelStarts[1].request.arrivalAction.exchange, true,
    "farm travel enables partial exchange")

local handledA, handledAReason = handler(
    { id = npcID },
    { state = "arrived", journeyId = "journey:a", arrivedWorldHour = 10 },
    travelStarts[1].request.arrivalAction)
T.truthy(handledA, handledAReason)
T.equal(handledAReason, "settlement_visit",
    "farm arrival reaches the DT settlement visit seam")
local afterFarmRecord = Service.GetRecord(traderID)
local afterFarmStock = Storage.LoadInventory(afterFarmRecord)
local farmAfter = Registry.Get("settlement_a")
T.equal(afterFarmRecord.v, 1, "farm arrival commits exactly one stock version")
T.equal(afterFarmStock:count("Base.CannedBeans"), 1,
    "farm surplus adds one carried food unit")
T.equal(afterFarmStock:count("Base.Unrelated"), 3,
    "farm exchange preserves unrelated persistent stock")
T.equal(afterFarmRecord.ca.lastSettlementID, "settlement_a",
    "farm arrival persists the canonical settlement identity")
T.equal(afterFarmRecord.ca.visitCount, 1,
    "farm arrival records one lifecycle visit")
T.truthy(farmAfter.categories.Food.supply
    < farmBefore.categories.Food.supply,
    "farm acquisition lowers local food supply")
T.truthy(farmAfter.categories.Food.demand
    > farmBefore.categories.Food.demand,
    "farm acquisition raises local food demand")
T.truthy(farmAfter.revision > farmBefore.revision,
    "farm acquisition commits a market revision")
local farmAfterQuote = Stock.Quote(
    "Base.CannedBeans", DTCommon.OP_BUY, nil,
    Pricing.BuildContext(afterFarmRecord, nil,
        { settlementID = "settlement_a" }))
T.truthy(farmAfterQuote.unitPrice > farmBeforeQuote.unitPrice,
    "later farm quote reflects local acquisition pressure")

local activeStorage = DTCommon.Storage
local activeMarket = DTCommon.SettlementMarket
savedRequire = require
require = function(moduleName)
    if moduleName == "PsychopatzCore/Inventory/PsychopatzInventory" then
        return Inventory
    end
    error("unexpected module during logistics reload: " .. tostring(moduleName))
end
local reloadedStorage = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
require = savedRequire
DTCommon.Storage = reloadedStorage
DTCommon.SettlementMarket = nil
local reloadedMarket = loadSource(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")
local reloadedRecord = reloadedStorage.GetData().t[traderID]
local reloadedStock = reloadedStorage.LoadInventory(reloadedRecord)
local reloadedFarm = reloadedMarket.Get("settlement_a")
T.equal(reloadedStock:count("Base.CannedBeans"), 1,
    "reloaded stock keeps the farm acquisition")
T.equal(reloadedStock:count("Base.Unrelated"), 3,
    "reloaded stock keeps unrelated goods")
near(reloadedFarm.categories.Food.supply,
    farmAfter.categories.Food.supply,
    "reloaded farm pressure is exact")
T.equal(reloadedRecord.v, afterFarmRecord.v,
    "reloaded stock version is exact")
DTCommon.Storage = activeStorage
DTCommon.SettlementMarket = activeMarket

local militaryAfterReload = Registry.Get("settlement_b")
local militaryBeforeQuoteAgain = Stock.Quote(
    "Base.CannedBeans", DTCommon.OP_BUY, nil,
    Pricing.BuildContext(Service.GetRecord(traderID), nil,
        { settlementID = "settlement_b" }))
T.equal(militaryAfterReload.revision, militaryBefore.revision,
    "military market remains unchanged before logistics")
T.equal(militaryBeforeQuoteAgain.unitPrice, militaryBeforeQuote.unitPrice,
    "military quote remains local and unchanged before disposal")

local startedB, startedBReason = Settlement.StartTraderTravel(
    traderID, "settlement_b", {
        destination = { x = 30, y = 40, z = 0 },
        arrivalAction = { visitID = "arrival:b" },
    })
T.truthy(startedB, startedBReason)
T.equal(travelStarts[2].npcID, npcID,
    "military travel keeps the same physical trader identity")
T.equal(travelStarts[2].request.arrivalAction.settlementID, "settlement_b",
    "military travel carries the canonical settlement ID")

local handledB, handledBReason = handler(
    { id = npcID },
    { state = "arrived", journeyId = "journey:b", arrivedWorldHour = 20 },
    travelStarts[2].request.arrivalAction)
T.truthy(handledB, handledBReason)
T.equal(handledBReason, "settlement_visit",
    "military arrival reaches the same DT visit seam")
local afterMilitaryRecord = Service.GetRecord(traderID)
local afterMilitaryStock = Storage.LoadInventory(afterMilitaryRecord)
local militaryAfter = Registry.Get("settlement_b")
T.equal(afterMilitaryRecord.v, 2,
    "military arrival commits one additional stock version")
T.equal(afterMilitaryStock:count("Base.CannedBeans"), 0,
    "military shortage disposes the carried food")
T.equal(afterMilitaryStock:count("Base.Unrelated"), 3,
    "military disposal preserves unrelated persistent stock")
T.equal(afterMilitaryRecord.ca.lastSettlementID, "settlement_b",
    "military arrival updates the canonical settlement identity")
T.equal(afterMilitaryRecord.ca.visitCount, 2,
    "two distinct arrival IDs record two visits")
T.truthy(militaryAfter.categories.Food.supply
    > militaryBefore.categories.Food.supply,
    "military disposal raises local food supply")
T.truthy(militaryAfter.categories.Food.demand
    < militaryBefore.categories.Food.demand,
    "military disposal lowers local food demand")
T.truthy(militaryAfter.revision > militaryBefore.revision,
    "military disposal commits a market revision")
local militaryAfterQuote = Stock.Quote(
    "Base.CannedBeans", DTCommon.OP_BUY, nil,
    Pricing.BuildContext(afterMilitaryRecord, nil,
        { settlementID = "settlement_b" }))
T.truthy(militaryAfterQuote.unitPrice < militaryBeforeQuote.unitPrice,
    "later military quote reflects local disposal pressure")

local duplicateVersion = afterMilitaryRecord.v
local duplicateBudget = afterMilitaryRecord.b
local duplicateRevision = militaryAfter.revision
local duplicate, duplicateReason = handler(
    { id = npcID },
    { state = "arrived", journeyId = "journey:b", arrivedWorldHour = 20 },
    travelStarts[2].request.arrivalAction)
T.truthy(duplicate, "replayed arrival is handled idempotently")
T.equal(duplicateReason, "duplicate_visit",
    "replayed arrival returns the duplicate visit reason")
T.equal(Service.GetRecord(traderID).v, duplicateVersion,
    "duplicate arrival does not increment stock version")
T.equal(Service.GetRecord(traderID).b, duplicateBudget,
    "duplicate arrival does not repeat the transaction")
T.equal(Registry.Get("settlement_b").revision, duplicateRevision,
    "duplicate arrival does not increment market revision")
local finalStock = Storage.LoadInventory(Service.GetRecord(traderID))
T.equal(finalStock:count("Base.CannedBeans"), 0,
    "duplicate arrival does not recreate disposed food")
T.equal(finalStock:count("Base.Unrelated"), 3,
    "duplicate arrival keeps exact persistent stock")
T.truthy(#transmissions > 0, "logistics persistence transmitted ModData")

T.finish("dt_settlement_logistics")

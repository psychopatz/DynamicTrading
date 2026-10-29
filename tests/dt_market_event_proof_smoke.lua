local T = require "tests/support/test"

package.preload["PsychopatzCore/Inventory/PsychopatzInventory"] =
    function() return {} end
package.preload["PsychopatzCore/Inventory/PsychopatzInventoryConstants"] =
    function() return {} end

DTCommon = {}
PsychopatzCore = {
    RuntimeRole = {
        AllowsServerCode = function() return true end,
    },
}

T.load("DTCommon", "shared", "DTCommon/DTCommon_Constants.lua")
local Schema = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua")
local Storage = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
local Events = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEvents.lua")
local Definitions = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEventDefinitions.lua")
local Policy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")

DTCommon.MarketSchema = Schema
DTCommon.Storage = Storage
DTCommon.MarketEvents = Events
DTCommon.TraderSupport = {}
DTCommon.SettlementMarket = {
    Get = function()
        return {
            revision = 1,
            categories = { Food = { supply = 0.5, demand = 0.5 } },
        }
    end,
}
DTCommon.MarketCatalog = {
    Get = function(fullType)
        if fullType == "Base.CannedBeans"
            or fullType == "Base.Bandage"
        then
            return { fullType = fullType, category = "Food" }
        end
        return nil
    end,
    GetCandidates = function()
        return { "Base.CannedBeans", "Base.Bandage" }
    end,
}
MarketSense = {
    GetPriceDetails = function() return { price = 100 } end,
    GetPriceDetailsForInstance = function() return { price = 100 } end,
}
local Pricing = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketPricing.lua")
local Stock = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderStock.lua")
DTCommon.TraderStock = Stock
DTCommon.SettlementExchange = {
    MAX_OPERATIONS = 8,
    MAX_UNITS = 8,
    MAX_ACQUISITION_UNITS = 4,
    SUPPLY_DELTA_PER_UNIT = 0.05,
    DEMAND_DELTA_PER_UNIT = 0.02,
}
local Candidates = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementExchangeCandidates.lua")

local record = {
    g = "faction-proof",
    ca = Policy.New({ lastSettlementID = "settlement-proof" }),
    stockSentinel = "unchanged",
}
local shortage = Definitions.Instantiate(
    Definitions.FOOD_SHORTAGE,
    "proof:food-shortage",
    { kind = "settlement", id = "settlement-proof" },
    10,
    20
)
local registeredShortage, shortageReason = Events.Register(
    shortage.eventID, shortage)
T.truthy(registeredShortage, shortageReason)

local shortageContext = Pricing.BuildContext(record, nil, { now = 15 })
local shortageQuote = Stock.Quote(
    "Base.CannedBeans", DTCommon.OP_BUY, nil, shortageContext)
T.equal(shortageQuote.intrinsicPrice, 100,
    "shortage proof keeps MarketSense intrinsic value")
T.equal(shortageQuote.unitPrice, 134,
    "food shortage raises price through generic event modifiers")
T.equal(shortageQuote.availabilityMultiplier, 0.65,
    "food shortage lowers generic availability")

local function newAcquisitionPlan()
    return {
        market = {
            categories = { Food = { supply = 0.8, demand = 0.1 } },
        },
        budgetBefore = 500,
        saleTotal = 0,
        operationCount = 0,
        unitCount = 0,
        maxOperations = 8,
        maxUnits = 8,
        purchaseTotal = 0,
        operations = {},
        disposals = {},
        deltas = {},
    }
end

local shortagePlan = newAcquisitionPlan()
Candidates.PlanAcquisitions(shortagePlan, shortageContext)
T.equal(#shortagePlan.operations, 1,
    "shortage availability bounds the candidate set deterministically")
T.equal(shortagePlan.operations[1].availabilityMultiplier, 0.65,
    "exchange operation carries the server availability factor")
T.equal(record.stockSentinel, "unchanged",
    "planning an event never mutates trader stock")

local removedShortage, removeShortageReason = Events.Remove(
    "proof:food-shortage")
T.truthy(removedShortage, removeShortageReason)
local surplus = Definitions.Instantiate(
    Definitions.AGRICULTURAL_SURPLUS,
    "proof:agricultural-surplus",
    { kind = "settlement", id = "settlement-proof" },
    10,
    20
)
local registeredSurplus, surplusReason = Events.Register(
    surplus.eventID, surplus)
T.truthy(registeredSurplus, surplusReason)

local surplusContext = Pricing.BuildContext(record, nil, { now = 15 })
local surplusQuote = Stock.Quote(
    "Base.CannedBeans", DTCommon.OP_BUY, nil, surplusContext)
T.equal(surplusQuote.intrinsicPrice, 100,
    "surplus proof keeps the same intrinsic item value")
T.equal(surplusQuote.unitPrice, 75,
    "agricultural surplus lowers price through the same pipeline")
T.equal(surplusQuote.availabilityMultiplier, 1.35,
    "agricultural surplus raises generic availability")

local surplusPlan = newAcquisitionPlan()
Candidates.PlanAcquisitions(surplusPlan, surplusContext)
T.equal(#surplusPlan.operations, 2,
    "surplus availability exposes the bounded candidate set")
T.equal(record.stockSentinel, "unchanged",
    "surplus planning still does not mutate trader stock")

local expiredContext = Pricing.BuildContext(record, nil, { now = 20 })
local expiredQuote = Stock.Quote(
    "Base.CannedBeans", DTCommon.OP_BUY, nil, expiredContext)
T.equal(expiredQuote.unitPrice, 100,
    "proof event expiry restores the neutral quote")
T.equal(expiredQuote.activeEventCount, 0,
    "expired proof event is absent from effective context")

T.finish("dt_market_event_proof")

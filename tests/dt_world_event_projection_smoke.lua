local T = require "tests/support/test"
T.addPackagePaths()

package.preload["PsychopatzCore/Inventory/PsychopatzInventory"] =
    function() return {} end
package.preload["PsychopatzCore/Inventory/PsychopatzInventoryConstants"] =
    function() return {} end
package.preload["PsychopatzCore/Economy/PsychopatzCurrency"] =
    function() return {} end

local modData = {}
ModData = {
    getOrCreate = function(key)
        modData[key] = modData[key] or {}
        return modData[key]
    end,
    transmit = function() return true end,
}

DTCommon = {}
DTHoomans = {}
PsychopatzCore = {
    RuntimeRole = {
        AllowsServerCode = function() return true end,
    },
}

local ScopedWorldEvents = require
    "PsychopatzCore/WorldEvents/PsychopatzScopedWorldEvents"
PsychopatzCore.ScopedWorldEvents = ScopedWorldEvents
ScopedWorldEvents.Reset()

local SurvivorWorld = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorld"
local worldRegistry = assert(SurvivorWorld.ActivateRuntime({ worldSeed = 101 }))

assert(worldRegistry:UpsertFaction({
    id = "faction_traders",
    name = "Traders",
    archetypeID = "trader",
}))
assert(worldRegistry:UpsertCommunity({
    id = "comm_rosewood",
    factionID = "faction_traders",
    name = "Rosewood Haven",
    regionID = "region_south",
    home = { x = 8000, y = 11500, z = 0, radius = 30 },
}))
assert(worldRegistry:UpsertCommunity({
    id = "comm_muldraugh",
    factionID = "faction_traders",
    name = "Muldraugh Outpost",
    regionID = "region_central",
    home = { x = 10600, y = 10000, z = 0, radius = 30 },
}))
assert(worldRegistry:UpsertCommunity({
    id = "comm_westpoint",
    factionID = "faction_traders",
    name = "West Point Camp",
    regionID = "region_north",
    home = { x = 11900, y = 6900, z = 0, radius = 30 },
}))

T.load("DTCommon", "shared", "DTCommon/DTCommon_Constants.lua")
DTCommon.MarketSchema = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketSchema.lua")
DTCommon.MarketProfiles = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketProfiles.lua")
DTCommon.Storage = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_Storage.lua")
DTCommon.SettlementDirectory = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementDirectory.lua")
T.load("DTCommon", "server", "DTCommon/DTCommon_CoreSettlementDirectoryProvider.lua")
DTCommon.CoreActorPolicy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
DTCommon.MarketEvents = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEvents.lua")
DTCommon.MarketEventDefinitions = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEventDefinitions.lua")
DTCommon.SettlementMarket = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementMarket.lua")
DTCommon.MarketEventProducer = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_MarketEventProducer.lua")

DTCommon.MarketSenseGateway = {
    Get = function(fullType)
        if fullType == "Base.CannedBeans" then
            return { fullType = fullType, category = "Food" }
        end
        if fullType == "Base.Pistol" then
            return { fullType = fullType, category = "Weapon" }
        end
        if fullType == "Base.Bandage" then
            return { fullType = fullType, category = "Medical" }
        end
        return nil
    end,
}
MarketSense = {
    GetPriceDetails = function() return { price = 100 } end,
    GetPriceDetailsForInstance = function() return { price = 100 } end,
}

local Pricing = T.load("DTCommon", "shared", "DTCommon/DTCommon_MarketPricing.lua")
local Stock = T.load("DTCommon", "shared", "DTCommon/DTCommon_TraderStock.lua")
local Projection = T.load(
    "DTHoomans", "shared", "DTHoomans/DTHoomans_WorldEventProjection.lua")
local Mobility = T.load(
    "DTHoomans", "server", "DTHoomans/DTHoomans_CommercialMobility.lua")

-- 1. regionID flows through DTCommon_CoreSettlementDirectoryProvider
local rosewood = DTCommon.SettlementDirectory.Get("comm_rosewood")
T.truthy(rosewood, "Core settlement descriptor resolves via Directory")
T.equal(rosewood.regionID, "region_south",
    "regionID flows through DTCommon_CoreSettlementDirectoryProvider")

local listed = DTCommon.SettlementDirectory.List()
local listedRosewood
for index = 1, #listed do
    if listed[index].settlementID == "comm_rosewood" then
        listedRosewood = listed[index]
        break
    end
end
T.truthy(listedRosewood, "comm_rosewood appears in Directory.List()")
T.equal(listedRosewood.regionID, "region_south",
    "regionID flows through Directory.List()")

-- Seed baseline markets for settlements
T.truthy(DTCommon.SettlementMarket.GetOrCreate("comm_rosewood", "default"))
T.truthy(DTCommon.SettlementMarket.GetOrCreate("comm_muldraugh", "default"))
T.truthy(DTCommon.SettlementMarket.GetOrCreate("comm_westpoint", "default"))

local rosewoodRecord = {
    g = "faction_traders",
    ca = DTCommon.CoreActorPolicy.New({ currentSettlementID = "comm_rosewood" }),
}
local muldraughRecord = {
    g = "faction_traders",
    ca = DTCommon.CoreActorPolicy.New({ currentSettlementID = "comm_muldraugh" }),
}

local baselinePrice = Stock.Quote(
    "Base.CannedBeans", DTCommon.OP_BUY, nil,
    Pricing.BuildContext(rosewoodRecord, nil, { now = 10 })
).unitPrice

-- 2. food_crisis projects into DTCommon.MarketEvents under hoomans-world-event:
--    with lower Food supply & higher price pressure (region-scoped via regionID)
assert(ScopedWorldEvents.Register({
    eventID = "ev_south_food_crisis",
    eventType = "food_crisis",
    scope = "region",
    scopeID = "region_south",
    startsAt = 5,
    endsAt = 50,
    severity = 0.8,
    source = "hoomans-world-event",
    effects = {
        foodAvailabilityPressure = 0.8,
        tradeScarcity = 0.3,
    },
}))

local projectedFood = DTCommon.MarketEvents.Get("hoomans-world-event:ev_south_food_crisis")
T.truthy(projectedFood, "food_crisis projected under hoomans-world-event: prefix")
T.equal(projectedFood.scope.kind, "region", "region scope preserved on projection")
T.equal(projectedFood.scope.id, "region_south", "region scopeID preserved on projection")

local rosewoodFoodCtx = Pricing.GetItemContext(
    "Base.CannedBeans", Pricing.BuildContext(rosewoodRecord, nil, { now = 10 }))
local muldraughFoodCtx = Pricing.GetItemContext(
    "Base.CannedBeans", Pricing.BuildContext(muldraughRecord, nil, { now = 10 }))
local crisisPrice = Stock.Quote(
    "Base.CannedBeans", DTCommon.OP_BUY, nil,
    Pricing.BuildContext(rosewoodRecord, nil, { now = 10 })
).unitPrice

T.truthy(rosewoodFoodCtx.effectiveSupply < rosewoodFoodCtx.marketSupply,
    "food_crisis lowers effective Food supply in affected region")
T.truthy(rosewoodFoodCtx.effectiveDemand > rosewoodFoodCtx.marketDemand,
    "food_crisis raises effective Food demand in affected region")
T.truthy(crisisPrice > baselinePrice,
    "food_crisis raises Food price pressure in affected region")
T.equal(muldraughFoodCtx.activeEventCount, 0,
    "region-scoped food_crisis does not leak to other regions")

-- 2b. agricultural_surplus lowers price pressure and raises Food supply
assert(ScopedWorldEvents.Register({
    eventID = "ev_central_surplus",
    eventType = "agricultural_surplus",
    scope = "region",
    scopeID = "region_central",
    startsAt = 5,
    endsAt = 50,
    severity = 0.6,
    source = "hoomans-world-event",
    effects = {
        foodAvailabilityPressure = -0.7,
    },
}))
local surplusFoodCtx = Pricing.GetItemContext(
    "Base.CannedBeans", Pricing.BuildContext(muldraughRecord, nil, { now = 10 }))
local surplusPrice = Stock.Quote(
    "Base.CannedBeans", DTCommon.OP_BUY, nil,
    Pricing.BuildContext(muldraughRecord, nil, { now = 10 })
).unitPrice
T.truthy(surplusFoodCtx.effectiveSupply > surplusFoodCtx.marketSupply,
    "agricultural_surplus raises effective Food supply")
T.truthy(surplusPrice < baselinePrice,
    "agricultural_surplus lowers Food price pressure")

-- 3. bandit_bonanza projects caravanRisk penalty into DTHoomans_CommercialMobility.OpportunityScore
local baselineMobilityScore = Mobility.OpportunityScore(
    { id = "faction_other", archetypeID = "trader" },
    { communityID = "comm_westpoint" },
    { at = 10 }
)

assert(ScopedWorldEvents.Register({
    eventID = "ev_north_bandit_bonanza",
    eventType = "bandit_bonanza",
    scope = "region",
    scopeID = "region_north",
    startsAt = 5,
    endsAt = 50,
    severity = 0.85,
    source = "hoomans-world-event",
    effects = {
        hostileActivityMultiplier = 2.0,
        caravanRisk = 0.9,
        travelRisk = 0.7,
    },
}))

local projectedBandit = DTCommon.MarketEvents.Get(
    "hoomans-world-event:ev_north_bandit_bonanza")
T.truthy(projectedBandit, "bandit_bonanza projected under hoomans-world-event:")

local banditMobilityScore = Mobility.OpportunityScore(
    { id = "faction_other", archetypeID = "trader" },
    { communityID = "comm_westpoint" },
    { at = 10 }
)
T.truthy(banditMobilityScore < baselineMobilityScore,
    "bandit_bonanza caravanRisk reduces CommercialMobility.OpportunityScore")

-- 4. local_area event affects ONLY its pre-resolved affectedSettlements
local directoryListCalls = 0
local originalDirectoryList = DTCommon.SettlementDirectory.List
DTCommon.SettlementDirectory.List = function(...)
    directoryListCalls = directoryListCalls + 1
    return originalDirectoryList(...)
end

assert(ScopedWorldEvents.Register({
    eventID = "ev_local_bridge_ambush",
    eventType = "trade_disruption",
    scope = "local_area",
    scopeID = "area_muldraugh_road",
    startsAt = 5,
    endsAt = 50,
    severity = 0.7,
    source = "hoomans-world-event",
    affectedSettlements = { "comm_muldraugh" },
    effects = {
        tradeScarcity = 0.5,
        travelRisk = 0.4,
    },
}))

T.equal(directoryListCalls, 0,
    "local_area projection never scans SettlementDirectory.List()")

local muldraughLocalEvents = DTCommon.MarketEvents.ListActive(
    "comm_muldraugh", muldraughRecord, { now = 10 })
local rosewoodLocalEvents = DTCommon.MarketEvents.ListActive(
    "comm_rosewood", rosewoodRecord, { now = 10 })

local foundLocalOnMuldraugh = false
local foundLocalOnRosewood = false
for index = 1, #muldraughLocalEvents do
    if string.find(muldraughLocalEvents[index].eventID, "ev_local_bridge_ambush", 1, true) then
        foundLocalOnMuldraugh = true
    end
end
for index = 1, #rosewoodLocalEvents do
    if string.find(rosewoodLocalEvents[index].eventID, "ev_local_bridge_ambush", 1, true) then
        foundLocalOnRosewood = true
    end
end
T.truthy(foundLocalOnMuldraugh,
    "local_area event affects its pre-resolved affectedSettlements")
T.falsy(foundLocalOnRosewood,
    "local_area event does NOT affect unrelated settlements")

DTCommon.SettlementDirectory.List = originalDirectoryList

-- 5. Expired event cleanly removes its DT MarketEvent projection
local prunedCount = ScopedWorldEvents.PruneExpired(60)
T.truthy(prunedCount >= 4, "ScopedWorldEvents expired active events at t=60")

local removedFood, removedFoodErr = DTCommon.MarketEvents.Get(
    "hoomans-world-event:ev_south_food_crisis")
T.falsy(removedFood, "expired food_crisis removed from DT MarketEvents")
T.equal(removedFoodErr, "event_not_found", "expired event returns event_not_found")

local removedBandit = DTCommon.MarketEvents.Get(
    "hoomans-world-event:ev_north_bandit_bonanza")
T.falsy(removedBandit, "expired bandit_bonanza removed from DT MarketEvents")

local postExpiryScore = Mobility.OpportunityScore(
    { id = "faction_other", archetypeID = "trader" },
    { communityID = "comm_westpoint" },
    { at = 60 }
)
T.equal(postExpiryScore, baselineMobilityScore,
    "CommercialMobility.OpportunityScore recovers cleanly after event expiry")

-- 6. DT market-native dt-market-condition: events do NOT feed back recursively
local coreCountBefore = ScopedWorldEvents.GetStats().activeCount
local shifted = DTCommon.SettlementMarket.ApplyDelta("comm_rosewood", {
    categories = {
        Food = { supplyDelta = -0.35, demandDelta = 0.35 },
    },
}, { now = 70 })
T.truthy(shifted, "settlement market shifted to trigger native producer")
local producerResult = DTCommon.MarketEventProducer.Evaluate("comm_rosewood", { now = 70 })
T.truthy(producerResult and producerResult.changed,
    "DT MarketEventProducer generated dt-market-condition: event")
T.equal(string.sub(producerResult.eventID, 1, 20), "dt-market-condition:",
    "native event uses dt-market-condition: prefix")

local coreCountAfter = ScopedWorldEvents.GetStats().activeCount
T.equal(coreCountAfter, coreCountBefore,
    "DT market-native event NEVER registers back into ScopedWorldEvents")

-- Even if an external caller registers a dt-market-condition event in Core,
-- projection ignores it cleanly.
assert(ScopedWorldEvents.Register({
    eventID = "dt-market-condition:loopback_guard",
    eventType = "food_shortage",
    scope = "settlement",
    scopeID = "comm_rosewood",
    startsAt = 70,
    endsAt = 80,
    source = "dt-market-condition",
    effects = { foodAvailabilityPressure = 0.5 },
}))
local loopProjected = DTCommon.MarketEvents.Get(
    "hoomans-world-event:dt-market-condition:loopback_guard")
T.falsy(loopProjected,
    "projection ignores dt-market-condition source and prefix")

Projection.Unsubscribe()
T.finish("dt_world_event_projection_smoke")

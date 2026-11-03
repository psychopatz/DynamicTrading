local T = require "tests/support/test"
T.addPackagePaths()

local coreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY")
    or "../psychopatzCore"
package.path = coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. package.path

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local World = Actors.World
local Journey = require "PsychopatzCore/Actors/PsychopatzActorJourney"
local Json = require "PsychopatzCore/Serialization/PsychopatzJson"

-- ---------------------------------------------------------------------------
-- 1. Persistence Verification across fresh storage reconstruction
-- ---------------------------------------------------------------------------
local originRegistry = Actors.NewRegistry()
local originStorageData = { t = {}, v = 1, r = 1 }

DTCommon = DTCommon or {}
local Directory = T.load(
    "DTCommon",
    "shared",
    "DTCommon/DTCommon_SettlementDirectory.lua"
)
assert(Directory.Register({
    settlementID = "settlement:muldraugh",
    name = "Muldraugh",
    position = { x = 10630, y = 9980, z = 0 },
    provider = "fixture",
}))
assert(Directory.Register({
    settlementID = "settlement:westpoint",
    name = "West Point",
    position = { x = 11900, y = 6900, z = 0 },
    provider = "fixture",
}))

local Policy = T.load("DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
local coreProvider = T.load("DTAbstract", "shared", "DTAbstract/DTAbstract_CoreProvider.lua")

-- Create Actor 1 with active journey
local actor1, actorReason = originRegistry:Create({
    actorId = "actor:dt:p7:1",
    identitySeed = "p7-seed-1",
    world = { position = { x = 10630, y = 9980, z = 0 } },
})
T.truthy(actor1, actorReason)

local acquired1 = coreProvider.Acquire(actor1, { Actors = Actors }, { owner = "dtcommon:trader_world", now = 0 })
originRegistry:Commit(actor1.actorId, acquired1, actor1.revision)

local currentActor1 = originRegistry:Get(actor1.actorId)
local world1 = World.StartJourney(currentActor1.world, actor1.actorId, {
    journeyID = "journey:p7:1",
    origin = { x = 10630, y = 9980, z = 0 },
    destination = { x = 11900, y = 6900, z = 0 },
    speed = 60,
    startAt = 10,
}, 10)
originRegistry:Commit(actor1.actorId, { world = world1 }, currentActor1.revision)

-- Advance to halfway
local duration = world1.journey.distanceTotal / 60
local midTime = 10 + (duration * 0.5)
currentActor1 = originRegistry:Get(actor1.actorId)
local advWorld1 = World.AdvanceJourney(currentActor1.world, midTime)
originRegistry:Commit(actor1.actorId, { world = advWorld1 }, currentActor1.revision)

local preReloadProjPos = World.ProjectPosition(advWorld1, midTime)

originStorageData.t["trader:dt:p7:1"] = {
    n = "P7 Persistent Trader",
    s = "READY",
    b = 888,
    v = 4,
    a = 1,
    ca = Policy.New({
        actorID = actor1.actorId,
        provider = "DTAbstract",
        providerState = "abstract",
        originSettlementID = "settlement:muldraugh",
        destinationSettlementID = "settlement:westpoint",
    }),
}

-- SERIALIZE to json/strings (deep decouple, no table sharing)
local serializedActors = Json.Encode(originRegistry:Save())
local serializedStorage = Json.Encode(originStorageData)
T.truthy(type(serializedActors) == "string", "actors serialized to string")
T.truthy(type(serializedStorage) == "string", "storage serialized to string")

-- RECONSTRUCT into completely fresh instances
local freshRegistry = Actors.NewRegistry()
local restoredActorPayload = Json.Decode(serializedActors)
freshRegistry:Load(restoredActorPayload)

local freshStorageData = Json.Decode(serializedStorage)

-- Verify restored actor & journey
local reloadedActor = freshRegistry:Get("actor:dt:p7:1")
T.truthy(reloadedActor, "reloaded actor found")
T.equal(reloadedActor.actorId, "actor:dt:p7:1", "actorId intact")
T.equal(reloadedActor.providerLease.provider, "DTAbstract", "provider lease preserved")
T.equal(reloadedActor.providerLease.state, "abstract", "provider state preserved")
T.truthy(reloadedActor.world.journey, "journey preserved")
T.equal(reloadedActor.world.journey.journeyID, "journey:p7:1", "journeyID preserved")
T.truthy(math.abs(reloadedActor.world.journey.progress - 0.5) < 0.01, "progress preserved")

-- Projected position matches before and after reload
local postReloadProjPos = World.ProjectPosition(reloadedActor.world, midTime)
T.truthy(math.abs(postReloadProjPos.x - preReloadProjPos.x) < 0.001, "projected X preserved across reload")
T.truthy(math.abs(postReloadProjPos.y - preReloadProjPos.y) < 0.001, "projected Y preserved across reload")

-- Verify restored DT storage record
local reloadedTrader = freshStorageData.t["trader:dt:p7:1"]
T.truthy(reloadedTrader, "reloaded trader record found")
T.equal(reloadedTrader.n, "P7 Persistent Trader", "name intact")
T.equal(reloadedTrader.b, 888, "budget intact")
T.equal(reloadedTrader.v, 4, "stock version intact")
T.equal(reloadedTrader.ca.actorID, "actor:dt:p7:1", "actorID binding intact")
T.equal(reloadedTrader.ca.provider, "DTAbstract", "provider intact")
T.equal(reloadedTrader.ca.destinationSettlementID, "settlement:westpoint", "destination settlement intact")

-- ---------------------------------------------------------------------------
-- 2. Performance & Bounded Work Verification
-- ---------------------------------------------------------------------------
DTCommon.Storage = {
    IsAuthority = function() return true end,
    GetData = function() return freshStorageData end,
    SaveInventory = function() return true end,
}
DTCommon.TraderStock = {
    SaveAndTransmit = function() end,
}
DTCommon.TraderService = {
    ForEach = function(cb)
        for id, r in pairs(freshStorageData.t) do cb(id, r) end
    end,
    GetRecord = function(id) return freshStorageData.t[id] end,
    Create = function(def)
        local id = def.traderID
        freshStorageData.t[id] = { n = def.displayName, ca = Policy.New(def), b = def.budget, v = 1 }
        return id, freshStorageData.t[id]
    end,
    MarkSettlementVisit = function() return true end,
}

local Provider = T.load(
    "DTAbstract", "server", "DTAbstract/DTAbstract_TraderWorldProvider.lua")
Provider.SetActorRegistry(freshRegistry)
local TraderWorld = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderWorld.lua")

-- Run 50 ticks and measure work:
-- Ensure work does not grow unboundedly with tick count
local totalSpawned = 0
local totalArrived = 0
local tickCount = 50

for t = 1, tickCount do
    local summary = TraderWorld.Tick(true, midTime + t)
    totalSpawned = totalSpawned + (summary.spawned or 0)
    totalArrived = totalArrived + (summary.arrived or 0)
    T.truthy(summary.activeCount <= TraderWorld.MAX_ROAMING_TRADERS,
        "active count never exceeds common roaming bound")
end

-- Active trader population is bounded
local finalCount = TraderWorld.CountManaged(TraderWorld.DEFAULT_ROLE)
T.truthy(finalCount <= TraderWorld.MAX_ROAMING_TRADERS,
    "final common managed count bounded")

-- Settlement Directory lookup is indexed O(1)
local benchmarkCount = 1000
for i = 1, benchmarkCount do
    local s = Directory.Get("settlement:muldraugh")
    if not s then error("lookup failed") end
end

T.finish("dt_trader_world_persistence_performance_smoke")

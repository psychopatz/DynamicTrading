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

DTCommon = DTCommon or {}

-- ---------------------------------------------------------------------------
-- 1. Load SettlementDirectory module
-- ---------------------------------------------------------------------------
local ok, err = pcall(function()
    return T.load("DTCommon", "shared", "DTCommon/DTCommon_SettlementDirectory.lua")
end)
if not ok then
    error("P0/P1 Fail-First: DTCommon.SettlementDirectory not implemented: " .. tostring(err), 2)
end

local Directory = DTCommon.SettlementDirectory
T.truthy(Directory, "SettlementDirectory loaded")

-- ---------------------------------------------------------------------------
-- 2. Settlement Registration and Lookup
-- ---------------------------------------------------------------------------
local registered, regReason = Directory.Register({
    settlementID = "settlement:muldraugh",
    name = "Muldraugh",
    position = { x = 10630, y = 9980, z = 0 },
    provider = "DTAbstract",
    profileID = "default",
    enabled = true,
})
T.truthy(registered, regReason)

local muldraugh, getReason = Directory.Get("settlement:muldraugh")
T.truthy(muldraugh, getReason)
T.equal(muldraugh.settlementID, "settlement:muldraugh", "settlement ID matches")
T.equal(muldraugh.name, "Muldraugh", "settlement name matches")
T.equal(muldraugh.position.x, 10630, "settlement X matches")
T.equal(muldraugh.position.y, 9980, "settlement Y matches")
T.equal(muldraugh.position.z, 0, "settlement Z matches")

-- ResolvePosition helper
local pos, posReason = Directory.ResolvePosition("settlement:muldraugh")
T.truthy(pos, posReason)
T.equal(pos.x, 10630, "ResolvePosition X")
T.equal(pos.y, 9980, "ResolvePosition Y")

-- Second distinct settlement
local registered2 = Directory.Register({
    settlementID = "settlement:westpoint",
    name = "West Point",
    position = { x = 11900, y = 6900, z = 0 },
    provider = "DTAbstract",
    profileID = "default",
    enabled = true,
})
T.truthy(registered2, "West Point registered")

local list = Directory.List()
T.truthy(#list >= 2, "at least two settlements listed")

-- ---------------------------------------------------------------------------
-- 3. Coordinate validation
-- ---------------------------------------------------------------------------
local invalidPos, invReason = Directory.Register({
    settlementID = "settlement:invalid",
    name = "Invalid",
    position = { x = "not-a-number", y = 9980, z = 0 },
})
T.falsy(invalidPos, "invalid position rejected")

-- ---------------------------------------------------------------------------
-- 4. Canonical Core Actor Projected Journey Position
-- ---------------------------------------------------------------------------
T.truthy(type(World.ProjectPosition) == "function" or type(Journey.ProjectPosition) == "function",
    "P0/P1 Fail-First: Canonical projected journey position function must exist in PsychopatzCore")

local ProjectFn = World.ProjectPosition or function(w, now)
    return Journey.ProjectPosition(w and w.journey, now)
end

local registry = Actors.NewRegistry()
local actor, actorReason = registry:Create({
    actorId = "trader:abstract:test1",
    identitySeed = "abstract-trader-seed-1",
    world = {
        position = { x = 10630, y = 9980, z = 0 },
    },
})
T.truthy(actor, actorReason)

local worldState, startReason = World.StartJourney(actor.world, actor.actorId, {
    journeyID = "journey:test1",
    origin = { x = 10630, y = 9980, z = 0 },
    destination = { x = 11900, y = 6900, z = 0 },
    speed = 100,
    startAt = 0,
}, 0)
T.truthy(worldState, startReason)

-- At start: projected position is origin
local projStart = ProjectFn(worldState, 0)
T.truthy(projStart, "projected position at start")
T.equal(projStart.x, 10630, "start X")
T.equal(projStart.y, 9980, "start Y")

-- At midpoint: advance to half distance
local totalDist = worldState.journey.distanceTotal
local midTime = (totalDist / 100) * 0.5
local advancedWorld = World.AdvanceJourney(worldState, midTime)
local projMid = ProjectFn(advancedWorld, midTime)
T.truthy(projMid, "projected position at midpoint")
local expectedMidX = 10630 + (11900 - 10630) * 0.5
local expectedMidY = 9980 + (6900 - 9980) * 0.5
T.truthy(math.abs(projMid.x - expectedMidX) < 1, "midpoint X within 1 tile")
T.truthy(math.abs(projMid.y - expectedMidY) < 1, "midpoint Y within 1 tile")

-- At arrival:
local finishTime = (totalDist / 100) + 1
local arrivedWorld = World.AdvanceJourney(advancedWorld, finishTime)
T.equal(arrivedWorld.journey.state, "arrived", "journey arrived")
local projArrival = ProjectFn(arrivedWorld, finishTime)
T.equal(projArrival.x, 11900, "arrival projected X matches destination")
T.equal(projArrival.y, 6900, "arrival projected Y matches destination")
T.equal(arrivedWorld.location.position.x, 11900, "stored location agrees with projected position")

-- ---------------------------------------------------------------------------
-- 5. Canonical Core Actor Binding and Persistence Reload
-- ---------------------------------------------------------------------------
DTAbstract = DTAbstract or {}
local coreProvider = dofile(T.repository
    .. "/Contents/mods/DTAbstract/42.20/media/lua/shared/DTAbstract/"
    .. "DTAbstract_CoreProvider.lua")

local acquiredActor, acqReason = coreProvider.Acquire(actor, { Actors = Actors }, {
    owner = "abstract:lifecycle",
    now = 0,
})
T.truthy(acquiredActor, acqReason)
T.equal(acquiredActor.providerLease.provider, "DTAbstract", "actor lease is DTAbstract")
T.equal(acquiredActor.providerLease.state, "abstract", "actor state is abstract")

local committedActor, comReason = registry:Commit(actor.actorId, acquiredActor, actor.revision)
T.truthy(committedActor, comReason)

-- Bind with DT trader record
local Policy = dofile(T.repository
    .. "/Contents/mods/DTCommon/42.20/media/lua/shared/DTCommon/"
    .. "DTCommon_CoreActorPolicy.lua")
local traderRecord = {
    n = "Trader Test1",
    s = "READY",
    b = 500,
    v = 1,
    ca = Policy.New({
        actorID = actor.actorId,
        provider = "DTAbstract",
        providerState = "abstract",
        homeSettlementID = "settlement:muldraugh",
        currentSettlementID = "settlement:muldraugh",
    }),
}

T.equal(traderRecord.ca.actorID, actor.actorId, "canonical binding trader -> actor")
T.equal(traderRecord.ca.provider, "DTAbstract", "canonical provider")

-- Persistence reload test: save Core registry and reload into fresh registry
local savedCore = registry:Save()
local freshRegistry = Actors.NewRegistry()
T.truthy(freshRegistry:Load(savedCore), "registry reloaded from saved payload")
local reloadedActor = freshRegistry:Get(actor.actorId)
T.truthy(reloadedActor, "reloaded actor exists")
T.equal(reloadedActor.actorId, actor.actorId, "actor ID preserved across reload")
T.equal(reloadedActor.providerLease.provider, "DTAbstract", "lease provider preserved")
T.equal(reloadedActor.providerLease.state, "abstract", "lease state preserved")

T.finish("dt_abstract_settlement_directory_smoke")

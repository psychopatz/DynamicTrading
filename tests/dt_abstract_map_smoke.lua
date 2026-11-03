local T = require "tests/support/test"
T.addPackagePaths()

local coreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY")
    or "../psychopatzCore"
package.path = coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. package.path

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local World = Actors.World
local actorRegistry = Actors.NewRegistry()

PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = Actors
PsychopatzCore.Debug = { CanUse = function() return true end }

DTCommon = DTCommon or {}
local Directory = T.load("DTCommon", "shared", "DTCommon/DTCommon_SettlementDirectory.lua")
Directory.Reset()
Directory.Register({
    settlementID = "settlement:muldraugh",
    name = "Muldraugh",
    position = { x = 10630, y = 9980, z = 0 },
    provider = "DTAbstract",
})
Directory.Register({
    settlementID = "settlement:westpoint",
    name = "West Point",
    position = { x = 11900, y = 6900, z = 0 },
    provider = "DTAbstract",
})

local traderStore = { t = {} }
local Policy = T.load("DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")

DTCommon.TraderService = {
    ForEach = function(callback)
        for id, record in pairs(traderStore.t) do
            callback(id, record)
        end
    end,
    GetRecord = function(id) return traderStore.t[id] end,
}

DTAbstract = DTAbstract or {}
DTAbstract.Lifecycle = {
    GetActorRegistry = function() return actorRegistry end,
}

-- Create actor and trader
local actor, actorReason = actorRegistry:Create({
    actorId = "actor:map:test1",
    identitySeed = "map-seed",
    world = { position = { x = 10630, y = 9980, z = 0 } },
})
T.truthy(actor, actorReason)

local coreProvider = T.load("DTAbstract", "shared", "DTAbstract/DTAbstract_CoreProvider.lua")
local acquired = coreProvider.Acquire(actor, { Actors = Actors }, { owner = "test", now = 0 })
actorRegistry:Commit(actor.actorId, acquired, actor.revision)

traderStore.t["trader:map:1"] = {
    n = "Traveling Merchant",
    s = "READY",
    b = 500,
    v = 1,
    ca = Policy.New({
        actorID = actor.actorId,
        provider = "DTAbstract",
        providerState = "abstract",
        homeSettlementID = "settlement:muldraugh",
        currentSettlementID = "settlement:muldraugh",
        destinationSettlementID = "settlement:westpoint",
    }),
}

-- ---------------------------------------------------------------------------
-- 1. Load WorldMap Module
-- ---------------------------------------------------------------------------
local WorldMap = T.load("DTAbstract", "client", "DTAbstract/DTAbstract_WorldMap.lua")
T.truthy(WorldMap, "DTAbstract.WorldMap loaded")

-- ---------------------------------------------------------------------------
-- 2. Settlement Markers Check
-- ---------------------------------------------------------------------------
local settlementMarkers = WorldMap.GetSettlementMarkers()
T.equal(#settlementMarkers, 2, "exactly two settlement markers")
T.equal(settlementMarkers[1].position.x, 10630, "Muldraugh X")
T.equal(settlementMarkers[1].position.y, 9980, "Muldraugh Y")
T.equal(settlementMarkers[2].position.x, 11900, "West Point X")
T.equal(settlementMarkers[2].position.y, 6900, "West Point Y")

-- ---------------------------------------------------------------------------
-- 3. Trader Marker Check at Origin
-- ---------------------------------------------------------------------------
local traderMarkers = WorldMap.GetTraderMarkers(0, true)
T.equal(#traderMarkers, 1, "one trader marker")
T.equal(traderMarkers[1].position.x, 10630, "trader marker at origin X")
T.equal(traderMarkers[1].position.y, 9980, "trader marker at origin Y")

-- ---------------------------------------------------------------------------
-- 4. Start Journey and Check Moving Marker
-- ---------------------------------------------------------------------------
local currentActor = actorRegistry:Get(actor.actorId)
local worldWithJourney = World.StartJourney(currentActor.world, actor.actorId, {
    journeyID = "journey:map:1",
    origin = { x = 10630, y = 9980, z = 0 },
    destination = { x = 11900, y = 6900, z = 0 },
    speed = 100,
    startAt = 0,
}, 0)
actorRegistry:Commit(actor.actorId, { world = worldWithJourney }, currentActor.revision)

-- Advance halfway
local totalDist = worldWithJourney.journey.distanceTotal
local midTime = (totalDist / 100) * 0.5
local advancedWorld = World.AdvanceJourney(worldWithJourney, midTime)
currentActor = actorRegistry:Get(actor.actorId)
actorRegistry:Commit(actor.actorId, { world = advancedWorld }, currentActor.revision)

-- Canonical projected position
local expectedProjPos = World.ProjectPosition(advancedWorld, midTime)
local movingMarkers = WorldMap.GetTraderMarkers(midTime, true)
T.equal(#movingMarkers, 1, "one moving trader marker")
T.equal(movingMarkers[1].position.x, expectedProjPos.x, "moving marker X matches canonical projected position")
T.equal(movingMarkers[1].position.y, expectedProjPos.y, "moving marker Y matches canonical projected position")

-- Advance to arrival
local arrTime = (totalDist / 100) + 1
local arrivedWorld = World.AdvanceJourney(advancedWorld, arrTime)
currentActor = actorRegistry:Get(actor.actorId)
actorRegistry:Commit(actor.actorId, { world = arrivedWorld }, currentActor.revision)

local arrivalMarkers = WorldMap.GetTraderMarkers(arrTime, true)
T.equal(arrivalMarkers[1].position.x, 11900, "arrival marker converged to West Point X")
T.equal(arrivalMarkers[1].position.y, 6900, "arrival marker converged to West Point Y")

-- ---------------------------------------------------------------------------
-- 5. Map Render Call & Simulation Immutability
-- ---------------------------------------------------------------------------
local drawnRects = {}
local drawnTexts = {}
local mockMap = {
    mapAPI = {
        worldToUIX = function(_, wx, wy) return wx / 10 end,
        worldToUIY = function(_, wx, wy) return wy / 10 end,
    },
    drawRect = function(_, x, y, w, h, a, r, g, b)
        drawnRects[#drawnRects + 1] = { x = x, y = y, w = w, h = h }
    end,
    drawTextCentre = function(_, text, x, y, r, g, b, a, font)
        drawnTexts[#drawnTexts + 1] = { text = text, x = x, y = y }
    end,
}

WorldMap.Render(mockMap)
T.truthy(#drawnRects >= 3, "renders 2 settlements + 1 trader marker")
T.truthy(#drawnTexts >= 3, "renders labels for settlements and trader")

-- Repeated rendering does not mutate state
local preRecord = traderStore.t["trader:map:1"]
local preVersion = preRecord.v
WorldMap.Render(mockMap)
WorldMap.Render(mockMap)
T.equal(preRecord.v, preVersion, "rendering does not mutate trader record version")

T.finish("dt_abstract_map_smoke")

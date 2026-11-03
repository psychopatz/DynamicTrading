local T = require "tests/support/test"
T.addPackagePaths()

local coreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY")
    or "../psychopatzCore"
package.path = coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. package.path

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local World = Actors.World
local Projection = Actors.Projection
local actorRegistry = Actors.NewRegistry()
local clientStore = Projection.NewStore()
Projection.ClientStore = clientStore
PsychopatzCore.ActorProjectionClient = nil

local notificationsShown = {}
PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = Actors
PsychopatzCore.Notifications = {
    Show = function(def)
        notificationsShown[#notificationsShown + 1] = def
        return true
    end,
}

DTCommon = DTCommon or {}
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

-- Create abstract trader at (10000, 10000)
local actor, actorReason = actorRegistry:Create({
    actorId = "actor:disc:1",
    identitySeed = "disc-seed",
    world = { position = { x = 10000, y = 10000, z = 0 } },
})
T.truthy(actor, actorReason)

local coreProvider = T.load("DTAbstract", "shared", "DTAbstract/DTAbstract_CoreProvider.lua")
local acquired = coreProvider.Acquire(actor, { Actors = Actors }, { owner = "test", now = 0 })
actorRegistry:Commit(actor.actorId, acquired, actor.revision)
local projected = assert(Projection.ProjectActor(
    actorRegistry:Get(actor.actorId), 0, {
        sourceID = "DTAbstract",
        provider = "DTAbstract",
        providerState = "abstract",
    }))
assert(clientStore:ApplySnapshot({
    schema = Projection.SCHEMA,
    schemaVersion = Projection.SCHEMA_VERSION,
    sourceID = "DTAbstract",
    snapshotRevision = 1,
    entries = { projected },
}))

traderStore.t["trader:disc:1"] = {
    n = "Nearby Merchant",
    s = "READY",
    b = 500,
    v = 1,
    ca = Policy.New({
        actorID = actor.actorId,
        provider = "DTAbstract",
        providerState = "abstract",
    }),
}

-- ---------------------------------------------------------------------------
-- 1. Load Discovery Module
-- ---------------------------------------------------------------------------
local Discovery = T.load("DTAbstract", "client", "DTAbstract/DTAbstract_NearbyDiscovery.lua")
T.truthy(Discovery, "DTAbstract.NearbyDiscovery loaded")
Discovery.ResetDiscovery()

-- ---------------------------------------------------------------------------
-- 2. Outside detection radius (100 tiles away) -> No notification
-- ---------------------------------------------------------------------------
local player = {
    x = 10100, y = 10000,
    getX = function(self) return self.x end,
    getY = function(self) return self.y end,
}

local detected = Discovery.CheckNearbyTraders(player, 100)
T.equal(detected, 0, "no detection outside radius")
T.equal(#notificationsShown, 0, "no notification shown")
T.falsy(Discovery.IsTraderDiscovered("trader:disc:1"), "trader is not yet discovered")

-- ---------------------------------------------------------------------------
-- 3. Enter radius (50 tiles away, inside 60 tile radius) -> Exactly 1 notification
-- ---------------------------------------------------------------------------
player.x = 10050
detected = Discovery.CheckNearbyTraders(player, 105)
T.equal(detected, 1, "exactly 1 trader detected")
T.equal(#notificationsShown, 1, "exactly 1 notification emitted")
T.equal(notificationsShown[1].id, "dt_nearby:trader:disc:1", "notification ID identifies trader")
T.truthy(Discovery.IsTraderDiscovered("trader:disc:1"), "trader is now marked discovered")

-- ---------------------------------------------------------------------------
-- 4. Repeated checks while remaining inside -> NO notification spam
-- ---------------------------------------------------------------------------
for step = 1, 5 do
    detected = Discovery.CheckNearbyTraders(player, 105 + step)
    T.equal(detected, 0, "no repeated detection while remaining inside")
    T.equal(#notificationsShown, 1, "notification count remains 1")
end

-- ---------------------------------------------------------------------------
-- 5. Edge jitter inside hysteresis window (65 tiles: > 60 detection, but < 75 exit)
-- ---------------------------------------------------------------------------
player.x = 10065
detected = Discovery.CheckNearbyTraders(player, 120)
T.equal(detected, 0, "jitter inside hysteresis does not re-detect")
local state = Discovery.GetTraderState("trader:disc:1")
T.truthy(state.inside, "state remains inside due to hysteresis")

-- ---------------------------------------------------------------------------
-- 6. True exit beyond 75 tiles (e.g. 80 tiles)
-- ---------------------------------------------------------------------------
player.x = 10080
detected = Discovery.CheckNearbyTraders(player, 130)
T.equal(detected, 0, "no detection on exit")
T.falsy(state.inside, "state marked outside after exceeding exit radius")

-- ---------------------------------------------------------------------------
-- 7. Re-enter before cooldown (30 seconds later < 300s cooldown) -> No spam
-- ---------------------------------------------------------------------------
player.x = 10050
detected = Discovery.CheckNearbyTraders(player, 160)
T.equal(detected, 0, "re-entering before cooldown does not spam notification")
T.equal(#notificationsShown, 1, "notification count still 1")

-- ---------------------------------------------------------------------------
-- 8. Re-enter after cooldown (exit then re-enter at now = 500 > 105 + 300)
-- ---------------------------------------------------------------------------
player.x = 10080
Discovery.CheckNearbyTraders(player, 400) -- true exit
player.x = 10050
detected = Discovery.CheckNearbyTraders(player, 500) -- re-enter after cooldown
T.equal(detected, 1, "detection triggers again after cooldown")
T.equal(#notificationsShown, 2, "second notification emitted after cooldown")

T.finish("dt_abstract_nearby_discovery_smoke")

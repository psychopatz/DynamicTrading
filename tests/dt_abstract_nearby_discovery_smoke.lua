local T = require "tests/support/test"
T.addPackagePaths()

local notificationsShown = {}
PsychopatzCore = {
    Notifications = {
        Show = function(def)
            notificationsShown[#notificationsShown + 1] = def
            return true
        end,
    },
}

local actor = {
    actorID = "actor:disc:1",
    groupID = "group:disc:1",
    communityID = "community:disc:1",
    position = { x = 10000, y = 10000, z = 0 },
}
local discovery = {}
local coreActions = {}
local actorRequests = 0
local CoreClient = {
    GetActor = function(actorID)
        if actorID == actor.actorID then return actor end
    end,
    RequestActorsIfDue = function(interval)
        actorRequests = actorRequests + 1
        T.equal(interval, 1000,
            "nearby actor refresh cadence changed")
        return true
    end,
    FindDiscovery = function(kind, entityID)
        return discovery[kind .. ":" .. entityID]
    end,
    DiscoveryAction = function(action, args)
        coreActions[#coreActions + 1] = {
            action = action,
            args = args,
        }
        if action == "mark_contacted" then
            discovery[args.kind .. ":" .. args.entityID] = {
                kind = args.kind,
                entityID = args.entityID,
                phase = 3,
            }
        elseif action == "debug_reset_entity" then
            discovery[args.kind .. ":" .. args.entityID] = nil
        elseif action == "debug_reset" then
            discovery = {}
        end
        return true
    end,
}
package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
] = function()
    return CoreClient
end

local record = {
    n = "Nearby Merchant",
    s = "READY",
    b = 500,
    v = 1,
    ca = {
        actorID = actor.actorID,
        provider = "DTAbstract",
        providerState = "abstract",
    },
}
DTCommon = {
    TraderService = {
        GetRecord = function(id)
            if id == "trader:disc:1" then return record end
        end,
    },
    TraderPresentation = {
        ListTraderRecords = function()
            return {
                {
                    traderID = "trader:disc:1",
                    record = record,
                    provider = "DTAbstract",
                },
            }
        end,
    },
}
DTAbstract = {}

local Discovery = T.load(
    "DTAbstract",
    "client",
    "DTAbstract/DTAbstract_NearbyDiscovery.lua"
)
T.truthy(Discovery, "DTAbstract.NearbyDiscovery loaded")
T.falsy(
    Discovery.IsTraderDiscovered("trader:disc:1"),
    "trader started discovered without Core knowledge"
)

local player = {
    x = 10100,
    y = 10000,
    getX = function(self) return self.x end,
    getY = function(self) return self.y end,
}

local detected = Discovery.CheckNearbyTraders(player, 100)
T.equal(detected, 0, "no detection outside radius")
T.equal(#notificationsShown, 0, "no notification shown")
T.falsy(
    Discovery.IsTraderDiscovered("trader:disc:1"),
    "outside trader became discovered"
)

player.x = 10050
detected = Discovery.CheckNearbyTraders(player, 105)
T.equal(detected, 1, "exactly 1 trader detected")
T.equal(#notificationsShown, 1,
    "exactly 1 notification emitted")
T.equal(
    notificationsShown[1].id,
    "dt_nearby:trader:disc:1",
    "notification ID identifies trader"
)
T.truthy(
    Discovery.IsTraderDiscovered("trader:disc:1"),
    "Core contact discovery did not become canonical truth"
)
T.equal(coreActions[1].action, "mark_contacted",
    "nearby discovery did not advance Core")
T.equal(coreActions[1].args.kind, "group",
    "nearby discovery did not use canonical group")
T.equal(coreActions[1].args.entityID, "group:disc:1",
    "nearby discovery group identity changed")

for step = 1, 5 do
    detected = Discovery.CheckNearbyTraders(
        player,
        105 + step
    )
    T.equal(detected, 0,
        "no repeated detection while remaining inside")
    T.equal(#notificationsShown, 1,
        "notification count remains 1")
end
T.equal(#coreActions, 1,
    "remaining inside repeatedly rewrote Core discovery")

player.x = 10065
detected = Discovery.CheckNearbyTraders(player, 120)
T.equal(detected, 0,
    "jitter inside hysteresis does not re-detect")
local state =
    Discovery.GetTraderState("trader:disc:1")
T.truthy(state.inside,
    "state remains inside due to hysteresis")

player.x = 10080
detected = Discovery.CheckNearbyTraders(player, 130)
T.equal(detected, 0, "no detection on exit")
T.falsy(state.inside,
    "state marked outside after exceeding exit radius")

player.x = 10050
detected = Discovery.CheckNearbyTraders(player, 160)
T.equal(detected, 0,
    "re-entering before cooldown does not spam")
T.equal(#notificationsShown, 1,
    "notification count still 1")
T.equal(#coreActions, 2,
    "re-entry should reassert contact once, not every tick")
T.equal(coreActions[2].action, "mark_contacted",
    "re-entry did not use Core contact action")

player.x = 10080
Discovery.CheckNearbyTraders(player, 400)
player.x = 10050
detected = Discovery.CheckNearbyTraders(player, 500)
T.equal(detected, 1,
    "detection triggers again after cooldown")
T.equal(#notificationsShown, 2,
    "second notification emitted after cooldown")

local reset, resetReason =
    Discovery.ResetDiscovery("trader:disc:1")
T.truthy(reset, resetReason)
T.falsy(
    Discovery.IsTraderDiscovered("trader:disc:1"),
    "per-trader debug reset did not clear Core entity discovery"
)
T.equal(
    coreActions[#coreActions].action,
    "debug_reset_entity",
    "per-trader reset used transient local state"
)

T.truthy(actorRequests >= 1,
    "nearby discovery did not refresh Core actor positions")

T.finish("dt_abstract_nearby_discovery_smoke")

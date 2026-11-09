local T = require "tests/support/test"

local commandHandlers = {}
local notifications = {}
local managerResults = {}
local bound

Events = {
    OnServerCommand = {
        Add = function(handler)
            commandHandlers[#commandHandlers + 1] = handler
        end,
    },
    OnGameStart = {
        Add = function() end,
    },
}

PsychopatzCore = {
    ActorNotifications = {
        Show = function(definition)
            notifications[#notifications + 1] = definition
            return true
        end,
    },
}

DTCommon = {
    MOD_ID = "DTCommon",
    T = function(_, fallback) return fallback end,
    Client = { Snapshots = {} },
    TraderManager = {
        SetResult = function(message, args)
            managerResults[#managerResults + 1] = {
                message = message,
                args = args,
            }
        end,
    },
}

DTHoomans = {
    MOD_ID = "DTHoomans",
    Client = {
        BindTrader = function(traderID, npcID, memberNPCIDs)
            bound = {
                traderID = traderID,
                npcID = npcID,
                memberNPCIDs = memberNPCIDs,
            }
        end,
    },
}

T.load("DTHoomans", "client", "DTHoomans/DTHoomans_Client.lua")

local function dispatch(command, args)
    for _, handler in ipairs(commandHandlers) do
        handler("DTHoomans", command, args)
    end
end

dispatch("TraderSpawnStarted", {
    requestID = "request:physical:1",
    factionID = "faction:physical:1",
})
dispatch("TraderSpawned", {
    accepted = true,
    traderID = "trader:physical:1",
    npcID = "npc:physical:1",
    memberNPCIDs = { "npc:physical:1", "npc:guard:1" },
    snapshot = { stockVersion = 1 },
})
dispatch("TraderSpawned", {
    accepted = false,
    traderID = "trader:physical:failed",
    reason = "spawn_failed",
})

T.equal(#notifications, 0,
    "DTHoomans lifecycle events opened an actor notification")
T.equal(#managerResults, 3,
    "DTHoomans lifecycle results did not reach the manager")
T.truthy(bound, "DTHoomans successful spawn did not bind the NPC")
T.equal(bound.traderID, "trader:physical:1",
    "DTHoomans binding lost trader identity")
T.equal(DTCommon.Client.Snapshots["trader:physical:1"].stockVersion, 1,
    "DTHoomans successful spawn lost its snapshot")
T.contains(managerResults[3].message, "spawn_failed",
    "DTHoomans failure result lost its reason")

T.finish("dt_hoomans_spawn_notification_policy_smoke")

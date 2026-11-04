local T = require "tests/support/test"
T.addPackagePaths()

local handlers = {}
Events = {
    OnClientCommand = {
        Add = function(callback)
            handlers[#handlers + 1] = callback
        end,
    },
}

local player = {}
getSpecificPlayer = function() return player end
getPlayer = function() return player end
triggerEvent = function(...)
    _G.loopback = { ... }
end
sendServerCommand = nil

DTCommon = {
    TraderWorld = {
        Tick = function() return {} end,
    },
    TraderService = {
        GetRecord = function(id)
            if id ~= "trader:abstract:loopback" then return nil end
            return {
                ca = {
                    actorID = "actor:abstract:loopback",
                },
            }
        end,
        ValidateTalkAccess = function()
            return true, "radio_access_granted"
        end,
    },
}

DTAbstract = {
    TraderWorldProvider = {
        releaseTrader = function() return true end,
    },
    SurvivorWorldRuntime = {
        FindGroupForActor = function() return nil end,
    },
}

local Server = T.load(
    "DTAbstract",
    "server",
    "DTAbstract/DTAbstract_Server.lua"
)
T.truthy(Server, "server module loaded")
T.equal(#handlers, 1, "server command hook registered")

handlers[1](
    "DTAbstract",
    "ConversationAccessRequest",
    player,
    {
        traderID = "trader:abstract:loopback",
        mode = "radio",
    }
)

T.truthy(loopback, "single-player conversation response looped back")
T.equal(loopback[1], "OnServerCommand", "loopback event")
T.equal(loopback[2], "DTAbstract", "loopback module")
T.equal(loopback[3], "ConversationAccessResult", "loopback command")
T.equal(loopback[4].accepted, true, "conversation access accepted")
T.equal(loopback[4].actorID, "actor:abstract:loopback",
    "canonical actor returned")

T.finish("dt_abstract_server_conversation_loopback_smoke")

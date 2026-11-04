local T = require "tests/support/test"
T.addPackagePaths()

local handlers = {}
Events = {
    OnServerCommand = {
        Add = function(callback)
            handlers[#handlers + 1] = callback
        end,
    },
}

local player = {}
getSpecificPlayer = function() return player end
getPlayer = function() return player end

local sent = {}
sendClientCommand = function(current, module, command, args)
    sent[#sent + 1] = {
        player = current,
        module = module,
        command = command,
        args = args,
    }
end

local opened
DTCommon = {
    TraderService = {
        GetRecord = function(id)
            if id ~= "trader:abstract:bridge" then return nil end
            return {
                n = "Remote Mara",
                ca = {
                    actorID = "actor:abstract:bridge",
                    provider = "DTAbstract",
                    providerState = "abstract",
                },
            }
        end,
    },
    CoreTraderConversation = {
        Open = function(traderID, actorID, options)
            opened = {
                traderID = traderID,
                actorID = actorID,
                options = options,
            }
            return opened
        end,
    },
}

DTAbstract = {}

local Bridge = T.load(
    "DTAbstract",
    "client",
    "DTAbstract/DTAbstract_CoreConversation.lua"
)

local requested, reason = Bridge.Request(
    "trader:abstract:bridge",
    "debug",
    {
        actorID = "actor:abstract:bridge",
        displayName = "Remote Mara",
    }
)
T.truthy(requested, reason)
T.equal(sent[1].command, "ConversationAccessRequest",
    "debug Talk uses server authorization")
T.equal(sent[1].args.mode, "debug",
    "debug mode preserved")
T.equal(opened, nil,
    "Core conversation opened before authorization")

for _, callback in ipairs(handlers) do
    callback("DTAbstract", "ConversationAccessResult", {
        accepted = true,
        traderID = "trader:abstract:bridge",
        actorID = "actor:abstract:bridge",
        mode = "debug",
        reason = "core_conversation_authorized",
    })
end

T.truthy(opened,
    "authorized bridge did not open Core conversation")
T.equal(opened.traderID, "trader:abstract:bridge",
    "Core bridge lost trader identity")
T.equal(opened.actorID, "actor:abstract:bridge",
    "Core bridge lost canonical actor identity")
T.equal(opened.options.displayName, "Remote Mara",
    "Core bridge lost display-name hint")
T.equal(opened.options.mode, "debug",
    "Core bridge lost authorization mode")

opened = nil
sent = {}
requested = Bridge.Request(
    "trader:abstract:bridge",
    "radio"
)
T.truthy(requested)
for _, callback in ipairs(handlers) do
    callback("DTAbstract", "ConversationAccessResult", {
        accepted = false,
        traderID = "trader:abstract:bridge",
        actorID = "actor:abstract:bridge",
        mode = "radio",
        reason = "radio_talk_unavailable",
    })
end
T.equal(opened, nil,
    "denied radio access still opened Core conversation")
T.equal(Bridge.LastResult.reason, "radio_talk_unavailable",
    "bridge retained server denial reason")

T.equal(PNC, nil,
    "DTAbstract Core bridge must not require ProjectHoomans globals")

T.finish("dt_abstract_core_conversation_bridge_smoke")

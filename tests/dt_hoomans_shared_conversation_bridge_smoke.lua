local T = require "tests/support/test"
T.addPackagePaths()

local handlers = {}
local sent
local opened
local player = {}
Events = {
    OnServerCommand = {
        Add = function(handler) handlers[#handlers + 1] = handler end,
    },
}
getSpecificPlayer = function() return player end
getPlayer = function() return player end
sendClientCommand = function(current, module, command, args)
    sent = { player = current, module = module, command = command, args = args }
end

local projection = {
    actorID = "actor:physical:bridge",
    displayName = "Physical Bea",
    provider = "DTHoomans",
    providerState = "materialized",
    portrait = { actorID = "actor:physical:bridge", face = {} },
    factionPresentation = { factionID = "faction:physical", glyph = "P" },
}
package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
] = function()
    return {
        GetActor = function(id)
            return id == projection.actorID and projection or nil
        end,
        GetPortraitSpec = function(entry)
            return entry == projection and entry.portrait or nil
        end,
    }
end

PsychopatzCore = {
    Conversation = {
        Open = function(spec)
            opened = spec
            return spec
        end,
    },
}
DTCommon = {
    TraderService = {
        GetRecord = function(id)
            if id ~= "trader:physical:bridge" then return nil end
            return {
                n = "Physical Bea",
                ca = {
                    actorID = projection.actorID,
                    provider = "DTHoomans",
                    providerState = "materialized",
                },
            }
        end,
    },
    Client = { OpenTrader = function() return true end },
}
DTHoomans = { MOD_ID = "DTHoomans" }

local Client = T.load(
    "DTHoomans",
    "client",
    "DTHoomans/DTHoomans_Client.lua"
)
local requested, reason = Client.RequestTraderConversation(
    "trader:physical:bridge",
    { mode = "physical", npcID = "merchant:physical" }
)
T.truthy(requested, reason)
T.equal(sent.command, "ConversationAccessRequest",
    "physical Talk did not request provider authorization")
T.equal(sent.args.mode, "physical",
    "physical Talk lost provider mode")

for _, handler in ipairs(handlers) do
    handler("DTHoomans", "ConversationAccessResult", {
        accepted = true,
        requestID = sent.args.requestID,
        traderID = "trader:physical:bridge",
        actorID = projection.actorID,
        mode = "physical",
    })
end
T.truthy(opened, "authorized physical Talk did not open shared content")
T.equal(opened.namespace, "DT.trader",
    "physical Talk opened provider-specific content")
T.equal(opened.context.provider, "DTHoomans",
    "physical Talk lost provider context")
T.equal(opened.context.actorID, projection.actorID,
    "physical Talk lost canonical actor identity")
T.equal(PNC, nil,
    "shared physical trader conversation must not require PNC content")

print("dt_hoomans_shared_conversation_bridge_smoke: PASS")

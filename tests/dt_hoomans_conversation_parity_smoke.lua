local T = require "tests/support/test"
T.addPackagePaths()

local registered
local requested
PNC = {
    Conversation = {
        Openers = {
            Register = function(spec)
                registered = spec
                return true, spec.id
            end,
        },
    },
}
DTHoomans = {
    Client = {
        RequestTraderConversation = function(traderID, options)
            requested = { traderID = traderID, options = options }
            return true, "access_requested"
        end,
    },
}

local records = {
    ["trader:physical"] = {
        ca = {
            actorID = "actor:physical",
            provider = "DTHoomans",
            providerState = "materialized",
        },
        p = "actor:physical",
        l = "actor:physical",
    },
}
DTCommon = {
    TraderService = {
        ForEach = function(callback)
            for id, record in pairs(records) do
                callback(id, record)
            end
        end,
    },
}
package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
] = function() return {} end

local Conversation = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_TraderConversation.lua"
)
local transportOK, transportReason =
    Conversation.RegisterProviderTransport(
        "DTHoomans",
        function(traderID, entry, player, options)
            return DTHoomans.Client.RequestTraderConversation(
                traderID,
                options
            )
        end
    )
T.truthy(transportOK, transportReason)
local registeredOK, registeredReason =
    Conversation.RegisterExternalOpener(PNC.Conversation.Openers)
T.truthy(registeredOK, registeredReason)
T.truthy(registered, "shared trader opener was not registered")
T.falsy(string.find(
    T.read("DTCommon", "client", "DTCommon/DTCommon_TraderConversation.lua"),
    "PNC",
    1,
    true
), "DTCommon trader conversation must not depend on PNC")
T.falsy(string.find(
    T.read("DTCommon", "client", "DTCommon/DTCommon_TraderConversation.lua"),
    "DTHoomans",
    1,
    true
), "DTCommon trader conversation must not depend on a provider")
T.equal(registered.id, "dynamictrading.trader",
    "trader opener identity changed")
T.truthy(registered.canOpen({ id = "actor:physical" }),
    "physical trader was not eligible for the shared Talk opener")

local result, reason = registered.open({ id = "actor:physical" }, {})
T.truthy(result, reason)
T.equal(requested.traderID, "trader:physical",
    "shared Talk opener lost the trader identity")
T.equal(requested.options.mode, "physical",
    "shared Talk opener did not use physical authorization")
T.equal(requested.options.npcID, "actor:physical",
    "shared Talk opener lost the selected NPC")
T.equal(Conversation.EXTERNAL_OPENER_ID, registered.id,
    "conversation opener is not owned by DTCommon")

T.finish("dt_hoomans_conversation_parity_smoke")

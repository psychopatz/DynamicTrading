local T = require "tests/support/test"
T.addPackagePaths()

PsychopatzCore = {}
require "PsychopatzCore/Semantics/PsychopatzSemantic"
require "DTCommon/DTCommon_SemanticPack"

local projection = {
    actorID = "actor:semantic:trader",
    displayName = "Semantic Mara",
    provider = "DTAbstract",
    providerState = "abstract",
    portrait = { actorID = "actor:semantic:trader", face = {} },
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

local traded
DTCommon = {
    TraderService = {
        GetRecord = function(id)
            if id ~= "trader:semantic" then return nil end
            return {
                n = "Semantic Mara",
                ca = {
                    actorID = projection.actorID,
                    provider = "DTAbstract",
                    providerState = "abstract",
                    destinationSettlementID = "settlement:dest",
                },
            }
        end,
    },
    PlacePresentation = {
        Resolve = function(id)
            return id == "settlement:dest" and "Rosewood Outpost" or nil
        end,
    },
    Client = {
        OpenTrader = function(id, options)
            traded = { id = id, options = options }
            return true
        end,
    },
}

local Conversation = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_TraderConversation.lua"
)
local spec = assert(Conversation.BuildSpec(
    "trader:semantic",
    projection.actorID,
    { mode = "debug" }
))
local service, reason = spec.actorConversation.createService({
    session = { conversationID = "conversation:semantic" },
})
T.truthy(service, reason)

local result = service:Submit("where are you heading", spec.context, {})
T.truthy(result and result.accepted, "semantic trader turn was rejected")
T.equal(#result.responses, 1,
    "semantic trader turn did not create one Core response")
T.equal(result.responses[1].text, "I'm heading toward Rosewood Outpost.",
    "semantic trader response lost DTCommon content")

local identityResult = service:Submit(
    "what is your name",
    spec.context,
    {}
)
T.truthy(identityResult and identityResult.accepted,
    "knowledge identity question was rejected by the semantic trader")
T.equal(identityResult.responses[1].text, "I'm Semantic Mara.",
    "knowledge identity question did not use the canonical actor name")

local tradeResult = service:Submit("trade", spec.context, {})
T.truthy(tradeResult and tradeResult.accepted,
    "semantic trader trade turn was rejected")
spec.actorConversation.onResult(
    nil,
    "trade",
    tradeResult,
    service
)
T.equal(traded.id, "trader:semantic",
    "semantic trade action lost trader identity")
T.equal(traded.options.actorID, projection.actorID,
    "semantic trade action lost canonical actor identity")

T.finish("dt_trader_semantic_service_smoke")

local T = require "tests/support/test"
T.addPackagePaths()

local projection = {
    actorID = "actor:guard:conversation",
    displayName = "Caravan Guard",
    role = "guard",
    provider = "DTAbstract",
    providerState = "abstract",
    portrait = { actorID = "actor:guard:conversation", face = {} },
}

package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
] = function()
    return {
        Resolve = function(id)
            return id == projection.actorID and projection or nil,
                id == projection.actorID and {
                    canonicalActorID = projection.actorID,
                } or "actor_not_found"
        end,
        GetActor = function(id)
            return id == projection.actorID and projection or nil
        end,
        GetPortraitSpec = function(entry)
            return entry == projection and projection.portrait or nil
        end,
    }
end

DTCommon = {
    TraderService = {
        GetRecord = function(id)
            if id ~= "trader:guard:conversation" then return nil end
            return {
                n = "Safe Passage Caravan",
                ca = {
                    actorID = projection.actorID,
                    provider = "DTAbstract",
                    providerState = "abstract",
                },
            }
        end,
    },
}

local Conversation = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_TraderConversation.lua"
)
local spec, reason = Conversation.BuildSpec(
    "trader:guard:conversation",
    projection.actorID,
    { role = "guard" }
)
T.truthy(spec, reason)
T.equal(spec.role, "guard", "guard role remains provider-neutral")
T.truthy(spec.greetingBlock,
    "guards use the shared Dynamic Trading greeting blocks")

local choices = {}
for _, choice in ipairs(spec.nodes.landing.choices or {}) do
    choices[choice.id] = choice
end
T.falsy(choices["DT.trade"],
    "guards do not receive the trade action without trade capability")
T.truthy(choices["DT.referral"],
    "guards receive the shared referral action")
T.truthy(choices["DT.rumors"],
    "guards receive the shared rumors action")
T.contains(choices["DT.referral"].response, "merchant",
    "guard referral action has a visible conversation response")

print("dt_guard_conversation_smoke: PASS")

local T = require "tests/support/test"
T.addPackagePaths()

local projections = {
    ["actor:trader:leader"] = {
        actorID = "actor:trader:leader",
        displayName = "Caravan Trader",
        provider = "DTAbstract",
        providerState = "abstract",
        role = "trader",
        factionID = "faction:caravan",
        factionName = "Safe Passage Supply Caravan",
        factionPresentation = { factionID = "faction:caravan", glyph = "C" },
        portrait = { actorID = "actor:trader:leader", face = {} },
    },
    ["actor:trader:guard"] = {
        actorID = "actor:trader:guard",
        displayName = "Caravan Guard",
        provider = "DTAbstract",
        providerState = "abstract",
        role = "guard",
        factionID = "faction:caravan",
        factionName = "Safe Passage Supply Caravan",
        factionPresentation = { factionID = "faction:caravan", glyph = "C" },
        portrait = { actorID = "actor:trader:guard", face = {} },
    },
}
local knowledgeRequests = 0
local knowledge = {
    ["actor:trader:leader"] = {
        state = "known",
        nameKnown = true,
        knownName = "Mara Voss",
        factionKnown = true,
        factionID = "faction:caravan",
        factionName = "Safe Passage Supply Caravan",
        revision = 3,
    },
    ["actor:trader:guard"] = {
        state = "known",
        nameKnown = true,
        knownName = "Cal Mercer",
        factionKnown = true,
        factionID = "faction:caravan",
        factionName = "Safe Passage Supply Caravan",
        revision = 4,
    },
}

package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
] = function()
    return {
        GetActor = function(id) return projections[id] end,
        GetPortraitSpec = function(entry) return entry.portrait end,
        RequestActorKnowledge = function()
            knowledgeRequests = knowledgeRequests + 1
            return true
        end,
        GetActorKnowledge = function(id) return knowledge[id] end,
    }
end

local record = {
    n = "Safe Passage Supply Caravan",
    g = "faction:caravan",
    l = "actor:trader:leader",
    m = { "actor:trader:leader", "actor:trader:guard" },
    ca = {
        actorID = "actor:trader:leader",
        provider = "DTAbstract",
        providerState = "abstract",
    },
}

DTCommon = {
    TraderService = {
        GetRecord = function(id)
            return id == "trader:roster" and record or nil
        end,
    },
}

local Conversation = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_TraderConversation.lua"
)

local spec, reason = Conversation.BuildSpec(
    "trader:roster",
    "actor:trader:leader",
    {}
)
T.truthy(spec, reason)
T.equal(knowledgeRequests, 1,
    "shared conversation requests actor knowledge through Core")
T.equal(spec.npcName, "Mara Voss",
    "shared conversation uses the learned actor name")
T.equal(spec.context.factionName, "Safe Passage Supply Caravan",
    "shared conversation keeps the learned faction presentation")
T.truthy(type(spec.roster) == "table" and #spec.roster == 2,
    "shared conversation exposes the complete trader roster")

local nextChoice
for _, choice in ipairs(spec.nodes.landing.choices or {}) do
    if choice.id == "next_person" then nextChoice = choice end
end
T.truthy(nextChoice,
    "shared trader conversation exposes a next-person choice for guards")
T.equal(nextChoice.text, "Talk to the next person.",
    "next-person choice has shared trader wording")

local refreshed
local nextSession = {
    view = {
        refreshConversationSpec = function(_, nextSpec)
            refreshed = nextSpec
        end,
    },
}
T.truthy(nextChoice.action({}, nextChoice, nextSession),
    "next-person action refreshes the shared conversation view")
T.equal(refreshed.npcID, "actor:trader:guard",
    "next-person action selects the next canonical actor")

print("dt_trader_roster_conversation_smoke: PASS")

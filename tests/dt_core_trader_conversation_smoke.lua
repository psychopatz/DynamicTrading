local T = require "tests/support/test"
T.addPackagePaths()

local projection = {
    actorID = "actor:core:trader",
    displayName = "Core Mara",
}
local portrait = {
    actorID = "actor:core:trader",
    appearance = {
        hairModel = "Long",
    },
    equipment = {
        worn = {
            Torso_Upper = "Base.Tshirt",
        },
    },
}
package.preload[
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
] = function()
    return {
        GetActor = function(actorID)
            return actorID == projection.actorID
                and projection or nil
        end,
        Resolve = function(actorID)
            if actorID == projection.actorID or actorID == "npc:legacy" then
                return projection, {
                    canonicalActorID = projection.actorID,
                    aliasKind = actorID == projection.actorID
                        and "canonical" or "alias",
                }
            end
            return nil, "actor_not_found"
        end,
        GetPortraitSpec = function(entry)
            return entry == projection and portrait or nil
        end,
    }
end

local openedSpec
getModFileReader = function(modID, path)
    if modID ~= "PsychopatzCore" then return nil end
    local file = io.open(T.path("PsychopatzCore", "common_mod", path), "r")
    if not file then return nil end
    return {
        readLine = function() return file:read("*l") end,
        close = function() file:close() end,
    }
end
PsychopatzCore = {
    Conversation = {
        Open = function(spec)
            openedSpec = spec
            return { spec = spec }
        end,
    },
}

local tradeOpened
DTCommon = {
    TraderService = {
        GetRecord = function(id)
            if id ~= "trader:core" then return nil end
            return {
                n = "Core Mara",
                ca = {
                    actorID = projection.actorID,
                    destinationSettlementID = "community_dest",
                    originSettlementID = "community_origin",
                },
            }
        end,
    },
    PlacePresentation = {
        Resolve = function(id)
            if id == "community_dest" then return "Rosewood Outpost" end
            if id == "community_origin" then return "March Ridge Depot" end
            return nil
        end,
    },
    WorldKnowledge = {
        BuildConversationContext = function()
            return {
                npcGossip = {
                    statements = {
                        "I heard about a BANDIT RAID at West Point.",
                    },
                },
            }
        end,
    },
    Client = {
        OpenTrader = function(id, options)
            tradeOpened = { id = id, options = options }
            return true
        end,
    },
}

local Conversation = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_TraderConversation.lua"
)

local spec, reason = Conversation.BuildSpec(
    "trader:core",
    projection.actorID,
    {}
)
T.truthy(spec, reason)
T.equal(spec.npcID, projection.actorID,
    "Core conversation keeps canonical actor identity")
T.equal(spec.portrait.equipment.worn.Torso_Upper, "Base.Tshirt",
    "Core conversation keeps canonical clothing portrait")
T.falsy(spec.context.abstractOnly,
    "shared Core conversation retained abstract-only policy")
T.truthy(type(spec.actorConversation) == "table",
    "shared trader conversation does not expose the Core semantic host")
T.truthy(type(spec.actorConversation.createService) == "function",
    "shared trader conversation does not provide an actor service factory")
T.truthy(type(spec.actorConversation.onResult) == "function",
    "shared trader conversation does not provide a semantic result handler")
T.truthy(type(spec.extensionParts) == "table"
    and spec.extensionParts[1]
    and spec.extensionParts[1].partID == "llmInput",
    "shared trader conversation does not mount the Core semantic input")
local landing = spec.nodes.landing
T.truthy(landing, "Core trader conversation exposes a shared landing node")
local function choiceByID(id)
    for _, choice in ipairs(landing.choices or {}) do
        if choice.id == id then return choice end
    end
    return nil
end
T.equal(#landing.choices, 10,
    "Core trader conversation exposes expected landing choices")
T.equal(choiceByID("core.small_talk.weather").text,
    "Some weather we're having.",
    "Core trader conversation uses the shared small-talk catalog")
local nicknameChoice = choiceByID("core.question.identity_nickname")
T.truthy(nicknameChoice,
    "Core trader conversation exposes the generated nickname identity choice")
T.equal(nicknameChoice.response(),
    "I don't really use a nickname.",
    "nickname response uses the Core identity knowledge state")
local surnameChoice = choiceByID("core.question.identity_surname")
T.truthy(surnameChoice,
    "Core trader conversation exposes the generated surname identity choice")
T.equal(choiceByID("destination").response(),
    "I'm heading toward Rosewood Outpost.",
    "destination response uses human-facing place presentation")
T.equal(choiceByID("origin").response(),
    "I came from March Ridge Depot.",
    "origin response uses human-facing place presentation")
T.contains(choiceByID("DT.rumors").response(), "BANDIT RAID",
    "road news uses shared WorldKnowledge")

local aliasSpec, aliasReason = Conversation.BuildSpec(
    "trader:core",
    "npc:legacy",
    {}
)
T.truthy(aliasSpec, aliasReason)
T.equal(aliasSpec.npcID, projection.actorID,
    "conversation resolves legacy actor aliases to the canonical ID")
T.equal(aliasSpec.sourceActorID, "npc:legacy",
    "conversation preserves the source actor reference")

projection.capabilities = { ["DT.trade"] = true }
local companionSpec, companionReason = Conversation.BuildSpec(
    "trader:core",
    projection.actorID,
    { role = "companion" }
)
T.truthy(companionSpec, companionReason)
T.equal(companionSpec.role, "companion",
    "conversation preserves a non-specialized actor role")
T.truthy(companionSpec.context.capabilities["DT.trade"],
    "conversation uses the shared actor trading capability")

choiceByID("DT.trade").action()
T.equal(tradeOpened.id, "trader:core",
    "Trade action keeps trader identity")
T.equal(tradeOpened.options.actorID, projection.actorID,
    "Trade action keeps Core actor identity")

local view, openReason = Conversation.Open(
    "trader:core",
    projection.actorID,
    {}
)
T.truthy(view, openReason)
T.truthy(openedSpec,
    "Open did not forward a Core conversation spec")
T.equal(openedSpec.npcID, spec.npcID,
    "Open keeps canonical Core actor identity")
T.equal(openedSpec.portrait.equipment.worn.Torso_Upper,
    "Base.Tshirt",
    "Open keeps canonical clothing portrait")

T.equal(PNC, nil,
    "Core trader conversation must not depend on ProjectHoomans")

T.finish("dt_core_trader_conversation_smoke")

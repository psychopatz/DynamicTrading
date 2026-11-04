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
        GetPortraitSpec = function(entry)
            return entry == projection and portrait or nil
        end,
    }
end

local openedSpec
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
T.equal(#spec.nodes.root.choices, 5,
    "Core trader conversation exposes expected root choices")
T.equal(spec.nodes.root.choices[2].response(),
    "I'm heading toward Rosewood Outpost.",
    "destination response uses human-facing place presentation")
T.equal(spec.nodes.root.choices[3].response(),
    "I came from March Ridge Depot.",
    "origin response uses human-facing place presentation")
T.contains(spec.nodes.root.choices[4].response(), "BANDIT RAID",
    "road news uses shared WorldKnowledge")

spec.nodes.root.choices[1].action()
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

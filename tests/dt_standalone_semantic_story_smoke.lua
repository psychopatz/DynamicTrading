local T = require "tests/support/test"
T.addPackagePaths()

local coreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY") or "../psychopatzCore"
package.path = coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. package.path

-- Ensure PNC / ProjectHoomans is NOT defined
PNC = nil
ProjectHoomans = nil

PsychopatzCore = PsychopatzCore or {}
local Semantics = require "PsychopatzCore/Semantics/PsychopatzSemantic"
local PackRegistry = Semantics.PackRegistry
local CoreActors = require "PsychopatzCore/Actors/PsychopatzActors"
local Social = CoreActors.Social

-- Initialize standalone DT
DTCommon = {
    STATUS_READY = "READY",
    Storage = { IsAuthority = function() return true end },
    T = function(_, fallback) return fallback end,
}

-- Load DT Semantic Pack
T.load("DTCommon", "shared", "DTCommon/DTCommon_SemanticPack.lua")
local DT_Pack = DTCommon.SemanticPack
T.truthy(DT_Pack, "DT Semantic Pack loaded")

-- Verify pack registered in Core Semantics
local pack = Semantics.GetPack("pack.dynamictrading.trader_story")
T.truthy(pack, "Dynamic Trading pack registered in Core")
T.equal(pack.ownerModID, "DynamicTrading", "pack owner is DynamicTrading")

-- 1. Action collection in DT standalone mode
local dtActions = Semantics.CollectActions({
    capabilities = {
        ["core.conversation"] = true,
        ["dynamictrading.trade"] = true,
    },
    traderRole = "trader",
})
T.truthy(#dtActions >= 1, "DT actions collected")
T.equal(dtActions[1].id, "dynamictrading.trade", "trade choice available for trader")

-- 2. Guard action collection: guard gets referral choice
local guardActions = Semantics.CollectActions({
    capabilities = {
        ["core.conversation"] = true,
        ["dynamictrading.trade"] = true,
    },
    traderRole = "guard",
})
T.truthy(#guardActions >= 1, "guard actions collected")
T.equal(guardActions[1].id, "dynamictrading.referral", "referral choice available for guard")

-- 3. Relationship-aware greeting selection via dialogue blocks
-- Stranger: approval = 0
local strangerContext = {
    capabilities = { ["core.conversation"] = true, ["dynamictrading.trade"] = true },
    traderRole = "trader",
    actor = {
        relationship = { approval = 0, respect = 0, familiarity = 0 },
    },
}
local strangerBlock = Semantics.SelectDialogueBlock("greeting", strangerContext, "seed1")
T.truthy(strangerBlock, "stranger block selected")
T.equal(strangerBlock.id, "dt_block_greeting_neutral", "neutral block for approval 0")
T.equal(strangerBlock.nodes.opening.fallback, "Welcome. Looking to buy or sell?", "neutral greeting text")

-- Friend: approval = 30
local friendContext = {
    capabilities = { ["core.conversation"] = true, ["dynamictrading.trade"] = true },
    traderRole = "trader",
    actor = {
        relationship = { approval = 30, respect = 15, familiarity = 20 },
    },
}
local friendBlock = Semantics.SelectDialogueBlock("greeting", friendContext, "seed2")
T.truthy(friendBlock, "friend block selected")
T.equal(friendBlock.id, "dt_block_greeting_friend", "friendly block for approval >= 25")
T.equal(friendBlock.nodes.opening.fallback,
    "Good to see you again, friend! What can I trade for you today?", "friend greeting text")

-- 4. Rumors and stories
local friendRumor = Semantics.SelectDialogueBlock("rumor", friendContext, "seed3")
T.truthy(friendRumor, "friend rumor block selected")
T.equal(friendRumor.id, "dt_block_rumors_friend", "high-trust rumor for friend")

local strangerRumor = Semantics.SelectDialogueBlock("rumor", strangerContext, "seed4")
T.truthy(strangerRumor, "stranger rumor block selected")
T.equal(strangerRumor.id, "dt_block_rumors_neutral", "general rumor for stranger")

-- 5. Full conversation turn with DTCommon_TalkService
T.load("DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
T.load("DTCommon", "shared", "DTCommon/DTCommon_TraderService.lua")
T.load("DTCommon", "shared", "DTCommon/DTCommon_WorldKnowledge.lua")
T.load("DTCommon", "shared", "DTCommon/DTCommon_TalkService.lua")
local TalkService = DTCommon.TalkService

local registry = CoreActors.NewRegistry()
PsychopatzCore.Actors = CoreActors
PsychopatzCore.Actors.DefaultRegistry = registry

local coreActor = registry:Create({
    actorId = "actor:dt:standalone:mara",
    identitySeed = "seed-mara-trader",
    archetypeID = "trader.general",
    providerLease = { leaseID = "lease:mara", provider = "DTAbstract", owner = "DynamicTrading" },
})
T.truthy(coreActor, "Core actor created")

-- Set friendly relationship to player:user:alice
registry:Commit(coreActor.actorId, {
    social = {
        relationships = {
            ["player:user:alice"] = {
                approval = 40,
                respect = 20,
                familiarity = 25,
            },
        },
    },
})

local traderRecord = {
    s = "READY",
    v = 1,
    b = 500,
    ca = { actorID = coreActor.actorId, providerRevision = 1, role = "trader" },
}

DTCommon.TraderService.GetRecord = function(id) return traderRecord end
DTCommon.TraderService.ValidateTalkAccess = function() return true end

local playerAlice = {
    getUsername = function() return "alice" end,
}

local session, sessionReason = TalkService.Open(playerAlice, "trader:standalone", "radio")
T.truthy(session, sessionReason)

-- Submit greeting
local turn, turnErr = TalkService.Submit(playerAlice, "trader:standalone", session.sessionID, "hello", {
    mode = "radio",
    requestID = "turn-hello",
})
T.truthy(turn, turnErr)
T.truthy(turn.result, "turn result present")
T.truthy(turn.result.responses[1], "turn response present")
-- Verified relationship-aware response delivered:
T.equal(turn.result.responses[1].text,
    "Good to see you again, friend! What can I trade for you today?",
    "friend greeting delivered based on Core Social relationship!")

-- Verified action choices collected in turn result:
T.truthy(turn.result.actions, "turn actions present")
T.equal(turn.result.actions[1].id, "dynamictrading.trade", "trade choice offered")

T.finish("dt_standalone_semantic_story_smoke")

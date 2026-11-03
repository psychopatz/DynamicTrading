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
local simulatedStorage = { v = 1, r = 0, t = {} }
DTCommon = {
    STATUS_READY = "READY",
    Storage = {
        IsAuthority = function() return true end,
        GetData = function() return simulatedStorage end,
        Touch = function() simulatedStorage.r = simulatedStorage.r + 1 end,
        Transmit = function() end,
    },
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
local Policy = T.load("DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
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
    traderID = "trader:standalone",
    s = "READY",
    v = 1,
    b = 500,
    ca = { actorID = coreActor.actorId, providerRevision = 1, role = "trader" },
}

DTCommon.TraderService.GetRecord = function(id)
    if simulatedStorage and simulatedStorage.t and simulatedStorage.t[id] then
        return simulatedStorage.t[id]
    end
    return traderRecord
end
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

-- 6. P15 Standalone Utterance Families & Factual Grounding Verification
-- A. Parsing verification across all mandatory families
local parsedWho = Semantics.Parse("who are you", { capabilities = { ["dynamictrading.trade"] = true } })
T.truthy(parsedWho, "Parses 'who are you'")
T.equal(parsedWho.intent, "QUESTION", "Intent is QUESTION")
T.equal(parsedWho.speechAct, "act.trade.ask_who", "Speech act is act.trade.ask_who")

local parsedWhoTrade = Semantics.Parse("who handles trading", { capabilities = { ["dynamictrading.trade"] = true } })
T.truthy(parsedWhoTrade, "Parses 'who handles trading'")
T.equal(parsedWhoTrade.speechAct, "act.trade.ask_who")

local parsedWhereTrader = Semantics.Parse("where is the trader", { capabilities = { ["dynamictrading.trade"] = true } })
T.truthy(parsedWhereTrader, "Parses 'where is the trader'")
T.equal(parsedWhereTrader.speechAct, "act.trade.ask_who")

local parsedWhereHeading = Semantics.Parse("where are you heading", { capabilities = { ["dynamictrading.trade"] = true } })
T.truthy(parsedWhereHeading, "Parses 'where are you heading'")
T.equal(parsedWhereHeading.speechAct, "act.trade.ask_whereabouts")

local parsedWhereFrom = Semantics.Parse("where did you come from", { capabilities = { ["dynamictrading.trade"] = true } })
T.truthy(parsedWhereFrom, "Parses 'where did you come from'")
T.equal(parsedWhereFrom.speechAct, "act.trade.ask_whereabouts")

local parsedWhereSettlement = Semantics.Parse("where is the settlement", { capabilities = { ["dynamictrading.trade"] = true } })
T.truthy(parsedWhereSettlement, "Parses 'where is the settlement'")
T.equal(parsedWhereSettlement.speechAct, "act.trade.ask_whereabouts")

local parsedWhatSettlement = Semantics.Parse("what settlement are you going to", { capabilities = { ["dynamictrading.trade"] = true } })
T.truthy(parsedWhatSettlement, "Parses 'what settlement are you going to'")
T.equal(parsedWhatSettlement.speechAct, "act.trade.ask_whereabouts")

local parsedRoadNews = Semantics.Parse("road news", { capabilities = { ["dynamictrading.trade"] = true } })
T.truthy(parsedRoadNews, "Parses 'road news'")
T.equal(parsedRoadNews.intent, "GOSSIP", "road news intent is GOSSIP")

local parsedStory = Semantics.Parse("tell me a caravan story", { capabilities = { ["dynamictrading.trade"] = true } })
T.truthy(parsedStory, "Parses 'tell me a caravan story'")
T.equal(parsedStory.intent, "GOSSIP", "story intent is GOSSIP")

local parsedGoodbye = Semantics.Parse("goodbye", { capabilities = { ["dynamictrading.trade"] = true } })
T.truthy(parsedGoodbye, "Parses 'goodbye'")
T.equal(parsedGoodbye.intent, "FAREWELL", "farewell intent is FAREWELL")

local parsedBuy = Semantics.Parse("buy", { capabilities = { ["dynamictrading.trade"] = true } })
T.truthy(parsedBuy, "Parses 'buy'")
T.equal(parsedBuy.intent, "TRADE")

local parsedSell = Semantics.Parse("sell", { capabilities = { ["dynamictrading.trade"] = true } })
T.truthy(parsedSell, "Parses 'sell'")
T.equal(parsedSell.intent, "TRADE")

local parsedTrade = Semantics.Parse("trade", { capabilities = { ["dynamictrading.trade"] = true } })
T.truthy(parsedTrade, "Parses 'trade'")
T.equal(parsedTrade.intent, "TRADE")

-- B. Dialogue block selection
local traderIdentityBlock = Semantics.SelectDialogueBlock("identity", {
    traderRole = "trader",
    capabilities = { ["dynamictrading.trade"] = true },
})
T.truthy(traderIdentityBlock, "trader identity block selected")
T.equal(traderIdentityBlock.id, "dt_block_who_trader")

local guardIdentityBlock = Semantics.SelectDialogueBlock("identity", {
    traderRole = "guard",
    capabilities = { ["dynamictrading.trade"] = true },
})
T.truthy(guardIdentityBlock, "guard identity block selected")
T.equal(guardIdentityBlock.id, "dt_block_who_guard")

local friendWhereabouts = Semantics.SelectDialogueBlock("whereabouts", friendContext, "seed_where")
T.truthy(friendWhereabouts, "friend whereabouts selected")
T.equal(friendWhereabouts.id, "dt_block_whereabouts_friend")

local strangerWhereabouts = Semantics.SelectDialogueBlock("whereabouts", strangerContext, "seed_where2")
T.truthy(strangerWhereabouts, "stranger whereabouts selected")
T.equal(strangerWhereabouts.id, "dt_block_whereabouts_neutral")

-- C. TalkService Turn Submission & Factual Grounding (P15B)

-- 1. Identity question
local turnWho, turnWhoErr = TalkService.Submit(playerAlice, "trader:standalone", session.sessionID, "who are you", {
    mode = "radio",
    requestID = "turn-who",
})
T.truthy(turnWho, turnWhoErr)
T.equal(turnWho.result.responses[1].text,
    "I'm the caravan trader. If you need supplies, weapons, or provisions, I'm the one to talk to.",
    "trader identity delivered via TalkService")

-- 2. Where is the trader (speaker is trader)
local turnWhereTrader, turnWhereTraderErr = TalkService.Submit(playerAlice, "trader:standalone", session.sessionID, "where is the trader", {
    mode = "radio",
    requestID = "turn-where-trader",
})
T.truthy(turnWhereTrader, turnWhereTraderErr)
T.equal(turnWhereTrader.result.responses[1].text,
    "I'm the caravan trader. I'm right here if you need supplies or goods.",
    "trader says they are right here")

-- 3. UNGROUNDED (NO EVIDENCE) Destination check: must return bounded uncertainty, NOT hardcoded fiction
local turnWhereUnk, turnWhereUnkErr = TalkService.Submit(playerAlice, "trader:standalone", session.sessionID, "where are you heading", {
    mode = "radio",
    requestID = "turn-where-unk",
})
T.truthy(turnWhereUnk, turnWhereUnkErr)
T.equal(turnWhereUnk.result.responses[1].text,
    "I cannot confirm where we are heading next; route orders haven't been finalized.",
    "unseeded destination yields bounded uncertainty")

-- 4. GROUNDED (KNOWN EVIDENCE) Destination check: seed destination via Policy
Policy.SetDestinationSettlement(traderRecord, "West Point Outpost")
local turnWhereGrounded, turnWhereGroundedErr = TalkService.Submit(playerAlice, "trader:standalone", session.sessionID, "where are you heading", {
    mode = "radio",
    requestID = "turn-where-grounded",
})
T.truthy(turnWhereGrounded, turnWhereGroundedErr)
T.equal(turnWhereGrounded.result.responses[1].text,
    "We are heading toward West Point Outpost.",
    "grounded destination rendered from production Policy state")

-- 5. GROUNDED Origin check: seed origin via Policy
Policy.SetOriginSettlement(traderRecord, "March Ridge Depot")
local turnOrigGrounded, turnOrigGroundedErr = TalkService.Submit(playerAlice, "trader:standalone", session.sessionID, "where did you come from", {
    mode = "radio",
    requestID = "turn-orig-grounded",
})
T.truthy(turnOrigGrounded, turnOrigGroundedErr)
T.equal(turnOrigGrounded.result.responses[1].text,
    "We came from March Ridge Depot.",
    "grounded origin rendered from production Policy state")

-- 6. GROUNDED Settlement check: seed settlement via Policy with distinct canonical ID vs display name (P19B)
DTCommon.PlacePresentation.RegisterResolver("test_community_resolver", function(id)
    if id == "community_123_456" then return "Riverside Safehouse" end
    if id == "community_dest_789" then return "West Point Outpost" end
    if id == "community_orig_321" then return "March Ridge Depot" end
    return nil
end, 100)

Policy.SetCurrentSettlement(traderRecord, "community_123_456")
local turnSettGrounded, turnSettGroundedErr = TalkService.Submit(playerAlice, "trader:standalone", session.sessionID, "where is the settlement", {
    mode = "radio",
    requestID = "turn-sett-grounded",
})
T.truthy(turnSettGrounded, turnSettGroundedErr)
T.equal(turnSettGrounded.result.responses[1].text,
    "Our primary trading settlement is Riverside Safehouse.",
    "grounded settlement rendered with human-facing display name")
T.falsy(string.find(turnSettGrounded.result.responses[1].text, "community_123_456"),
    "raw machine ID does not leak into player dialogue")
T.equal(turnSettGrounded.result.responses[1].evidence, "community_123_456",
    "exact canonical machine ID preserved in evidence")

-- 6B. Unresolvable machine ID produces bounded uncertainty instead of leaking raw machine string
Policy.SetDestinationSettlement(traderRecord, "community_999_unknown_raw")
local turnUnres, turnUnresErr = TalkService.Submit(playerAlice, "trader:standalone", session.sessionID, "where are you heading", {
    mode = "radio",
    requestID = "turn-dest-unres",
})
T.truthy(turnUnres, turnUnresErr)
T.equal(turnUnres.result.responses[1].text,
    "I cannot confirm where we are heading next; route orders haven't been finalized.",
    "unresolvable machine ID produces bounded uncertainty")
T.falsy(string.find(turnUnres.result.responses[1].text, "community_999_unknown_raw"),
    "unresolvable machine ID never leaks into dialogue")

-- 7A. UNGROUNDED News check: no seeded news -> bounded no-news
local turnNoNews, turnNoNewsErr = TalkService.Submit(playerAlice, "trader:standalone", session.sessionID, "road news", {
    mode = "radio",
    requestID = "turn-no-news",
})
T.truthy(turnNoNews, turnNoNewsErr)
T.equal(turnNoNews.result.responses[1].text,
    "I haven't heard any news lately.",
    "unseeded road news yields bounded no-news")

-- 7B. GROUNDED News check: publish and acquire real fact through WorldKnowledge
local CoreWK = require "PsychopatzCore/WorldKnowledge/PsychopatzWorldKnowledge"
CoreWK.Reset({ maxFacts = 16, maxActors = 8, maxRefs = 8 })
local publishedFact, pubErr = DTCommon.WorldKnowledge.Publish({
    factID = "fact:market:food-shortage:rosewood",
    kind = "market.event",
    subject = { id = "rosewood", kind = "settlement" },
    payload = {
        eventType = "FOOD SHORTAGE",
        marketID = "rosewood",
    },
})
T.truthy(publishedFact, pubErr)
local acquired, acqErr = DTCommon.WorldKnowledge.Acquire("trader:standalone", "fact:market:food-shortage:rosewood", {
    authorized = true,
    provenance = "witnessed",
    confidence = 90,
})
T.truthy(acquired, acqErr)

local turnNewsGrounded, turnNewsErr = TalkService.Submit(playerAlice, "trader:standalone", session.sessionID, "road news", {
    mode = "radio",
    requestID = "turn-news-grounded",
})
T.truthy(turnNewsGrounded, turnNewsErr)
T.truthy(turnNewsGrounded.result.responses[1].evidence, "evidence attached from real fact")
T.equal(turnNewsGrounded.result.responses[1].evidence, "fact:market:food-shortage:rosewood", "exact fact ID returned as evidence")
T.contains(turnNewsGrounded.result.responses[1].text, "FOOD SHORTAGE", "response text derived from published market event")

-- 8. Caravan Story check (Authored non-factual flavor)
local turnStory, turnStoryErr = TalkService.Submit(playerAlice, "trader:standalone", session.sessionID, "tell me a caravan story", {
    mode = "radio",
    requestID = "turn-story",
})
T.truthy(turnStory, turnStoryErr)
T.equal(turnStory.result.responses[1].text,
    "I remember a run through Muldraugh back when the fog was thick... barely made it out with the wagon wheels intact.",
    "caravan story delivered")

-- 9. Farewell / Goodbye check
local turnFarewell, turnFarewellErr = TalkService.Submit(playerAlice, "trader:standalone", session.sessionID, "goodbye", {
    mode = "radio",
    requestID = "turn-farewell",
})
T.truthy(turnFarewell, turnFarewellErr)
T.equal(turnFarewell.result.responses[1].text,
    "Safe travels out there, friend. Until our next deal.",
    "friendly farewell delivered based on relationship approval")

-- 10. RECONSTRUCTED PERSISTENCE & RELOAD (P20B)
local function deepCopy(value)
    if type(value) ~= "table" then return value end
    local res = {}
    for k, v in pairs(value) do
        res[deepCopy(k)] = deepCopy(v)
    end
    return res
end

-- 1. Establish trader state through production owners
Policy.SetHomeSettlement(traderRecord, "community_123_456")
Policy.SetCurrentSettlement(traderRecord, "community_123_456")
Policy.SetOriginSettlement(traderRecord, "community_orig_321")
Policy.SetDestinationSettlement(traderRecord, "community_dest_789")

-- 2. Obtain actual DT storage representation and persist WorldKnowledge
local storageData = DTCommon.Storage.GetData()
storageData.t = storageData.t or {}
storageData.t[traderRecord.traderID or traderRecord.id or traderRecord.t] = traderRecord
local savedPayload = DTCommon.WorldKnowledge.Save()
T.truthy(savedPayload, "WorldKnowledge successfully saved to storage")

-- 3. Produce a persisted snapshot/deep copy representing Global ModData
local persistedSnapshot = deepCopy(storageData)

-- 4. Tear down / reset relevant runtime state
local originalTrader = traderRecord
TalkService.Sessions = {}
CoreWK.Reset({ maxFacts = 16, maxActors = 8, maxRefs = 8 })
traderRecord = nil

-- 5. Replace DT storage using a fresh table reconstructed from the persisted snapshot
simulatedStorage = deepCopy(persistedSnapshot)

-- 6. Retrieve trader record again from fresh storage
local reloadedData = DTCommon.Storage.GetData()
local reloadedTrader = reloadedData.t["trader:standalone"]
T.truthy(reloadedTrader, "persisted trader record retrieved from storage")

-- Mandatory assertion: reloaded trader record is a distinct Lua object!
T.truthy(reloadedTrader ~= originalTrader, "reloaded trader record is a distinct reconstructed Lua object")
-- Canonical values match
T.equal(reloadedTrader.ca.destinationSettlementID, "community_dest_789", "canonical destination survived")
T.equal(reloadedTrader.ca.originSettlementID, "community_orig_321", "canonical origin survived")
T.equal(reloadedTrader.ca.currentSettlementID, "community_123_456", "canonical current survived")
T.equal(reloadedTrader.ca.homeSettlementID, "community_123_456", "canonical home survived")

-- 7. Call WorldKnowledge.Load() against reconstructed storage
local loadOk, loadErr = DTCommon.WorldKnowledge.Load()
T.truthy(loadOk, loadErr)

-- 8. Re-open TalkService session and query
local reloadedSession, sessErr = TalkService.Open(playerAlice, "trader:standalone", "radio")
T.truthy(reloadedSession, sessErr)

-- Destination query
local turnDestReload, turnDestReloadErr = TalkService.Submit(playerAlice, "trader:standalone", reloadedSession.sessionID, "where are you going", {
    mode = "radio",
    requestID = "turn-dest-reload",
})
T.truthy(turnDestReload, turnDestReloadErr)
T.equal(turnDestReload.result.responses[1].text, "We are heading toward West Point Outpost.", "reloaded destination resolves display name")
T.equal(turnDestReload.result.responses[1].evidence, "community_dest_789", "reloaded destination preserves canonical machine ID evidence")
T.falsy(string.find(turnDestReload.result.responses[1].text, "community_dest_789"), "destination machine ID is not leaked")

-- Origin query
local turnOrigReload, turnOrigReloadErr = TalkService.Submit(playerAlice, "trader:standalone", reloadedSession.sessionID, "where did you come from", {
    mode = "radio",
    requestID = "turn-orig-reload",
})
T.truthy(turnOrigReload, turnOrigReloadErr)
T.equal(turnOrigReload.result.responses[1].text, "We came from March Ridge Depot.", "reloaded origin resolves display name")
T.equal(turnOrigReload.result.responses[1].evidence, "community_orig_321", "reloaded origin preserves canonical machine ID evidence")
T.falsy(string.find(turnOrigReload.result.responses[1].text, "community_orig_321"), "origin machine ID is not leaked")

-- Settlement query
local turnSettReload, turnSettReloadErr = TalkService.Submit(playerAlice, "trader:standalone", reloadedSession.sessionID, "where is the settlement", {
    mode = "radio",
    requestID = "turn-sett-reload",
})
T.truthy(turnSettReload, turnSettReloadErr)
T.equal(turnSettReload.result.responses[1].text, "Our primary trading settlement is Riverside Safehouse.", "reloaded settlement resolves display name")
T.equal(turnSettReload.result.responses[1].evidence, "community_123_456", "reloaded settlement preserves canonical machine ID evidence")
T.falsy(string.find(turnSettReload.result.responses[1].text, "community_123_456"), "settlement machine ID is not leaked")

-- Route query ("what route") - grounded in reloaded WorldKnowledge gossip fact
local turnRouteReload, turnRouteReloadErr = TalkService.Submit(playerAlice, "trader:standalone", reloadedSession.sessionID, "what route", {
    mode = "radio",
    requestID = "turn-route-reload",
})
T.truthy(turnRouteReload, turnRouteReloadErr)
T.contains(turnRouteReload.result.responses[1].text, "FOOD SHORTAGE", "reloaded route grounds in WorldKnowledge gossip")
T.equal(turnRouteReload.result.responses[1].evidence, "fact:market:food-shortage:rosewood", "reloaded route preserves canonical fact ID evidence")

-- Road news query
local turnNewsReload, turnNewsReloadErr = TalkService.Submit(playerAlice, "trader:standalone", reloadedSession.sessionID, "road news", {
    mode = "radio",
    requestID = "turn-news-reload",
})
T.truthy(turnNewsReload, turnNewsReloadErr)
T.contains(turnNewsReload.result.responses[1].text, "FOOD SHORTAGE", "reloaded world knowledge fact text survives")
T.equal(turnNewsReload.result.responses[1].evidence, "fact:market:food-shortage:rosewood", "reloaded fact ID evidence survives")

-- 9. Failure and Completion Persistence & Reload:
-- 9A. Save & reload coherent failed/offsite state
Policy.SetCurrentSettlement(reloadedTrader, nil)
Policy.SetDestinationSettlement(reloadedTrader, nil)
Policy.SetOriginSettlement(reloadedTrader, "community_orig_321")
Policy.SetAvailable(reloadedTrader, false, "resident_excursion_failed")
reloadedTrader.s = "AWAY"

local originalFailedTrader = reloadedTrader
local failedSnapshot = deepCopy(DTCommon.Storage.GetData())
TalkService.Sessions = {}
CoreWK.Reset({ maxFacts = 16, maxActors = 8, maxRefs = 8 })
simulatedStorage = deepCopy(failedSnapshot)

local reloadedFailedData = DTCommon.Storage.GetData()
local reloadedFailedTrader = reloadedFailedData.t["trader:standalone"]
T.truthy(reloadedFailedTrader, "failed trader record recovered")
T.truthy(reloadedFailedTrader ~= originalFailedTrader, "reloaded failed trader is distinct object")
T.falsy(reloadedFailedTrader.ca.currentSettlementID, "failed trader does NOT falsely become home after reload")
T.falsy(reloadedFailedTrader.ca.destinationSettlementID, "failed trader has no stale destination after reload")
T.equal(reloadedFailedTrader.ca.originSettlementID, "community_orig_321", "failed trader retains origin after reload")
T.equal(reloadedFailedTrader.s, "AWAY", "failed trader availability remains away")

local failedSession, failedSessErr = TalkService.Open(playerAlice, "trader:standalone", "radio")
T.truthy(failedSession, failedSessErr)
local turnFailedDest = TalkService.Submit(playerAlice, "trader:standalone", failedSession.sessionID, "where are you going", {
    mode = "radio", requestID = "turn-failed-dest",
})
T.equal(turnFailedDest.result.responses[1].text, "I cannot confirm where we are heading next; route orders haven't been finalized.", "failed trader yields bounded uncertainty for destination")

local turnFailedRoute = TalkService.Submit(playerAlice, "trader:standalone", failedSession.sessionID, "what route", {
    mode = "radio", requestID = "turn-failed-route",
})
T.equal(turnFailedRoute.result.responses[1].text, "We are currently operating around Riverside Safehouse.", "failed offsite trader resolves operating around home settlement")
T.equal(turnFailedRoute.result.responses[1].evidence, "community_123_456", "failed offsite route evidence is home settlement")

-- 9B. Save & reload completed AT_HOME state
Policy.SetCurrentSettlement(reloadedFailedTrader, "community_123_456")
Policy.SetOriginSettlement(reloadedFailedTrader, "community_123_456")
Policy.SetDestinationSettlement(reloadedFailedTrader, nil)
Policy.SetAvailable(reloadedFailedTrader, true, "resident_trader_home")
reloadedFailedTrader.s = "READY"

local originalHomeTrader = reloadedFailedTrader
local homeSnapshot = deepCopy(DTCommon.Storage.GetData())
TalkService.Sessions = {}
simulatedStorage = deepCopy(homeSnapshot)

local reloadedHomeData = DTCommon.Storage.GetData()
local reloadedHomeTrader = reloadedHomeData.t["trader:standalone"]
T.truthy(reloadedHomeTrader, "home trader record recovered")
T.truthy(reloadedHomeTrader ~= originalHomeTrader, "reloaded home trader is distinct object")
T.equal(reloadedHomeTrader.ca.currentSettlementID, "community_123_456", "reloaded home trader is at home")
T.falsy(reloadedHomeTrader.ca.destinationSettlementID, "stale destination does not reappear after reload")
T.equal(reloadedHomeTrader.s, "READY", "reloaded home trader is ready")

local homeSession, homeSessErr = TalkService.Open(playerAlice, "trader:standalone", "radio")
T.truthy(homeSession, homeSessErr)
local turnHomeDest = TalkService.Submit(playerAlice, "trader:standalone", homeSession.sessionID, "where are you going", {
    mode = "radio", requestID = "turn-home-dest",
})
T.equal(turnHomeDest.result.responses[1].text, "I cannot confirm where we are heading next; route orders haven't been finalized.", "completed AT_HOME trader yields bounded uncertainty (stale destination did not reappear)")

-- Route query when at home without gossip -> resolves home position
local turnHomeRoute = TalkService.Submit(playerAlice, "trader:standalone", homeSession.sessionID, "what route", {
    mode = "radio", requestID = "turn-home-route",
})
T.equal(turnHomeRoute.result.responses[1].text, "We are currently operating around Riverside Safehouse.", "at home trader resolves operating around home")
T.equal(turnHomeRoute.result.responses[1].evidence, "community_123_456", "at home route preserves canonical machine ID evidence")

T.finish("dt_standalone_semantic_story_smoke")

local T = require "tests/support/test"
T.addPackagePaths()

local coreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY")
    or "../psychopatzCore"
package.path = coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. package.path

PsychopatzCore = {}
local WorldKnowledge = require
    "PsychopatzCore/WorldKnowledge/PsychopatzWorldKnowledge"

local data = { t = {} }
local records = {}
DTCommon = {
    Storage = {
        IsAuthority = function() return true end,
        GetData = function() return data end,
        Touch = function() data.touched = (data.touched or 0) + 1 end,
        Transmit = function() data.transmitted = (data.transmitted or 0) + 1 end,
    },
    TraderService = {
        GetRecord = function(id) return records[id] end,
    },
}

local Policy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
local Adapter = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_WorldKnowledge.lua")

local actorA = "npc:dt:caravan-a"
local actorB = "npc:dt:caravan-b"
local actorC = "npc:dt:caravan-c"
records["trader:caravan-a"] = {
    ca = Policy.New({ actorID = actorA, providerRevision = 1 }),
}
records["trader:caravan-b"] = {
    ca = Policy.New({ actorID = actorB, providerRevision = 1 }),
}
records["trader:caravan-c"] = {
    ca = Policy.New({ actorID = actorC, providerRevision = 1 }),
}

Adapter.Reset({ maxFacts = 32, maxActors = 8, maxRefs = 8 })
local fact, factReason = Adapter.Publish({
    kind = "market.route",
    producer = "dynamictrading:route",
    eventID = "route:ridge:open",
    subject = { id = "route:ridge" },
    payload = { routeID = "route:ridge", marketID = "market:west" },
    occurredAt = 10,
    observedAt = 10,
    retention = "historical",
    confidence = 0.95,
})
T.truthy(fact, factReason)

local acquired, acquireReason = Adapter.Acquire("trader:caravan-a",
    fact.factID, {
        authorized = true,
        provenance = "experienced",
        source = "caravan_route_observation",
        acquisitionPath = "route_observation",
        confidence = 0.95,
        learnedAt = 10,
    })
T.truthy(acquired, acquireReason)

local context, contextReason = Adapter.BuildConversationContext(
    "trader:caravan-a", { now = 11 })
T.truthy(context, contextReason)
T.equal(context.traderID, "trader:caravan-a", "context trader identity")
T.equal(context.actorID, actorA, "context Core actor identity")
T.equal(context.npcGossip.factRefs[1], fact.factID,
    "context references the same fact")
T.contains(context.npcGossip.statements[1], "route:ridge",
    "DT renderer grounds the route statement")

local unknown = Adapter.BuildConversationContext("trader:caravan-b", { now = 11 })
T.equal(#unknown.npcGossip.statements, 0,
    "an uninformed trader has no gossip statement")

local transferred, transferReason = Adapter.Propagate(
    "trader:caravan-a", "trader:caravan-b", {
        authorized = true,
        channel = "conversation",
        now = 12,
    })
T.truthy(transferred, transferReason)
T.equal(transferred[1].factID, fact.factID,
    "propagation keeps the same fact ID")
T.equal(transferred[1].provenance, "told",
    "conversation propagation records told provenance")

local informed = Adapter.BuildConversationContext("trader:caravan-b", {
    now = 13,
})
T.equal(informed.npcGossip.factRefs[1], fact.factID,
    "recipient can discuss the same fact")
T.contains(informed.npcGossip.statements[1], "I heard",
    "recipient does not pretend to have witnessed it")

local explanation, explainReason = Adapter.Explain(
    "trader:caravan-b", fact.factID, 13)
T.truthy(explanation, explainReason)
T.equal(explanation.producer, "dynamictrading:route",
    "explainability retains DT producer")
T.equal(explanation.provenance, "told",
    "explainability retains transferred provenance")
T.equal(explanation.sourceActorID, actorA,
    "explainability retains source actor")

-- Provider hot-swaps keep the same trader binding and Core fact references.
local before = Adapter.BuildConversationContext("trader:caravan-a", { now = 14 })
records["trader:caravan-a"].ca.provider = "DTAbstract"
records["trader:caravan-a"].ca.providerState = "abstract"
records["trader:caravan-a"].ca.providerRevision = 2
local materialized = Adapter.BuildConversationContext("trader:caravan-a", {
    now = 15,
})
records["trader:caravan-a"].ca.provider = "DTHoomans"
records["trader:caravan-a"].ca.providerState = "materialized"
records["trader:caravan-a"].ca.providerRevision = 3
local released = Adapter.BuildConversationContext("trader:caravan-a", { now = 16 })
T.equal(before.actorID, actorA, "abstract stage retains actor ID")
T.equal(materialized.actorID, actorA, "physical stage retains actor ID")
T.equal(released.actorID, actorA, "release stage retains actor ID")
T.equal(released.npcGossip.factRefs[1], fact.factID,
    "provider hot-swap does not duplicate or lose knowledge")

local ephemeral = Adapter.Publish({
    kind = "market.route_probe",
    producer = "dynamictrading:route",
    eventID = "probe:1",
    retention = "ephemeral",
    observedAt = 20,
})
T.truthy(ephemeral, "ephemeral fact accepted at runtime")
local payload = Adapter.Save()
T.truthy(payload, "DT save payload")
T.equal(#payload.ledger.facts, 1,
    "ephemeral runtime observation is not persisted")
T.truthy(data.touched, "DT persistence was touched")
T.truthy(data.transmitted, "DT persistence was transmitted")

WorldKnowledge.Reset({ maxFacts = 32, maxActors = 8, maxRefs = 8 })
local loaded, loadReason = Adapter.Load()
T.truthy(loaded, loadReason)
local restored = Adapter.BuildConversationContext("trader:caravan-b", { now = 21 })
T.equal(restored.npcGossip.factRefs[1], fact.factID,
    "reload preserves intended historical trader knowledge")

-- Exercise the existing Core actor conversation service through DTCommon Talk:
-- the adapter supplies context, while the shared semantic router still owns
-- parsing and response selection.
local Semantics = require "PsychopatzCore/Semantics/PsychopatzSemantic"
local Knowledge = require "PsychopatzCore/Actors/PsychopatzActorKnowledge"
local actorObjects = {
    [actorA] = {
        actorId = actorA,
        identity = { displayName = "Caravan A" },
        persona = { selectionSetVersion = 1 },
        social = { personality = {}, relationships = {} },
        knowledge = Knowledge.NewState(),
    },
    [actorB] = {
        actorId = actorB,
        identity = { displayName = "Caravan B" },
        persona = { selectionSetVersion = 1 },
        social = { personality = {}, relationships = {} },
        knowledge = Knowledge.NewState(),
    },
    [actorC] = {
        actorId = actorC,
        identity = { displayName = "Caravan C" },
        persona = { selectionSetVersion = 1 },
        social = { personality = {}, relationships = {} },
        knowledge = Knowledge.NewState(),
    },
}
Policy.ResolveActor = function(record)
    local id = record and record.ca and record.ca.actorID
    return actorObjects[id], actorObjects[id] and nil or "actor_not_found"
end
DTCommon.STATUS_READY = "READY"
DTCommon.T = function(_, fallback) return fallback end
DTCommon.TraderService.ValidateTalkAccess = function(_, id, mode)
    if not records[id] then return false, "trader_not_found" end
    if mode ~= "radio" then return false, "wrong_mode" end
    return true
end
Semantics.Registry.Reset()
Semantics.Registry.RegisterPattern({
    id = "dt.world_knowledge.news",
    match = { { kind = "literal", value = "news" } },
    emit = { intent = "GOSSIP", speechAct = "QUESTION", subject = "SOCIAL" },
})
local Talk = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TalkService.lua")
local player = { getUsername = function() return "dt-world-knowledge" end }
local talkOpen, talkOpenReason = Talk.Open(
    player, "trader:caravan-a", "radio")
T.truthy(talkOpen, talkOpenReason)
T.equal(talkOpen.worldKnowledge.npcGossip.factRefs[1], fact.factID,
    "Talk opens with the shared fact reference")
local talkTurn, talkTurnReason = Talk.Submit(
    player, "trader:caravan-a", talkOpen.sessionID, "news", {
        mode = "radio", language = "EN", requestID = "dt-wkg-news",
    })
T.truthy(talkTurn, talkTurnReason)
T.contains(talkTurn.result.responses[1].text, "route:ridge",
    "Talk response is grounded in the DT fact")

local unknownOpen, unknownOpenReason = Talk.Open(
    player, "trader:caravan-c", "radio")
T.truthy(unknownOpen, unknownOpenReason)
local unknownTurn, unknownTurnReason = Talk.Submit(
    player, "trader:caravan-c", unknownOpen.sessionID, "news", {
        mode = "radio", language = "EN", requestID = "dt-wkg-no-news",
    })
T.truthy(unknownTurn, unknownTurnReason)
T.equal(unknownTurn.result.responses[1].text,
    "I haven't heard any news lately.",
    "Talk keeps truthful no-news behavior")

T.finish("dt_world_knowledge_smoke")

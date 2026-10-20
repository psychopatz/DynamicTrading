local T = require "tests/support/test"
T.addPackagePaths()

local coreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY")
    or "../psychopatzCore"
package.path = coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. package.path

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local Knowledge = require "PsychopatzCore/Actors/PsychopatzActorKnowledge"
local Json = require "PsychopatzCore/Serialization/PsychopatzJson"
local ActorService = require
    "PsychopatzCore/Conversation/PsychopatzActorConversationService"
local Router = require "PsychopatzCore/Semantics/PsychopatzSemanticDialogueRouter"
local State = require "PsychopatzCore/Semantics/PsychopatzSemanticDialogueState"

local data = { t = {} }
local touched = 0
local transmitted = 0
local stock = {}

DTCommon = {
    STATUS_READY = "READY",
    STATUS_AWAY = "AWAY",
    Storage = {
        IsAuthority = function() return true end,
        GetData = function() return data end,
        Touch = function() touched = touched + 1 end,
        Transmit = function() transmitted = transmitted + 1 end,
        LoadInventory = function() return stock end,
        SaveInventory = function() return true end,
    },
    TraderStock = {
        SaveAndTransmit = function() end,
        SnapshotItems = function() return {} end,
    },
    TraderSupport = {},
}
DTCommon.TraderSupport.Bounded = function(value, maximum)
    value = tostring(value or "")
    return #value > maximum and string.sub(value, 1, maximum) or value
end

local Policy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
T.load("DTCommon", "shared", "DTCommon/DTCommon_TraderRegistry.lua")
local TraderService = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderService.lua")
local abstract = dofile(T.repository
    .. "/Contents/mods/DTAbstract/42.20/media/lua/shared/DTAbstract/"
    .. "DTAbstract_CoreProvider.lua")
local hoomans = T.load(
    "DTHoomans", "shared", "DTHoomans/DTHoomans_CoreProvider.lua")

local core = { Actors = Actors }
local registry = Actors.NewRegistry()
local actorID = "npc:c5:portable-trader"
local traderID = "trader:c5:portable"
local actor, reason = registry:Create({
    actorId = actorID,
    identitySeed = "c5-portable-trader-seed",
    starterItems = {
        { fullType = "Base.Bandage", quantity = 2 },
    },
    social = {
        relationships = {
            ["player:user:alice"] = {
                target = "player:user:alice",
                approval = 31,
                respect = 17,
                familiarity = 9,
            },
        },
    },
})
T.truthy(actor, reason)

local knowledge = Knowledge.Record(actor.knowledge, {
    playerKey = "alice",
    factID = "safehouse",
    value = "north",
    status = "confirmed",
    confidence = 0.9,
    discoveredAt = 10,
    evidence = { id = "c5-alice-safehouse", sourceType = "conversation" },
}, "server")
T.truthy(knowledge, "alice Knowledge record")
knowledge = Knowledge.Record(knowledge, {
    playerKey = "bob",
    factID = "safehouse",
    value = "east",
    status = "suspected",
    confidence = 0.4,
    discoveredAt = 11,
    evidence = { id = "c5-bob-safehouse", sourceType = "conversation" },
}, "server")
T.truthy(knowledge, "bob Knowledge record")
actor, reason = registry:Commit(actorID, { knowledge = knowledge }, actor.revision)
T.truthy(actor, reason)

local record = {
    n = "Portable Trader",
    r = "merchant",
    c = "c5-caravan",
    s = "READY",
    a = 1,
    b = 777,
    v = 9,
    ca = Policy.New({ actorID = actorID }),
}
data.t[traderID] = record
local bound, bindReason = TraderService.BindCoreActor(traderID, actorID)
T.truthy(bound, bindReason)

local function commit(nextActor, previous)
    local committed, commitReason = registry:Commit(actorID, {
        providerLease = nextActor.providerLease,
    }, previous.revision)
    T.truthy(committed, commitReason)
    return committed
end

local function syncLease(nextActor, abstractAccess, bodyID)
    local lease = nextActor.providerLease
    local synced, syncReason = TraderService.SetCoreProviderLease(traderID, {
        actorID = actorID,
        provider = lease.provider,
        state = lease.state,
        leaseID = lease.leaseID,
        revision = lease.revision,
        bodyID = bodyID or lease.bodyID,
    })
    T.truthy(synced, syncReason)
    record.a = abstractAccess and 1 or 0
    record.p = bodyID
end

-- Abstract radio provider.
local previous = actor
actor, reason = abstract.Acquire(actor, core, {
    owner = "dtabstract:c5",
    authority = "server",
    expectedRevision = actor.providerLease.revision,
    now = 1,
})
T.truthy(actor, reason)
actor = commit(actor, previous)
syncLease(actor, true)
T.equal(record.ca.actorID, actorID, "trader binding keeps actor ID")

-- A stale radio-side transition cannot mutate the Core lease.
local stale, staleReason = abstract.Release(actor, core, {
    owner = "dtabstract:c5",
    authority = "server",
    expectedRevision = actor.providerLease.revision - 1,
    now = 2,
})
T.equal(stale, nil, "stale provider transition rejected")
T.equal(staleReason, "provider_revision_conflict",
    "stale provider transition reason")

previous = actor
actor, reason = abstract.Release(actor, core, {
    owner = "dtabstract:c5",
    authority = "server",
    expectedRevision = actor.providerLease.revision,
    now = 3,
})
T.truthy(actor, reason)
actor = commit(actor, previous)
syncLease(actor, true)

-- Physical provider takes the same lease and actor without rerolling state.
previous = actor
actor, reason = hoomans.Acquire(actor, core, {
    owner = "dthoomans:c5",
    authority = "server",
    expectedRevision = actor.providerLease.revision,
    now = 4,
})
T.truthy(actor, reason)
actor = commit(actor, previous)
syncLease(actor, false)

local bodyCount = 0
local body
local rejected, rejectedReason = hoomans.Materialize(actor, core, {
    owner = "dthoomans:c5",
    authority = "server",
    expectedRevision = actor.providerLease.revision,
    now = 5,
    bodyFactory = function()
        bodyCount = bodyCount + 1
        return "body:c5:rejected", { id = "body:c5:rejected" }
    end,
    applyProjection = function()
        return false
    end,
    cleanup = function()
        bodyCount = bodyCount - 1
    end,
})
T.equal(rejected, nil, "failed body projection rejects transition")
T.equal(rejectedReason, "body_projection_rejected",
    "failed body projection reason")
T.equal(bodyCount, 0, "failed projection cleans up its body")
T.equal(actor.providerLease.state, "abstract",
    "failed projection does not strand materialized lease")

local materialized, materializeReason = hoomans.Materialize(actor, core, {
    owner = "dthoomans:c5",
    authority = "server",
    expectedRevision = actor.providerLease.revision,
    now = 6,
    bodyFactory = function()
        bodyCount = bodyCount + 1
        return "body:c5:merchant", { id = "body:c5:merchant" }
    end,
    applyProjection = function(_, projection)
        return projection.actorId == actorID
            and projection.identity.identitySeed == "c5-portable-trader-seed"
    end,
})
T.truthy(materialized, materializeReason)
body = materialized.body
T.equal(materialized.bodyID, "body:c5:merchant", "one physical body ID")
T.equal(actor.providerLease.state, "abstract",
    "caller retains pre-transition actor until commit")
actor = commit(materialized.actor, actor)
syncLease(actor, false, materialized.bodyID)
T.equal(actor.providerLease.state, "materialized", "physical lease state")
T.equal(bodyCount, 1, "one physical body exists")
local duplicateBody, duplicateBodyReason = hoomans.Materialize(actor, core, {
    owner = "dthoomans:c5",
    authority = "server",
    expectedRevision = actor.providerLease.revision,
    bodyFactory = function()
        bodyCount = bodyCount + 1
        return "body:c5:duplicate", { id = "body:c5:duplicate" }
    end,
})
T.equal(duplicateBody, nil, "duplicate materialization rejected")
T.equal(duplicateBodyReason, "body_lease_active",
    "duplicate materialization reason")
T.equal(bodyCount, 1, "duplicate materialization spawns no body")

previous = actor
local dematerialized, dematerializeReason = hoomans.Dematerialize(actor, core, {
    owner = "dthoomans:c5",
    authority = "server",
    expectedRevision = actor.providerLease.revision,
    body = body,
    bodyID = materialized.bodyID,
    now = 7,
    persist = function(projection)
        return projection.personalInventory ~= nil
            and projection.social ~= nil
    end,
    cleanup = function()
        bodyCount = bodyCount - 1
    end,
})
T.truthy(dematerialized, dematerializeReason)
actor = commit(dematerialized.actor, previous)
syncLease(actor, false)
T.equal(bodyCount, 0, "dematerialization removes exactly one body")

previous = actor
actor, reason = hoomans.Release(actor, core, {
    owner = "dthoomans:c5",
    authority = "server",
    expectedRevision = actor.providerLease.revision,
    now = 8,
})
T.truthy(actor, reason)
actor = commit(actor, previous)
syncLease(actor, false)

previous = actor
actor, reason = abstract.Acquire(actor, core, {
    owner = "dtabstract:c5:return",
    authority = "server",
    expectedRevision = actor.providerLease.revision,
    now = 9,
})
T.truthy(actor, reason)
actor = commit(actor, previous)
syncLease(actor, true)

T.equal(record.ca.actorID, actorID, "return keeps one actor binding")
T.equal(record.ca.provider, "DTAbstract", "return provider")
T.equal(record.ca.providerState, "abstract", "return provider state")
T.equal(record.b, 777, "merchant budget is not copied into actor")
T.equal(record.v, 9, "merchant stock version is not changed")
T.truthy(touched > 0 and transmitted > 0, "trader lease persists")

local conversation = ActorService.New({
    actor = actor,
    router = Router.New({
        state = State.New({
            pendingQuestion = { id = "c5-question", topic = "home" },
            recentSemanticEvents = {
                { sequence = 1, topic = "home", rawText = "where do you live" },
            },
        }),
    }),
    conversationID = "c5-continuity",
})
local conversationSnapshot = conversation:Snapshot()
local resumed = ActorService.New({
    actor = actor,
    router = Router.New(),
})
local resumedSnapshot, resumeReason = resumed:Restore(conversationSnapshot)
T.truthy(resumedSnapshot, resumeReason)
T.equal(resumedSnapshot.state.pendingQuestion.id, "c5-question",
    "bounded pending question survives handoff")
T.equal(#resumedSnapshot.state.recentSemanticEvents, 1,
    "bounded topic history survives handoff")

local savedActors, actorSaveReason = registry:Save()
T.truthy(savedActors, actorSaveReason)
local fresh = Actors.NewRegistry()
T.truthy(fresh:Load(savedActors), "actor registry reload")
local restored = fresh:Get(actorID)
local traderPayload = Json.Encode({ traderID = traderID, record = record })
local traderReloaded = Json.Decode(traderPayload)
T.equal(restored.actorId, actorID, "actor ID survives reload")
T.equal(restored.identity.identitySeed, "c5-portable-trader-seed",
    "identity seed survives reload")
T.equal(restored.personalInventory.items[1].itemId,
    actor.personalInventory.items[1].itemId,
    "personal inventory survives reload")
T.equal(restored.social.relationships["player:user:alice"].approval, 31,
    "relationship survives reload")
T.equal(Knowledge.Get(restored.knowledge, "alice", "safehouse").value,
    "north", "Alice Knowledge survives reload")
T.equal(Knowledge.Get(restored.knowledge, "bob", "safehouse").value,
    "east", "Bob Knowledge remains isolated")
T.equal(restored.providerLease.provider, "DTAbstract",
    "final abstract provider survives reload")
T.equal(restored.providerLease.state, "abstract",
    "final abstract state survives reload")
T.equal(traderReloaded.record.ca.actorID, actorID,
    "trader actor binding survives reload")
T.equal(traderReloaded.record.ca.providerLeaseID, record.ca.providerLeaseID,
    "trader lease ID survives reload")
T.equal(traderReloaded.record.b, 777, "trader budget survives reload")
T.equal(traderReloaded.record.v, 9, "trader stock version survives reload")

print("dt_provider_hotswap_persistence_smoke: PASS")

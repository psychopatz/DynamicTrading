local T = require "tests/support/test"
T.addPackagePaths()

local modDataStore = {}
ModData = {
    getOrCreate = function(key)
        modDataStore[key] = modDataStore[key] or {}
        return modDataStore[key]
    end,
    transmit = function() end,
}

local commandHandlers = {}
Events = {
    OnInitGlobalModData = { Add = function() end },
    OnServerStarted = { Add = function() end },
    OnGameStart = { Add = function() end },
    OnSave = { Add = function() end },
    EveryDays = { Add = function() end },
    OnClientCommand = {
        Add = function(fn) commandHandlers[#commandHandlers + 1] = fn end,
    },
}

isServer = function() return true end
isClient = function() return false end

local worldHours = 200
getGameTime = function()
    return {
        getWorldAgeHours = function() return worldHours end,
    }
end

local serverEvents = {}
triggerEvent = function(eventName, moduleName, commandName, payload)
    serverEvents[#serverEvents + 1] = {
        eventName = eventName,
        moduleName = moduleName,
        commandName = commandName,
        payload = payload,
    }
end

-- Phase 1: Core + DTCommon + DTAbstract WITHOUT ProjectHoomans (PNC = nil)
PNC = nil

local CoreActors = require "PsychopatzCore/Actors/PsychopatzActors"
local Social = CoreActors.Social
local GC = CoreActors.GC
local WKG = require "PsychopatzCore/WorldKnowledge/PsychopatzWorldKnowledge"
local SurvivorWorld = require "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorld"

PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = CoreActors
PsychopatzCore.WorldKnowledge = WKG
PsychopatzCore.RuntimeRole = {
    AllowsServerCode = function() return true end,
}

local registry = CoreActors.NewRegistry()
CoreActors.DefaultRegistry = registry

local dtPolicyReg = require "DTCommon/SocialPolicy/Registry"
CoreActors.SocialPolicy.RegisterRegistry(dtPolicyReg)

dofile(T.path("DTCommon", "shared", "DTCommon/00_DTCommon_Init.lua"))

local Service = DTCommon.TraderService
local Policy = DTCommon.CoreActorPolicy
local Generation = DTCommon.TraderGeneration
local LifecycleBridge = DTCommon.ActorLifecycle
T.truthy(LifecycleBridge, "DTCommon.ActorLifecycle loaded via 00_DTCommon_Init")
LifecycleBridge.RegisterGCProvider(GC)

-- Verify 1: Rollback group/actor deletion uses HardDelete and leaves 0 tombstones
local rbActor = assert(registry:Create({
    actorId = "actor:dt:rollback",
    identitySeed = "dt-rollback-seed",
    world = { position = { x = 100, y = 100, z = 0 } },
}))
local rbRemoved = Generation.RemoveCanonicalGroup({
    createdActorIDs = { rbActor.actorId },
})
T.truthy(rbRemoved, "RemoveCanonicalGroup succeeded")
T.equal(registry:Get(rbActor.actorId), nil, "rollback actor removed from live records")
T.equal(#registry:ListTombstones(), 0, "rollback deletion creates zero tombstones")
T.equal(registry:GetLifecycleState(rbActor.actorId), "FORGOTTEN",
    "rollback actor is FORGOTTEN")

-- Verify 2: DTAbstract commercial-role removal (RemoveTrader) leaves Core actor LIVE
local roleActor = assert(registry:Create({
    actorId = "actor:dt:role_only",
    identitySeed = "dt-role-only",
    social = Social.NewState({
        relationships = {
            ["player:user:bob"] = {
                target = "player:user:bob",
                familiarity = 25,
                approval = 15,
            },
        },
        memoryBank = {
            {
                id = "mem:role:1",
                aboutKey = "player:user:bob",
                eventType = "trade_fair",
                retentionClass = "LONG",
                refStrength = "WEAK",
                salience = 5,
                createdAt = worldHours,
            },
        },
    }),
    world = { position = { x = 220, y = 220, z = 0 } },
}))
Service.Create({
    traderID = "trader:role_only",
    displayName = "Temporary Role Merchant",
    actorID = roleActor.actorId,
    provider = "DTAbstract",
    providerState = "abstract",
    abstractAccessEnabled = true,
})

DTAbstract = {
    SurvivorWorldRuntime = {
        GetActorRegistry = function() return registry end,
        SetActorRegistry = function() end,
        GetRegistry = function() return nil end,
        FindGroupForActor = function() return nil end,
        SelectTraderCandidate = function() return nil end,
    },
    TraderWorldProvider = {
        releaseTrader = function() return true, "released" end,
    },
}
T.load("DTAbstract", "shared", "DTAbstract/DTAbstract_CoreProvider.lua")
T.load("DTAbstract", "server", "DTAbstract/DTAbstract_Server.lua")
local adminPlayer = {}
for _, handler in ipairs(commandHandlers) do
    handler("DTAbstract", "RemoveTrader", adminPlayer, { traderID = "trader:role_only" })
end
T.equal(Service.GetRecord("trader:role_only"), nil,
    "RemoveTrader deleted DT commercial listing")
T.equal(registry:GetLifecycleState(roleActor.actorId), "LIVE",
    "commercial-role removal never retires Core actor")
T.equal(#registry:ListTombstones(), 0,
    "commercial-role removal creates zero tombstones")
T.truthy(Social.Get(registry:Get(roleActor.actorId).social, "player:user:bob"),
    "commercial-role removal preserves Core social history")

-- Verify 3: PreSurvivorWorldImport merges social + WorldKnowledge & HardDeletes old actor
WKG.Reset()
local migratedFact = assert(WKG.Publish({
    factID = "fact:mig:1",
    kind = "market_event",
    topic = "market",
    text = "Westpoint needs canned food.",
}, { now = worldHours }))
local oldStandalone = assert(registry:Create({
    actorId = "actor:dt:world:legacy_1",
    identitySeed = "legacy-1",
    social = Social.NewState({
        relationships = {
            ["player:user:alice"] = {
                target = "player:user:alice",
                familiarity = 40,
                approval = 20,
            },
        },
        memoryBank = {
            {
                id = "mem:mig:legacy_trade",
                aboutKey = "player:user:alice",
                eventType = "trade_fair",
                retentionClass = "ANCHOR",
                refStrength = "STRONG",
                salience = 10,
                createdAt = worldHours,
            },
        },
    }),
    world = { position = { x = 300, y = 400, z = 0 } },
}))
WKG.Acquire(oldStandalone.actorId, migratedFact.factID, {
    authorized = true,
    provenance = "public",
    source = "test",
    confidence = 1,
    learnedAt = worldHours,
})
local canonicalMig = assert(registry:Create({
    actorId = "npc_core_mig_target",
    identitySeed = "canonical-mig",
    world = { position = { x = 500, y = 600, z = 0 } },
}))

local migCommunity = "community:mig_canonical"
DTCommon.SettlementDirectory = {
    Get = function(id)
        if id == migCommunity then
            return {
                settlementID = id,
                name = "Mig Camp",
                position = { x = 500, y = 600, z = 0 },
                provider = "PsychopatzCore",
                enabled = true,
            }
        end
    end,
    ResolvePosition = function(id)
        local entry = DTCommon.SettlementDirectory.Get(id)
        return entry and entry.position or nil
    end,
}
DTAbstract.SurvivorWorldRuntime.SelectTraderCandidate = function()
    return {
        actorID = canonicalMig.actorId,
        groupID = "agroup_mig",
        factionID = "faction_mig",
        communityID = migCommunity,
        position = { x = 500, y = 600, z = 0 },
    }
end
DTAbstract.SurvivorWorldRuntime.FindGroupForActor = function(actorID)
    if actorID == canonicalMig.actorId then
        return { id = "agroup_mig", memberActorIDs = { canonicalMig.actorId } }
    end
    return nil, "actor_group_not_found"
end

local AbstractProvider = T.load(
    "DTAbstract", "server", "DTAbstract/DTAbstract_TraderWorldProvider.lua"
)
AbstractProvider.SetActorRegistry(registry)

local _, legacyDT = Service.Create({
    traderID = "trader:legacy_import",
    displayName = "Legacy Migrator",
    actorID = oldStandalone.actorId,
    provider = "DTAbstract",
    providerState = "abstract",
    abstractAccessEnabled = true,
})
local importedOK, importedReason = AbstractProvider.reconcileRecord(
    "trader:legacy_import", legacyDT
)
T.truthy(importedOK, importedReason)
T.equal(registry:Get(oldStandalone.actorId), nil, "superseded actor deleted")
T.equal(#registry:ListTombstones(), 0,
    "superseded PreSurvivorWorldImport migration creates ZERO fake tombstones")
T.equal(registry:GetLifecycleState(oldStandalone.actorId), "FORGOTTEN",
    "superseded actor is FORGOTTEN without tombstone")
local updatedCanon = assert(registry:Get(canonicalMig.actorId))
T.equal(updatedCanon.providerLease.provider, "DTAbstract",
    "canonical replacement preserved acquired DTAbstract lease after social merge")
T.truthy(Social.Get(updatedCanon.social, "player:user:alice"),
    "migration preserved oldActor social relationships on replacement")
T.equal(#Social.GetMemoriesForTarget(updatedCanon.social, "player:user:alice"), 1,
    "migration preserved oldActor memoryBank entries on replacement")
T.equal(WKG.KnowledgeState.byActor[oldStandalone.actorId], nil,
    "oldActor WorldKnowledge bucket cleaned after migration")
T.truthy(WKG.ActorKnowledge.Get(WKG.KnowledgeState, canonicalMig.actorId, migratedFact.factID),
    "oldActor WorldKnowledge transferred to canonical replacement")

-- Verify 4: Unreferenced trader retirement + WorldKnowledge clearing + GC purge + member scrub
local unrefActor = assert(registry:Create({
    actorId = "actor:dt:dead_unreferenced",
    identitySeed = "dead-unref",
    world = { position = { x = 700, y = 700, z = 0 } },
}))
WKG.Acquire(unrefActor.actorId, migratedFact.factID, {
    authorized = true,
    provenance = "public",
    source = "test",
    confidence = 1,
    learnedAt = worldHours,
})
Service.Create({
    traderID = "trader:dead_unreferenced",
    displayName = "Unreferenced Merchant",
    actorID = unrefActor.actorId,
    provider = "DTAbstract",
    providerState = "abstract",
    abstractAccessEnabled = true,
})
local _, survivorDT = Service.Create({
    traderID = "trader:surviving_caravan",
    displayName = "Surviving Merchant",
    actorID = canonicalMig.actorId,
    provider = "DTAbstract",
    providerState = "abstract",
    abstractAccessEnabled = true,
})
survivorDT.m = { canonicalMig.actorId, unrefActor.actorId }

-- Keep commercial record initially to confirm OnBeforePurge scrubs & Policy rejects
local tsUnref = assert(LifecycleBridge.RetireTraderActor("trader:dead_unreferenced", {
    retiredAt = worldHours,
    graceHours = 12,
    reason = "death",
    keepCommercialRecord = true,
}))
T.equal(registry:GetLifecycleState(unrefActor.actorId), "RETIRED",
    "RetireTraderActor creates Core tombstone")
T.equal(WKG.KnowledgeState.byActor[unrefActor.actorId], nil,
    "RetireTraderActor clears dead outgoing WorldKnowledge")
local availOK, availErr = Policy.IsAvailable(Service.GetRecord("trader:dead_unreferenced"))
T.falsy(availOK, "Policy.IsAvailable rejects retired trader")
T.equal(availErr, "actor_retired", "Policy.IsAvailable returns actor_retired")
T.equal(#Service.GetRecord("trader:surviving_caravan").m, 1,
    "OnActorRetired scrubbed dead member ref from surviving trader roster")

worldHours = worldHours + 24
local unrefSummary = GC.RunFull(registry, {
    authority = "server",
    now = worldHours,
    worldKnowledge = WKG,
})
T.truthy(unrefSummary.completed, "GC RunFull completed")
T.equal(registry:GetLifecycleState(unrefActor.actorId), "FORGOTTEN",
    "unreferenced dead trader purged to FORGOTTEN after grace")
T.equal(Service.GetRecord("trader:dead_unreferenced"), nil,
    "GC OnBeforePurge removed unreferenced lingering dead trader listing")

-- Verify 5: Strong betrayal anchor & active DT debt/contract pin tombstone, then purge when settled
local betrayerActor = assert(registry:Create({
    actorId = "actor:dt:dead_betrayer",
    identitySeed = "dead-betrayer",
    world = { position = { x = 800, y = 800, z = 0 } },
}))
Service.Create({
    traderID = "trader:dead_betrayer",
    displayName = "Backstabber Pete",
    actorID = betrayerActor.actorId,
    provider = "DTAbstract",
    providerState = "abstract",
    abstractAccessEnabled = true,
})
-- Witness actor holds STRONG betrayal anchor toward betrayerActor
local witnessActor = assert(registry:Create({
    actorId = "actor:dt:witness",
    identitySeed = "witness",
    social = Social.NewState({
        relationships = {
            ["actor:dt:dead_betrayer"] = {
                target = "actor:dt:dead_betrayer",
                trust = -70,
                fear = 30,
            },
        },
        memoryBank = {
            {
                id = "mem:betrayal:1",
                aboutKey = "actor:dt:dead_betrayer",
                eventType = "betrayed_player",
                retentionClass = "ANCHOR",
                refStrength = "STRONG",
                salience = 95,
                createdAt = worldHours,
            },
        },
    }),
}))
assert(LifecycleBridge.RetireTraderActor("trader:dead_betrayer", {
    retiredAt = worldHours,
    graceHours = 12,
    reason = "death",
}))
T.equal(Service.GetRecord("trader:dead_betrayer"), nil,
    "unencumbered dead betrayer commercial listing removed immediately on RetireTraderActor")

local obligorActor = assert(registry:Create({
    actorId = "actor:dt:dead_obligor",
    identitySeed = "dead-obligor",
    world = { position = { x = 900, y = 900, z = 0 } },
}))
local _, obligorRec = Service.Create({
    traderID = "trader:dead_obligor",
    displayName = "Bonded Merchant",
    actorID = obligorActor.actorId,
    provider = "DTAbstract",
    providerState = "abstract",
    abstractAccessEnabled = true,
})
obligorRec.obligations = {
    { id = "debt:1", active = true, counterparty = witnessActor.actorId },
}
assert(LifecycleBridge.RetireTraderActor("trader:dead_obligor", {
    retiredAt = worldHours,
    graceHours = 12,
    reason = "death",
}))
T.truthy(Service.GetRecord("trader:dead_obligor"),
    "trader record preserved while active commercial obligation exists")

worldHours = worldHours + 24
GC.RunFull(registry, { authority = "server", now = worldHours, worldKnowledge = WKG })
T.equal(registry:GetLifecycleState(betrayerActor.actorId), "RETIRED",
    "betrayed dead trader tombstone retained by STRONG anchor memory")
T.equal(registry:GetLifecycleState(obligorActor.actorId), "RETIRED",
    "obligor dead trader tombstone retained by active DT obligation")
local obligorExplain = GC.ExplainRetention(registry, obligorActor.actorId, { now = worldHours })
local foundDTReason = false
for _, root in ipairs(obligorExplain.strongRoots or {}) do
    if root.providerID == "DynamicTrading.CommercialRoots"
        and root.reason == "dt_active_obligation"
    then
        foundDTReason = true
    end
end
T.truthy(foundDTReason, "ExplainRetention identifies DynamicTrading.CommercialRoots obligation")

-- Settle obligation and verify obligor purges while betrayer stays pinned
obligorRec.obligations[1].active = false
GC.RunFull(registry, { authority = "server", now = worldHours, worldKnowledge = WKG })
T.equal(registry:GetLifecycleState(obligorActor.actorId), "FORGOTTEN",
    "settled obligor purges to FORGOTTEN")
T.equal(Service.GetRecord("trader:dead_obligor"), nil,
    "GC OnBeforePurge cleaned up settled obligor commercial listing")
T.equal(registry:GetLifecycleState(betrayerActor.actorId), "RETIRED",
    "betrayer remains RETIRED while STRONG anchor survives")

-- Verify 6: DTAbstract reconcileRecord recognizes Core RETIRED as actor_retired, never core_actor_missing
local extDeadActor = assert(registry:Create({
    actorId = "actor:dt:external_death",
    identitySeed = "ext-dead",
    world = { position = { x = 1000, y = 1000, z = 0 } },
}))
local _, extDT = Service.Create({
    traderID = "trader:external_death",
    displayName = "Externally Retired Merchant",
    actorID = extDeadActor.actorId,
    provider = "DTAbstract",
    providerState = "abstract",
    abstractAccessEnabled = true,
})
assert(registry:Retire(extDeadActor.actorId, {
    authority = "server",
    reason = "death",
    retiredAt = worldHours,
    graceHours = 12,
}))
local recOK, recReason = AbstractProvider.reconcileRecord("trader:external_death", extDT)
T.truthy(recOK, recReason)
T.equal(recReason, "changed", "reconcileRecord transitions retired actor record")
T.equal(extDT.ca.available, false, "external retirement marks DT record unavailable")
T.equal(extDT.ca.availabilityReason, "actor_retired",
    "reconcileRecord uses actor_retired instead of core_actor_missing")
T.equal(extDT.ca.lifecycleState, "retired", "reconcileRecord sets lifecycleState = retired")
T.equal(extDT.s, DTCommon.STATUS_AWAY, "reconcileRecord marks trader AWAY")

worldHours = worldHours + 24
GC.RunFull(registry, { authority = "server", now = worldHours, worldKnowledge = WKG })
T.equal(registry:GetLifecycleState(extDeadActor.actorId), "FORGOTTEN",
    "external dead trader purged")
-- Even after purge, never treat an actor_retired record as core_actor_missing or auto-resurrect
local postPurgeOK, postPurgeReason = AbstractProvider.reconcileRecord("trader:external_death", {
    s = DTCommon.STATUS_AWAY,
    ca = Policy.New({
        actorID = extDeadActor.actorId,
        provider = "DTAbstract",
        providerState = "released",
        available = false,
        availabilityReason = "actor_retired",
    }),
})
T.truthy(postPurgeOK, postPurgeReason)
T.equal(postPurgeReason, "unchanged", "post-purge retired record never flips to core_actor_missing")

-- Phase 2: Combined DTHoomans + ProjectHoomans continuity, SettlementTrader BindActor, and physical death
local SHARED = T.path("ProjectHoomans", "shared", "PNC/Core/")
PNC = {}
T.load(SHARED .. "Base/PNC_Core.lua")
local physicalRecords = {}
PNC.Types = {
    NewRecord = function(spec)
        return {
            id = spec.id,
            displayName = spec.displayName,
            name = spec.displayName,
            alive = true,
            x = spec.x,
            y = spec.y,
            z = spec.z or 0,
            persist = spec.persist == true,
            runtime = {},
        }
    end,
}
PNC.Registry = {
    Data = physicalRecords,
    DeathMarkers = {},
    Get = function(id) return physicalRecords[tostring(id)] end,
    AddRecord = function(rec)
        physicalRecords[tostring(rec.id)] = rec
        return true
    end,
    RemoveRecord = function(id)
        local key = tostring(id)
        local removed = physicalRecords[key]
        physicalRecords[key] = nil
        return removed
    end,
    List = function()
        local out = {}
        for _, r in pairs(physicalRecords) do out[#out + 1] = r end
        return out
    end,
}
PNC.Persistence = {
    CoreProvider = {
        BuildRecord = function(_, _, base) return base end,
        Release = function(actor, _, opts)
            return {
                providerLease = {
                    schema = "PsychopatzCore.NPC.ProviderLease",
                    schemaVersion = 1,
                    actorID = actor.actorId,
                    provider = opts.provider or "ProjectHoomans",
                    owner = nil,
                    state = "released",
                    revision = ((actor.providerLease and actor.providerLease.revision) or 1) + 1,
                },
            }
        end,
    },
}
T.load(SHARED .. "Persistence/PNC_Persistence_CoreLifecycle.lua")

local settleActor = assert(registry:Create({
    actorId = "actor:hoom:settle_trader",
    identitySeed = "hoom-settle-trader",
    social = Social.NewState({
        relationships = {
            ["player:user:carol"] = {
                target = "player:user:carol",
                familiarity = 30,
                approval = 25,
            },
        },
    }),
    world = { position = { x = 1200, y = 1200, z = 0 } },
}))

-- Test DTHoomans_SettlementTrader BindActor fix on an existing record missing ca.actorID
PNC.Factions = {
    Get = function(id)
        if id == "faction:settle_1" then
            return { id = id, status = "active" }
        end
    end,
    GetMembers = function()
        return {
            {
                npcID = settleActor.actorId,
                affiliation = { role = "trader" },
            },
        }
    end,
    IsMobileGroup = function() return false end,
}
Service.Create({
    traderID = "dt_faction:settle_1",
    displayName = "Settlement Shopkeep",
    provider = "DTHoomans",
    providerState = "materialized",
    abstractAccessEnabled = false,
})
local settleRec = Service.GetRecord("dt_faction:settle_1")
settleRec.p = settleActor.actorId
settleRec.l = settleActor.actorId
settleRec.ca.actorID = nil

T.load("DTHoomans", "server", "DTHoomans/DTHoomans_SettlementTrader.lua")
local settledOK, settledReason = DTHoomans.Settlement.EnsureTraderForFaction("faction:settle_1")
T.truthy(settledOK, settledReason)
T.equal(Service.GetRecord("dt_faction:settle_1").ca.actorID, settleActor.actorId,
    "SettlementTrader repaired missing ca.actorID via Service.BindActor")

-- Materialize -> dematerialize continuity keeps single canonical Core actor LIVE
T.load("DTHoomans", "server", "DTHoomans/DTHoomans_ProviderRuntime.lua")
local matRec = PNC.Types.NewRecord({
    id = settleActor.actorId,
    displayName = "Settlement Shopkeep",
    x = 1200,
    y = 1200,
    z = 0,
})
matRec.runtime.dtProviderProjection = true
PNC.Registry.AddRecord(matRec)
T.truthy(PNC.Registry.Get(settleActor.actorId), "physical body materialized")
T.truthy(PNC.Registry.Get(settleActor.actorId).runtime.dtProviderProjection, "projection marked")
-- Dematerialize: remove transient body record without retiring canonical Core actor
PNC.Registry.RemoveRecord(settleActor.actorId)
T.equal(registry:GetLifecycleState(settleActor.actorId), "LIVE",
    "dematerialize leaves canonical Core actor LIVE")
T.truthy(Social.Get(registry:Get(settleActor.actorId).social, "player:user:carol"),
    "dematerialize preserves Core social state")

-- Physical death via Project Hoomans retires canonical Core actor cleanly
local deadOK, deadReason = PNC.Persistence.CoreLifecycle.RetireActor({
    id = settleActor.actorId,
    coreActorID = settleActor.actorId,
    displayName = "Settlement Shopkeep",
    role = "trader",
}, "death", { retiredAt = worldHours, graceHours = 12 })
T.truthy(deadOK, deadReason)
T.equal(registry:GetLifecycleState(settleActor.actorId), "RETIRED",
    "PNC death retires single canonical trader actor into Core tombstone")
local physAvailOK, physAvailErr = Policy.IsAvailable(Service.GetRecord("dt_faction:settle_1"))
T.falsy(physAvailOK, "Policy.IsAvailable rejects physically retired trader immediately")
T.equal(physAvailErr, "actor_retired", "physical death returns actor_retired")

local reconPhysOK = LifecycleBridge.OnActorRetired(settleActor.actorId, {
    removeCommercialRecord = false,
    now = worldHours,
})
T.truthy(reconPhysOK, "OnActorRetired reconciled DT commercial record")
local finalSettleRec = Service.GetRecord("dt_faction:settle_1")
T.equal(finalSettleRec.ca.providerState, "released",
    "physical death releases DT providerState")
T.equal(finalSettleRec.ca.availabilityReason, "actor_retired",
    "physical death records actor_retired reason")

T.finish("dt_actor_lifecycle_gc_adoption_smoke")

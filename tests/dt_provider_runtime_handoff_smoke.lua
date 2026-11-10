local T = require "tests/support/test"
T.addPackagePaths()

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local ActorInventory = Actors.Inventory
local registry = Actors.NewRegistry()
Actors.DefaultRegistry = registry
PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = Actors

local worldNow = 5
getGameTime = function()
    return { getWorldAgeHours = function() return worldNow end }
end

DTCommon = DTCommon or {}
local Policy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
DTCommon.CoreActorPolicy = Policy

local records = {}
DTCommon.TraderStock = { SaveAndTransmit = function() return true end }
DTCommon.TraderService = {
    GetRecord = function(id) return records[id] end,
    BindPhysical = function(id, npcID)
        records[id].p = npcID
        return true
    end,
    ClearPhysical = function(id)
        records[id].p = nil
        return true
    end,
}

local actor = assert(registry:Create({
    actorId = "actor:handoff:runtime",
    identitySeed = "handoff-runtime",
    world = { position = { x = 100, y = 200, z = 0 } },
}))
local acquired = assert(Actors.Provider.Acquire(actor, {
    provider = "DTAbstract",
    owner = "dtcommon:trader_world",
    authority = "server",
    now = 0,
}))
assert(registry:Commit(actor.actorId, {
    providerLease = acquired.providerLease,
}, actor.revision))

local current = registry:Get(actor.actorId)
local journey = assert(Actors.World.StartJourney(
    current.world, actor.actorId, {
        journeyID = "journey:handoff:runtime",
        origin = { x = 100, y = 200, z = 0 },
        destination = { x = 300, y = 200, z = 0 },
        speed = 20,
        startAt = 0,
        arrivalAction = {
            type = "dt_settlement_visit",
            settlementID = "settlement:westpoint",
        },
    }, 0))
assert(registry:Commit(actor.actorId, { world = journey }, current.revision))

records["trader:handoff:runtime"] = {
    n = "Handoff Trader",
    b = 500,
    v = 1,
    ca = Policy.New({
        actorID = actor.actorId,
        provider = "DTAbstract",
        providerState = "abstract",
        destinationSettlementID = "settlement:westpoint",
    }),
}


local function addCoreInventoryItem(payload, itemID, fullType)
    local ledger, reason = ActorInventory.Decode(payload)
    T.truthy(ledger, reason)
    local existing = ledger:Get(itemID)
    if not existing then
        local added
        added, reason = ledger:Add({
            itemId = itemID,
            fullType = fullType or "Base.Bandage",
        })
        T.truthy(added, reason)
    end
    local compact, mode = ActorInventory.ToSmallestPayload(ledger)
    T.truthy(compact, mode)
    return compact
end

local function hasCoreInventoryItem(payload, itemID)
    local ledger, reason = ActorInventory.Decode(payload)
    T.truthy(ledger, reason)
    return ledger:Get(itemID) ~= nil
end

local body = {
    x = 200, y = 200, z = 0,
    getX = function(self) return self.x end,
    getY = function(self) return self.y end,
    getZ = function(self) return self.z end,
}

local hoomansRecords = {}
PNC = {
    Types = {
        NewRecord = function(def)
            return {
                id = def.id,
                name = def.displayName,
                displayName = def.displayName,
                identity = def.identity,
                appearance = def.appearance,
                x = def.x, y = def.y, z = def.z,
                persist = true,
                runtime = {},
            }
        end,
    },
    Registry = {
        Get = function(id) return hoomansRecords[id] end,
        AddRecord = function(record)
            hoomansRecords[record.id] = record
            return true
        end,
        RemoveRecord = function(id)
            hoomansRecords[id] = nil
        end,
        GetLiveZombie = function(id)
            if id == actor.actorId then return body end
        end,
    },
    Persistence = {
        CoreProvider = {},
    },
}

function PNC.Persistence.CoreProvider.BuildRecord(source, core, base)
    base = base or {}
    base.id = source.actorId
    base.identity = source.identity
    base.appearance = source.appearance
    base.social = source.social
    base.personalInventory = source.personalInventory
    base.runtime = base.runtime or {}
    return base, { actorID = source.actorId }
end

function PNC.Persistence.CoreProvider.Materialize(source, core, spec)
    T.equal(source.providerLease.provider, "DTHoomans",
        "runtime did not switch provider before materialization")
    local nextActor, reason = Actors.Provider.Materialize(source, {
        provider = "DTHoomans",
        owner = "dthoomans:runtime",
        bodyID = "body:handoff:runtime",
        authority = "server",
        now = spec.now,
    })
    if not nextActor then return nil, reason end
    return {
        actor = nextActor,
        body = body,
        bodyID = "body:handoff:runtime",
    }
end

function PNC.Persistence.CoreProvider.Dematerialize(source, core, spec)
    local nextActor, reason = Actors.Provider.Dematerialize(source, {
        provider = "DTHoomans",
        owner = "dthoomans:runtime",
        bodyID = source.providerLease.bodyID,
        authority = "server",
        now = spec.now,
    })
    if not nextActor then return nil, reason end
    nextActor.personalInventory = addCoreInventoryItem(
        source.personalInventory,
        source.actorId .. ":physical:bandage",
        "Base.Bandage"
    )
    return {
        actor = nextActor,
        body = body,
        bodyID = "body:handoff:runtime",
    }
end

function PNC.Persistence.CoreProvider.CaptureInventory(source)
    return addCoreInventoryItem(
        source.personalInventory,
        source.actorId .. ":recovery:water",
        "Base.WaterBottleFull"
    ), "BASELINE_DELTA", "fixture_capture"
end

DTHoomans = {}
local Runtime = T.load(
    "DTHoomans", "server", "DTHoomans/DTHoomans_ProviderRuntime.lua")

local materialized, matResult = Runtime.MaterializeTrader(
    "trader:handoff:runtime", { now = 5 })
T.truthy(materialized, matResult)
T.equal(materialized.providerLease.provider, "DTHoomans",
    "materialized provider mismatch")
T.equal(materialized.providerLease.state, "materialized",
    "provider state not materialized")
T.equal(records["trader:handoff:runtime"].ca.provider, "DTHoomans",
    "trader policy did not follow provider")
T.equal(records["trader:handoff:runtime"].p, actor.actorId,
    "physical binding was not set")
T.truthy(math.abs(materialized.world.location.position.x - 200) < 0.001,
    "materialization did not freeze projected journey position")
T.truthy(hoomansRecords[actor.actorId]
    and hoomansRecords[actor.actorId].runtime.dtProviderProjection == true,
    "DT-only actor was not adopted into a provider-owned Hoomans record")

-- Simulate a physical move before returning to abstract.
body.x = 218
worldNow = 6
local resumed, dematResult = Runtime.DematerializeTrader(
    "trader:handoff:runtime", { now = 6 })
T.truthy(resumed, dematResult)
T.equal(resumed.providerLease.provider, "DTAbstract",
    "provider did not return to DTAbstract")
T.equal(resumed.providerLease.state, "abstract",
    "returned provider is not abstract")
T.equal(records["trader:handoff:runtime"].ca.provider, "DTAbstract",
    "trader policy did not return to DTAbstract")
T.equal(records["trader:handoff:runtime"].p, nil,
    "physical binding was not cleared")

local resumedPos = Actors.World.ProjectPosition(resumed.world, 6)
T.truthy(math.abs(resumedPos.x - 218) < 0.001,
    "abstract journey did not rebase from physical final position")
T.equal(resumed.world.journey.journeyID, "journey:handoff:runtime",
    "handoff changed canonical journey identity")
T.equal(resumed.world.journey.destination.x, 300,
    "handoff lost route destination")
T.equal(hoomansRecords[actor.actorId], nil,
    "provider-owned Hoomans record survived dematerialization")
T.truthy(hasCoreInventoryItem(
    registry:Get(actor.actorId).personalInventory,
    actor.actorId .. ":physical:bandage"
), "normal dematerialization did not commit durable Core inventory")

-- Failed materialization must roll the lease back and clear temporary return
-- metadata rather than poisoning later representation decisions.
local successfulMaterialize = PNC.Persistence.CoreProvider.Materialize
PNC.Persistence.CoreProvider.Materialize = function()
    return nil, "fixture_materialize_failed"
end
local failedMaterialize, failedReason = Runtime.MaterializeTrader(
    "trader:handoff:runtime", { now = 7 })
T.falsy(failedMaterialize, "failed physical spawn unexpectedly succeeded")
T.equal(failedReason, "fixture_materialize_failed",
    "failed materialization reason mismatch")
T.equal(records["trader:handoff:runtime"].ca.returnProviderID, nil,
    "failed materialization left stale return provider")
T.equal(registry:Get(actor.actorId).providerLease.provider, "DTAbstract",
    "failed materialization did not roll Core lease back")
T.equal(hoomansRecords[actor.actorId], nil,
    "failed materialization left provider-owned Hoomans record")
PNC.Persistence.CoreProvider.Materialize = successfulMaterialize

-- Simulate a later save/reload recovery edge: Core restored a materialized
-- DTHoomans lease, but Hoomans startup has conclusively reconciled the
-- provider-owned record to abstract/missing with no live body.
local recoveredActor = registry:Get(actor.actorId)
local switched = assert(registry:SwitchProvider(actor.actorId, {
    provider = "DTHoomans",
    owner = "dthoomans:runtime",
    handoffFrom = "dtcommon:trader_world",
    authority = "server",
    now = 10,
}))
local materializedLease = assert(Actors.Provider.Materialize(switched, {
    provider = "DTHoomans",
    owner = "dthoomans:runtime",
    bodyID = "body:stale:restart",
    authority = "server",
    now = 10,
}))
assert(registry:Commit(actor.actorId, {
    providerLease = materializedLease.providerLease,
}, switched.revision))
records["trader:handoff:runtime"].ca =
    assert(Policy.SetProviderLease(
        records["trader:handoff:runtime"],
        registry:Get(actor.actorId).providerLease))
records["trader:handoff:runtime"].ca.returnProviderID = "DTAbstract"

body = nil
hoomansRecords[actor.actorId] = {
    id = actor.actorId,
    runtime = {
        dtProviderProjection = true,
        lifecycle = { phase = "abstract", bodyState = "missing" },
    },
}
local recovered, recoveryReason = Runtime.RecoverMissingBody(
    "trader:handoff:runtime", { now = 11 })
T.truthy(recovered, recoveryReason)
T.equal(recoveryReason, "recovered_missing_body",
    "missing-body recovery reason mismatch")
T.equal(recovered.providerLease.provider, "DTAbstract",
    "missing-body recovery did not return actor to abstract provider")
T.equal(recovered.providerLease.state, "abstract",
    "missing-body recovery did not restore abstract lease state")
T.equal(hoomansRecords[actor.actorId], nil,
    "missing-body recovery did not remove provider-owned Hoomans record")
T.truthy(hasCoreInventoryItem(
    registry:Get(actor.actorId).personalInventory,
    actor.actorId .. ":recovery:water"
), "missing-body recovery did not commit logical inventory capture")

-- A fresh Hoomans startup may already have hydrated this Core actor before
-- DynamicTrading asks DTHoomans to materialize it. That record is canonical
-- Hoomans state, not a temporary DT projection, so the hotswap must preserve
-- the same table across materialize/dematerialize.
local hydratedRecord = {
    id = actor.actorId,
    runtime = {},
    hydratedByCore = true,
}
hoomansRecords[actor.actorId] = hydratedRecord
local materializedHydrated, hydratedMaterializeReason =
    Runtime.MaterializeTrader("trader:handoff:runtime", { now = 12 })
T.truthy(materializedHydrated, hydratedMaterializeReason)
T.equal(hoomansRecords[actor.actorId], hydratedRecord,
    "provider hotswap replaced the pre-hydrated Hoomans record")
T.falsy(hydratedRecord.runtime.dtProviderProjection,
    "pre-hydrated Hoomans record became a temporary DT projection")

local resumedHydrated, hydratedDematerializeReason =
    Runtime.DematerializeTrader("trader:handoff:runtime", { now = 13 })
T.truthy(resumedHydrated, hydratedDematerializeReason)
T.equal(hoomansRecords[actor.actorId], hydratedRecord,
    "dematerialization removed the pre-hydrated Hoomans record")
T.falsy(hydratedRecord.runtime.dtProviderProjection,
    "dematerialization left temporary DT projection metadata")

T.finish("dt_provider_runtime_handoff_smoke")

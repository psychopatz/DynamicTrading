local T = require "tests/support/test"
T.addPackagePaths()

local coreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY")
    or "../psychopatzCore"
package.path = coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. package.path

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local World = Actors.World
local actorRegistry = Actors.NewRegistry()

local storeData = { t = {} }
local touched = 0

DTCommon = DTCommon or {}
DTCommon.STATUS_READY = "READY"
DTCommon.Storage = {
    IsAuthority = function() return true end,
    GetData = function() return storeData end,
    Touch = function() touched = touched + 1 end,
    Transmit = function() end,
}
DTCommon.TraderStock = {
    SaveAndTransmit = function() end,
}

local Policy = T.load("DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
DTCommon.TraderService = {
    ForEach = function(callback)
        for id, record in pairs(storeData.t) do
            callback(id, record)
        end
    end,
    GetRecord = function(id) return storeData.t[id] end,
    SetCoreProviderLease = function(traderID, lease)
        local record = storeData.t[traderID]
        if not record then return nil, "trader_not_found" end
        record.ca = record.ca or Policy.New({ actorID = lease.actorID })
        record.ca.provider = lease.provider
        record.ca.providerState = lease.state
        record.ca.providerLeaseID = lease.leaseID
        record.ca.providerRevision = lease.revision
        record.ca.providerBodyID = lease.bodyID
        return record.ca
    end,
}

DTAbstract = DTAbstract or {}
local abstract = T.load("DTAbstract", "shared", "DTAbstract/DTAbstract_CoreProvider.lua")
local hoomans = T.load("DTHoomans", "shared", "DTHoomans/DTHoomans_CoreProvider.lua")

local core = { Actors = Actors }

-- ---------------------------------------------------------------------------
-- 1. Create canonical Core actor and bind with DT trader record
-- ---------------------------------------------------------------------------
local actorID = "actor:dt:hybrid:1"
local traderID = "trader:dt:hybrid:1"

local actor, actorReason = actorRegistry:Create({
    actorId = actorID,
    identitySeed = "hybrid-seed-1",
    world = { position = { x = 10000, y = 10000, z = 0 } },
})
T.truthy(actor, actorReason)

local acquired, acqReason = abstract.Acquire(actor, core, {
    owner = "abstract:lifecycle",
    now = 0,
})
T.truthy(acquired, acqReason)
T.equal(acquired.providerLease.provider, "DTAbstract", "initial provider is DTAbstract")
T.equal(acquired.providerLease.state, "abstract", "initial provider state is abstract")

actorRegistry:Commit(actorID, acquired, actor.revision)

local traderRecord = {
    n = "Hybrid Trader",
    s = "READY",
    b = 1500,
    v = 3,
    ca = Policy.New({
        actorID = actorID,
        provider = "DTAbstract",
        providerState = "abstract",
        homeSettlementID = "settlement:muldraugh",
        currentSettlementID = "settlement:muldraugh",
    }),
}
storeData.t[traderID] = traderRecord

-- ---------------------------------------------------------------------------
-- 2. Handoff to physical provider (DTHoomans)
-- ---------------------------------------------------------------------------
local currentActor = actorRegistry:Get(actorID)
local released, relReason = abstract.Release(currentActor, core, {
    owner = "abstract:lifecycle",
    expectedRevision = currentActor.providerLease.revision,
    now = 1,
})
T.truthy(released, relReason)
currentActor = actorRegistry:Commit(actorID, released, currentActor.revision)

local hoomansAcquired, hAcqReason = hoomans.Acquire(currentActor, core, {
    owner = "hoomans:body",
    expectedRevision = currentActor.providerLease.revision,
    now = 2,
})
T.truthy(hoomansAcquired, hAcqReason)
currentActor = actorRegistry:Commit(actorID, hoomansAcquired, currentActor.revision)

local bodyCount = 0
local materialized, matReason = hoomans.Materialize(currentActor, core, {
    owner = "hoomans:body",
    expectedRevision = currentActor.providerLease.revision,
    now = 3,
    bodyFactory = function()
        bodyCount = bodyCount + 1
        return "body:hybrid:1", { id = "body:hybrid:1" }
    end,
    applyProjection = function() return true end,
})
T.truthy(materialized, matReason)
currentActor = actorRegistry:Commit(actorID, materialized.actor, currentActor.revision)
T.equal(bodyCount, 1, "exactly one physical body exists")
T.equal(currentActor.providerLease.provider, "DTHoomans", "current provider is DTHoomans")
T.equal(currentActor.providerLease.state, "materialized", "current state is materialized")

-- Sync DT trader record
DTCommon.TraderService.SetCoreProviderLease(traderID, currentActor.providerLease)
traderRecord.p = materialized.bodyID
T.equal(traderRecord.ca.actorID, actorID, "same canonical actor ID preserved")
T.equal(traderRecord.ca.provider, "DTHoomans", "provider updated to DTHoomans")
T.equal(traderRecord.b, 1500, "merchant budget preserved untouched")
T.equal(traderRecord.v, 3, "merchant stock version preserved untouched")

-- ---------------------------------------------------------------------------
-- 3. Dematerialize and return to DTAbstract
-- ---------------------------------------------------------------------------
local dematerialized, demReason = hoomans.Dematerialize(currentActor, core, {
    owner = "hoomans:body",
    expectedRevision = currentActor.providerLease.revision,
    body = materialized.body,
    bodyID = materialized.bodyID,
    now = 4,
    cleanup = function() bodyCount = bodyCount - 1 end,
    persist = function(proj) return true end,
})
T.truthy(dematerialized, demReason)
currentActor = actorRegistry:Commit(actorID, dematerialized.actor, currentActor.revision)
T.equal(bodyCount, 0, "body cleanly destroyed on dematerialize")

local hoomansReleased, hRelReason = hoomans.Release(currentActor, core, {
    owner = "hoomans:body",
    expectedRevision = currentActor.providerLease.revision,
    now = 5,
})
T.truthy(hoomansReleased, hRelReason)
currentActor = actorRegistry:Commit(actorID, hoomansReleased, currentActor.revision)

local abstractResumed, absReason = abstract.Acquire(currentActor, core, {
    owner = "abstract:lifecycle",
    expectedRevision = currentActor.providerLease.revision,
    now = 6,
})
T.truthy(abstractResumed, absReason)
currentActor = actorRegistry:Commit(actorID, abstractResumed, currentActor.revision)

DTCommon.TraderService.SetCoreProviderLease(traderID, currentActor.providerLease)
traderRecord.p = nil
T.equal(currentActor.providerLease.provider, "DTAbstract", "provider returned to DTAbstract")
T.equal(currentActor.providerLease.state, "abstract", "state returned to abstract")
T.equal(traderRecord.ca.actorID, actorID, "actor ID preserved")
T.equal(traderRecord.b, 1500, "budget unchanged")
T.equal(traderRecord.v, 3, "stock version unchanged")

-- ---------------------------------------------------------------------------
-- 4. Save / Reload Persistence Verification
-- ---------------------------------------------------------------------------
local savedRegistry = actorRegistry:Save()
local freshRegistry = Actors.NewRegistry()
T.truthy(freshRegistry:Load(savedRegistry), "fresh registry loaded")

local reloaded = freshRegistry:Get(actorID)
T.truthy(reloaded, "reloaded actor found")
T.equal(reloaded.actorId, actorID, "actorId matches")
T.equal(reloaded.providerLease.provider, "DTAbstract", "reloaded provider lease is DTAbstract")
T.equal(reloaded.providerLease.state, "abstract", "reloaded provider lease state is abstract")

T.finish("dt_abstract_hybrid_handoff_smoke")

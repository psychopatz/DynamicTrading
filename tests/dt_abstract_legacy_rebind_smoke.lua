local T = require "tests/support/test"
T.addPackagePaths()

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local registry = Actors.NewRegistry()
Actors.DefaultRegistry = registry
PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = Actors
PsychopatzCore.RuntimeRole = {
    AllowsServerCode = function() return true end,
}

DTCommon = {
    STATUS_READY = "READY",
    Storage = {
        IsAuthority = function() return true end,
    },
}
local Policy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
DTCommon.CoreActorPolicy = Policy
local Providers = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderProviderRegistry.lua")
DTCommon.TraderProviders = Providers

local canonicalCommunity = "community:canonical"
DTCommon.SettlementDirectory = {
    Get = function(id)
        if id == canonicalCommunity then
            return {
                settlementID = id,
                name = "Canonical Camp",
                position = { x = 500, y = 600, z = 0 },
                provider = "PsychopatzCore",
                enabled = true,
            }
        end
    end,
    ResolvePosition = function(id)
        local item = DTCommon.SettlementDirectory.Get(id)
        return item and item.position or nil
    end,
}

local records = {}
DTCommon.TraderService = {
    ForEach = function(callback)
        for id, record in pairs(records) do
            callback(id, record)
        end
    end,
    Create = function()
        return nil, "fixture_create_failed"
    end,
}
DTCommon.TraderStock = {
    SaveAndTransmit = function() return true end,
}

local old = assert(registry:Create({
    actorId = "actor:dt:world:1",
    identitySeed = "legacy-standalone",
    world = { position = { x = 100, y = 200, z = 0 } },
}))
local oldAcquired = assert(Actors.Provider.Acquire(old, {
    provider = "DTAbstract",
    owner = "dtcommon:trader_world",
    authority = "server",
    now = 1,
}))
assert(registry:Commit(
    old.actorId,
    oldAcquired,
    old.revision
))

local canonical = assert(registry:Create({
    actorId = "npc_core_trader",
    identitySeed = "canonical-trader",
    world = { position = { x = 500, y = 600, z = 0 } },
}))

local candidate = {
    actorID = canonical.actorId,
    groupID = "agroup_core_trader",
    factionID = "faction_core_trader",
    communityID = canonicalCommunity,
    position = { x = 500, y = 600, z = 0 },
}

DTAbstract = {
    SurvivorWorldRuntime = {
        SetActorRegistry = function() end,
        GetActorRegistry = function() return registry end,
        SelectTraderCandidate = function() return candidate end,
        FindGroupForActor = function(actorID)
            if actorID == canonical.actorId then
                return {
                    id = candidate.groupID,
                    memberActorIDs = { canonical.actorId },
                }
            end
            return nil, "actor_group_not_found"
        end,
        GetRegistry = function() return nil end,
    },
}
T.load(
    "DTAbstract",
    "shared",
    "DTAbstract/DTAbstract_CoreProvider.lua"
)
local Provider = T.load(
    "DTAbstract",
    "server",
    "DTAbstract/DTAbstract_TraderWorldProvider.lua"
)
Provider.SetActorRegistry(registry)

local traderID = "trader:world:legacy"
records[traderID] = {
    n = "Legacy Merchant",
    b = 4321,
    v = 17,
    i = { rows = { { fullType = "Base.CannedBeans", quantity = 4 } } },
    ca = Policy.New({
        actorID = old.actorId,
        provider = "DTAbstract",
        providerState = "abstract",
        homeSettlementID = "settlement:rosewood",
        currentSettlementID = nil,
        destinationSettlementID = "settlement:westpoint",
        worldManaged = true,
        worldRole = "roaming",
        lifecycleState = "traveling",
        journeyID = "legacy-actor-journey",
        journeyState = "en_route",
    }),
}

local accepted, reason = Provider.reconcileRecord(
    traderID,
    records[traderID]
)
T.truthy(accepted, reason)
T.equal(reason, "changed", "legacy migration result")
T.equal(records[traderID].ca.actorID, canonical.actorId,
    "commercial record did not rebind canonical actor")
T.equal(records[traderID].ca.homeSettlementID, canonicalCommunity,
    "legacy home settlement was not migrated to canonical home")
T.equal(records[traderID].ca.currentSettlementID, canonicalCommunity,
    "legacy current settlement was not reset to canonical home")
T.equal(records[traderID].ca.destinationSettlementID, nil,
    "obsolete static destination survived migration")
T.equal(records[traderID].ca.lifecycleState, "idle",
    "obsolete actor-owned travel state survived migration")
T.equal(records[traderID].ca.journeyID, nil,
    "obsolete actor journey survived migration")
T.equal(records[traderID].b, 4321,
    "merchant budget changed during world migration")
T.equal(records[traderID].v, 17,
    "merchant stock version changed during world migration")
T.equal(records[traderID].i.rows[1].quantity, 4,
    "merchant stock changed during world migration")
T.equal(registry:Get(old.actorId), nil,
    "retired standalone actor was not removed")
local migratedActor = assert(registry:Get(canonical.actorId))
T.equal(migratedActor.providerLease.provider, "DTAbstract",
    "canonical replacement did not receive abstract lease")
T.equal(migratedActor.providerLease.state, "abstract",
    "canonical replacement lease state mismatch")

local second, secondReason = Provider.reconcileRecord(
    traderID,
    records[traderID]
)
T.truthy(second, secondReason)
T.equal(secondReason, "unchanged",
    "legacy migration repeated after canonical rebind")

-- A failed new commercial bind must roll its temporary provider lease back.
local rollbackActor = assert(registry:Create({
    actorId = "npc_core_rollback",
    identitySeed = "rollback-trader",
    world = { position = { x = 700, y = 800, z = 0 } },
}))
candidate = {
    actorID = rollbackActor.actorId,
    groupID = "agroup_core_rollback",
    factionID = "faction_core_rollback",
    communityID = canonicalCommunity,
    position = { x = 700, y = 800, z = 0 },
}

local spawned, spawnReason = Provider.spawnTrader({
    traderID = "trader:fixture:failed",
    sequence = 99,
    position = candidate.position,
})
T.falsy(spawned, "fixture commercial bind unexpectedly succeeded")
T.equal(spawnReason, "fixture_create_failed",
    "failed commercial bind reason changed")
local rolledBack = assert(registry:Get(rollbackActor.actorId))
T.equal(rolledBack.providerLease.state, "released",
    "failed bind left canonical actor leased to DTAbstract")
T.equal(Provider.LastRollbackError, nil,
    "failed bind rollback itself failed")

T.finish("dt_abstract_legacy_rebind_smoke")

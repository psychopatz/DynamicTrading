local T = require "tests/support/test"
T.addPackagePaths()

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local registry = Actors.NewRegistry()
PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = Actors

DTCommon = DTCommon or {}
local Policy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
DTCommon.CoreActorPolicy = Policy

local records = {
    ["trader:missing"] = {
        n = "Missing Actor Trader",
        ca = Policy.New({
            actorID = "actor:missing",
            provider = "DTAbstract",
            providerState = "abstract",
        }),
    },
    ["trader:valid"] = {
        n = "Valid Actor Trader",
        ca = Policy.New({
            actorID = "actor:valid",
            provider = "DTAbstract",
            providerState = "abstract",
        }),
    },
}

assert(registry:Create({
    actorId = "actor:valid",
    identitySeed = "valid",
    world = { position = { x = 10, y = 20, z = 0 } },
}))

local transmissions = 0
DTCommon.TraderService = {
    ForEach = function(callback)
        for id, record in pairs(records) do callback(id, record) end
    end,
}
DTCommon.TraderStock = {
    SaveAndTransmit = function()
        transmissions = transmissions + 1
        return true
    end,
}

DTAbstract = {}
local Lifecycle = T.load(
    "DTAbstract", "server", "DTAbstract/DTAbstract_Lifecycle.lua")
Lifecycle.SetActorRegistry(registry)

local first = Lifecycle.ReconcileActorLinks()
T.equal(first.checked, 2, "reconciliation did not inspect both traders")
T.equal(first.quarantined, 1, "missing actor was not quarantined")
T.equal(records["trader:missing"].ca.available, false,
    "missing actor trader remained available")
T.equal(records["trader:missing"].ca.availabilityReason,
    "core_actor_missing", "missing actor reason was not recorded")
T.equal(Lifecycle.CountAbstractTraders(), 1,
    "quarantined trader still consumed active population")
T.equal(transmissions, 1, "quarantine was not persisted")

-- Simulate later authoritative actor restoration from persistence.
assert(registry:Create({
    actorId = "actor:missing",
    identitySeed = "restored",
    world = { position = { x = 30, y = 40, z = 0 } },
}))
local second = Lifecycle.ReconcileActorLinks()
T.equal(second.restored, 1, "restored actor did not reactivate trader")
T.equal(records["trader:missing"].ca.available, true,
    "restored actor trader stayed quarantined")
T.equal(Lifecycle.CountAbstractTraders(), 2,
    "restored trader did not rejoin active population")
T.equal(transmissions, 2, "reactivation was not persisted")

T.finish("dt_abstract_orphan_reconciliation_smoke")

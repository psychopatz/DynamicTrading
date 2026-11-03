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
local Provider = T.load(
    "DTAbstract", "server", "DTAbstract/DTAbstract_TraderWorldProvider.lua")
Provider.SetActorRegistry(registry)
local TraderWorld = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderWorld.lua")

local first = TraderWorld.ReconcileProviders()
T.equal(first.checked, 2, "reconciliation did not inspect both traders")
T.equal(first.changed, 1, "missing actor was not quarantined")
T.equal(records["trader:missing"].ca.available, false,
    "missing actor trader remained available")
T.equal(records["trader:missing"].ca.availabilityReason,
    "core_actor_missing", "missing actor reason was not recorded")
local activeAfterFirst = 0
for _, record in pairs(records) do
    if record.ca.available ~= false then activeAfterFirst = activeAfterFirst + 1 end
end
T.equal(activeAfterFirst, 1,
    "quarantined trader remained available")
T.equal(transmissions, 1, "quarantine was not persisted")

-- Simulate later authoritative actor restoration from persistence.
assert(registry:Create({
    actorId = "actor:missing",
    identitySeed = "restored",
    world = { position = { x = 30, y = 40, z = 0 } },
}))
local second = TraderWorld.ReconcileProviders()
T.equal(second.changed, 1, "restored actor did not reactivate trader")
T.equal(records["trader:missing"].ca.available, true,
    "restored actor trader stayed quarantined")
local activeAfterSecond = 0
for _, record in pairs(records) do
    if record.ca.available ~= false then activeAfterSecond = activeAfterSecond + 1 end
end
T.equal(activeAfterSecond, 2,
    "restored trader did not rejoin availability")
T.equal(transmissions, 2, "reactivation was not persisted")

T.finish("dt_abstract_orphan_reconciliation_smoke")

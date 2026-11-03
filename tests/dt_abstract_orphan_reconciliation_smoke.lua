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
    ["trader:ungrouped"] = {
        n = "Ungrouped Actor Trader",
        ca = Policy.New({
            actorID = "actor:ungrouped",
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
assert(registry:Create({
    actorId = "actor:ungrouped",
    identitySeed = "ungrouped",
    world = { position = { x = 15, y = 25, z = 0 } },
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

local groupsByActor = {
    ["actor:valid"] = { id = "agroup:valid" },
}
DTAbstract = {
    SurvivorWorldRuntime = {
        GetActorRegistry = function() return registry end,
        SetActorRegistry = function() end,
        FindGroupForActor = function(actorID)
            local group = groupsByActor[actorID]
            if group then return group end
            return nil, "actor_group_not_found"
        end,
    },
}
local Provider = T.load(
    "DTAbstract", "server", "DTAbstract/DTAbstract_TraderWorldProvider.lua")
Provider.SetActorRegistry(registry)
local TraderWorld = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderWorld.lua")

local first = TraderWorld.ReconcileProviders()
T.equal(first.checked, 3,
    "reconciliation did not inspect all abstract traders")
T.equal(first.changed, 2,
    "actor/group orphans were not quarantined")
T.equal(records["trader:missing"].ca.available, false,
    "missing actor trader remained available")
T.equal(records["trader:missing"].ca.availabilityReason,
    "core_actor_missing", "missing actor reason was not recorded")
T.equal(records["trader:ungrouped"].ca.available, false,
    "ungrouped actor trader remained available")
T.equal(records["trader:ungrouped"].ca.availabilityReason,
    "core_group_missing", "missing group reason was not recorded")
T.equal(records["trader:valid"].ca.available, true,
    "valid canonical actor/group was quarantined")
T.equal(transmissions, 1,
    "quarantine changes were not persisted once")

-- Restore both canonical requirements. Availability must recover without
-- creating replacement actors or a parallel DTAbstract world.
assert(registry:Create({
    actorId = "actor:missing",
    identitySeed = "restored",
    world = { position = { x = 30, y = 40, z = 0 } },
}))
groupsByActor["actor:missing"] = { id = "agroup:missing" }
groupsByActor["actor:ungrouped"] = { id = "agroup:ungrouped" }

local second = TraderWorld.ReconcileProviders()
T.equal(second.changed, 2,
    "restored canonical actor/group bindings did not reactivate traders")
T.equal(records["trader:missing"].ca.available, true,
    "restored actor trader stayed quarantined")
T.equal(records["trader:ungrouped"].ca.available, true,
    "restored group trader stayed quarantined")

local activeAfterSecond = 0
for _, record in pairs(records) do
    if record.ca.available ~= false then
        activeAfterSecond = activeAfterSecond + 1
    end
end
T.equal(activeAfterSecond, 3,
    "restored canonical traders did not rejoin availability")
T.equal(transmissions, 2,
    "reactivation was not persisted once")

T.finish("dt_abstract_orphan_reconciliation_smoke")

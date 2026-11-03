local T = require "tests/support/test"
T.addPackagePaths()

isClient = function() return false end
isServer = function() return true end

local roots = {}
ModData = {
    get = function(key) return roots[key] end,
    getOrCreate = function(key)
        roots[key] = roots[key] or {}
        return roots[key]
    end,
}
Events = {
    OnInitGlobalModData = { Add = function() end },
    OnSave = { Add = function() end },
}
WorldGenParams = {
    INSTANCE = {
        getSeedString = function()
            return "dt-survivor-world-parity"
        end,
    },
}

PNC = nil
DTHoomans = nil
ProjectHoomans = nil
DTCommon = nil
DTAbstract = {}

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local actorRegistry = Actors.NewRegistry()
local SurvivorWorld = require
    "PsychopatzCore/SurvivorWorld/PsychopatzSurvivorWorld"
SurvivorWorld.RuntimeStore.ResetForTests()

local anchor = { x = 9000, y = 8500, z = 0 }
local expected, expectedReason =
    SurvivorWorld.Bootstrap.BuildPlan({
        seedString = "dt-survivor-world-parity",
        anchor = anchor,
        communityCount = 3,
        groupCount = 3,
        traderGroupCount = 2,
        source = "WORLD_POPULATION_BOOTSTRAP",
    })
T.truthy(expected, expectedReason)

local Runtime = T.load(
    "DTAbstract",
    "server",
    "DTAbstract/DTAbstract_SurvivorWorldRuntime.lua"
)
Runtime.SetActorRegistry(actorRegistry)

local registry, reason = Runtime.Ensure({
    anchor = anchor,
    actorRegistry = actorRegistry,
})
T.truthy(registry, reason)
T.equal(PNC, nil,
    "standalone DTAbstract unexpectedly required ProjectHoomans PNC")
T.equal(DTHoomans, nil,
    "standalone DTAbstract unexpectedly required DTHoomans")

local function sortedKeys(map)
    local output = {}
    for id in pairs(map or {}) do
        output[#output + 1] = id
    end
    table.sort(output)
    return output
end

local expectedCommunityIDs = {}
local expectedFactionIDs = {}
for _, item in ipairs(expected.communities or {}) do
    expectedCommunityIDs[item.communityID] = true
    expectedFactionIDs[item.factionID] = true
end
local expectedGroupIDs = {}
local expectedActorIDs = {}
for _, item in ipairs(expected.groups or {}) do
    expectedGroupIDs[item.groupID] = true
    expectedFactionIDs[item.factionID] = true
    for _, actorID in ipairs(item.memberActorIDs or {}) do
        expectedActorIDs[actorID] = true
    end
end
for _, item in ipairs(expected.communities or {}) do
    for _, actorID in ipairs(item.memberActorIDs or {}) do
        expectedActorIDs[actorID] = true
    end
end

local snapshot = registry:Snapshot()
local actualCommunityIDs = sortedKeys(snapshot.communities)
local actualFactionIDs = sortedKeys(snapshot.factions)
local actualGroupIDs = sortedKeys(snapshot.groups)
local plannedCommunityIDs = sortedKeys(expectedCommunityIDs)
local plannedFactionIDs = sortedKeys(expectedFactionIDs)
local plannedGroupIDs = sortedKeys(expectedGroupIDs)

T.equal(#actualCommunityIDs, #plannedCommunityIDs,
    "canonical community count diverged from Core plan")
T.equal(#actualFactionIDs, #plannedFactionIDs,
    "canonical faction count diverged from Core plan")
T.equal(#actualGroupIDs, #plannedGroupIDs,
    "canonical group count diverged from Core plan")

for index, id in ipairs(plannedCommunityIDs) do
    T.equal(actualCommunityIDs[index], id,
        "community identity diverged from Core plan")
end
for index, id in ipairs(plannedFactionIDs) do
    T.equal(actualFactionIDs[index], id,
        "faction identity diverged from Core plan")
end
for index, id in ipairs(plannedGroupIDs) do
    T.equal(actualGroupIDs[index], id,
        "group identity diverged from Core plan")
end

for actorID in pairs(expectedActorIDs) do
    local actor = actorRegistry:Get(actorID)
    T.truthy(actor,
        "planned Core actor missing: " .. tostring(actorID))
    T.falsy(
        actor.personalInventory
            and actor.personalInventory.mode == "FULL",
        "untouched abstract actor persisted FULL inventory: "
            .. tostring(actorID)
    )
end

local persisted = roots["PsychopatzCore.SurvivorWorld"]
T.truthy(
    persisted and type(persisted.registry) == "string",
    "standalone DTAbstract did not persist canonical Core world"
)
T.equal(
    roots["DTAbstract.SurvivorWorld"],
    nil,
    "DTAbstract created a parallel world ModData root"
)

T.finish("dt_survivor_world_identity_parity_smoke")

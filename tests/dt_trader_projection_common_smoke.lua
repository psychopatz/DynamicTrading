local T = require "tests/support/test"
T.addPackagePaths()

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local authority = Actors.NewRegistry()
PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = Actors

getGameTime = function()
    return { getWorldAgeHours = function() return 10 end }
end

local abstractActor = assert(authority:Create({
    actorId = "actor:projection:abstract",
    identitySeed = "projection-abstract",
    world = { position = { x = 100, y = 200, z = 0 } },
}))
local physicalActor = assert(authority:Create({
    actorId = "actor:projection:physical",
    identitySeed = "projection-physical",
    world = { position = { x = 300, y = 400, z = 0 } },
}))
local physicalJourney = assert(Actors.World.StartJourney(
    physicalActor.world, physicalActor.actorId, {
        journeyID = "journey:projection:physical",
        origin = { x = 300, y = 400, z = 0 },
        destination = { x = 500, y = 400, z = 0 },
        speed = 20,
        startAt = 0,
    }, 0))
assert(authority:Commit(physicalActor.actorId, {
    world = physicalJourney,
}, physicalActor.revision))
physicalActor = authority:Get(physicalActor.actorId)

DTCommon = {
    TraderService = {},
}
local Providers = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderProviderRegistry.lua")
DTCommon.TraderProviders = Providers
Providers.Register("FixtureAbstract", {
    kind = "abstract",
    getActorRegistry = function() return authority end,
    getPosition = function()
        return { x = 101, y = 201, z = 0 }
    end,
})
Providers.Register("FixturePhysical", {
    kind = "physical",
    getActorRegistry = function() return authority end,
    getPosition = function()
        return { x = 333, y = 444, z = 0 }
    end,
})

local records = {
    ["trader:projection:abstract"] = {
        n = "Abstract Projection",
        ca = {
            actorID = abstractActor.actorId,
            provider = "FixtureAbstract",
            providerState = "abstract",
        },
    },
    ["trader:projection:physical"] = {
        n = "Physical Projection",
        ca = {
            actorID = physicalActor.actorId,
            provider = "FixturePhysical",
            providerState = "materialized",
            providerBodyID = "body:projection:physical",
        },
    },
}
DTCommon.TraderService.ForEach = function(callback)
    for id, record in pairs(records) do callback(id, record) end
end
DTCommon.TraderService.GetRecord = function(id) return records[id] end

local registeredSource = nil
local registeredProvider = nil
local broadcasts = 0
package.preload["PsychopatzCore/Actors/PsychopatzActorProjectionServer"] =
    function()
        return {
            RegisterProvider = function(sourceID, provider)
                registeredSource = sourceID
                registeredProvider = provider
                return true
            end,
            Broadcast = function(sourceID)
                T.equal(sourceID, "DynamicTrading",
                    "projection broadcast source is not common")
                broadcasts = broadcasts + 1
                return 1
            end,
        }
    end

DTCommon.TraderWorld = {
    RegisterChangeListener = function(id, callback)
        T.equal(id, "DTCommon:trader_projection",
            "projection listener registration ID mismatch")
        DTCommon.TraderWorld.listener = callback
        return true
    end,
}

local Bridge = T.load(
    "DTCommon", "server", "DTCommon/DTCommon_TraderProjectionServer.lua")
T.equal(Bridge.SOURCE_ID, "DynamicTrading",
    "projection source still belongs to an adopter")
T.equal(registeredSource, "DynamicTrading",
    "Core projection provider registered under wrong source")
T.truthy(registeredProvider
    and registeredProvider.BuildEntries == Bridge.BuildEntries,
    "common projection provider was not registered")

local entries = Bridge.BuildEntries()
T.equal(#entries, 2, "common projection did not include both representations")
local byActor = {}
for _, entry in ipairs(entries) do byActor[entry.actorID] = entry end
T.equal(byActor[abstractActor.actorId].provider, "FixtureAbstract",
    "abstract provider identity was lost")
T.equal(byActor[physicalActor.actorId].provider, "FixturePhysical",
    "physical provider identity was lost")
T.equal(byActor[physicalActor.actorId].bodyID, "body:projection:physical",
    "physical body identity was lost")
T.equal(byActor[abstractActor.actorId].position.x, 101,
    "abstract provider position override was ignored")
T.equal(byActor[physicalActor.actorId].position.x, 333,
    "physical body position did not override stale Core journey position")
T.equal(byActor[physicalActor.actorId].position.y, 444,
    "physical body Y projection mismatch")
T.equal(byActor[physicalActor.actorId].journey, nil,
    "physical projection leaked abstract journey interpolation")

DTCommon.TraderWorld.listener("policy_changed", {})
T.equal(broadcasts, 1,
    "common world changes did not refresh projection")

-- Client presentation consumes the same neutral source and exposes both rows.
local projections = byActor
package.preload["PsychopatzCore/Actors/PsychopatzActorProjectionClient"] =
    function()
        return {
            Request = function(sourceID)
                T.equal(sourceID, "DynamicTrading",
                    "client requested adopter-specific projection source")
                return true
            end,
            Get = function(actorID) return projections[actorID] end,
            GetSourceRevision = function(sourceID)
                T.equal(sourceID, "DynamicTrading",
                    "client cache revision source mismatch")
                return 7
            end,
        }
    end

local Presentation = T.load(
    "DTCommon", "client", "DTCommon/DTCommon_TraderPresentation.lua")
T.equal(Presentation.SOURCE_ID, "DynamicTrading",
    "client presentation source still belongs to an adopter")
T.truthy(Presentation.RequestSync(), "common projection sync request failed")

local rows = Presentation.ListTraderRecords(true, 1)
T.equal(#rows, 2, "common presentation did not list both providers")
local posA = assert(Presentation.GetPosition(
    records["trader:projection:abstract"], 10))
local posP = assert(Presentation.GetPosition(
    records["trader:projection:physical"], 10))
T.equal(posA.x, 101, "abstract projected position mismatch")
T.equal(posP.x, 333, "physical projected position mismatch")

T.finish("dt_trader_projection_common_smoke")

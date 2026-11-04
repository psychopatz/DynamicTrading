local T = require "tests/support/test"
T.addPackagePaths()

DTAbstract = nil
DTHoomans = nil
PNC = nil

local now = 10
getGameTime = function()
    return { getWorldAgeHours = function() return now end }
end

DTCommon = {
    STATUS_READY = "READY",
}

local projectionPublishes = 0
PsychopatzCore = {
    SurvivorWorldProjectionServer = {
        Publish = function()
            projectionPublishes = projectionPublishes + 1
            return 1
        end,
    },
}

local data = { t = {} }
local touches = 0
local transmissions = 0
DTCommon.Storage = {
    IsAuthority = function() return true end,
    GetData = function() return data end,
    Touch = function() touches = touches + 1 end,
    Transmit = function() transmissions = transmissions + 1 end,
}
DTCommon.TraderStock = {
    SaveAndTransmit = function()
        transmissions = transmissions + 1
        return true
    end,
}

local Policy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
local Providers = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderProviderRegistry.lua")

local settlements = {
    {
        settlementID = "settlement:a",
        name = "A",
        position = { x = 10, y = 20, z = 0 },
        provider = "fixture",
        enabled = true,
    },
    {
        settlementID = "settlement:b",
        name = "B",
        position = { x = 30, y = 40, z = 0 },
        provider = "fixture",
        enabled = true,
    },
}
DTCommon.SettlementDirectory = {
    List = function() return settlements end,
    Get = function(id)
        for _, entry in ipairs(settlements) do
            if entry.settlementID == id then return entry end
        end
    end,
}

local visitIDs = {}
local visitCount = 0
DTCommon.TraderService = {
    ForEach = function(callback)
        for id, record in pairs(data.t) do callback(id, record) end
        return true
    end,
    GetRecord = function(id) return data.t[id] end,
    MarkSettlementVisit = function(traderID, options)
        if options.visitID and visitIDs[options.visitID] then
            return nil, "duplicate_visit"
        end
        if options.visitID then visitIDs[options.visitID] = true end
        visitCount = visitCount + 1
        local record = data.t[traderID]
        record.ca.visitCount = (record.ca.visitCount or 0) + 1
        record.ca.lastVisitID = options.visitID
        record.ca.lastSettlementID = options.settlementID
        record.ca.currentSettlementID = options.settlementID
        return { traderID = traderID, visitCount = record.ca.visitCount }
    end,
}

local movement = {}
local spawnSequence = 0
Providers.Register("FixtureProvider", {
    priority = 500,
    kind = "fixture",
    isAvailable = function() return true end,
    spawnTrader = function(spec)
        spawnSequence = spawnSequence + 1
        local traderID = "trader:fixture:" .. tostring(spawnSequence)
        local actorID = "actor:fixture:" .. tostring(spawnSequence)
        data.t[traderID] = {
            n = "Fixture Trader",
            b = 1000,
            s = "READY",
            ca = Policy.New({
                actorID = actorID,
                provider = "FixtureProvider",
                providerState = "abstract",
                homeSettlementID = "settlement:a",
                currentSettlementID = "settlement:a",
                worldManaged = true,
                worldRole = spec.worldRole,
            }),
        }
        return {
            traderID = traderID,
            actorID = actorID,
            settlementID = "settlement:a",
        }
    end,
    canTravelTo = function() return true end,
    startMovement = function(traderID, _, request)
        movement[traderID] = {
            journeyID = request.journeyID,
            destinationSettlementID = request.destinationSettlementID,
            arrived = false,
        }
        return { status = "en_route", journeyID = request.journeyID }
    end,
    pollMovement = function(traderID)
        local state = movement[traderID]
        if state and state.arrived then
            return {
                status = "arrived",
                journeyID = state.journeyID,
                settlementID = state.destinationSettlementID,
            }
        end
        return { status = "en_route", journeyID = state and state.journeyID }
    end,
})

local World = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderWorld.lua")

local forced = World.Tick(true, now)
T.equal(forced.spawned, 2,
    "forced/bootstrap tick did not fill bounded trader target")
T.equal(World.CountManaged("roaming"), 2,
    "forced/bootstrap tick population target mismatch")
T.equal(projectionPublishes, 0,
    "shared trader creation published projection synchronously")
T.truthy(World.ProjectionDirty,
    "shared trader creation did not mark Core projection dirty")
T.truthy(World.ConsumeProjectionDirty(),
    "shared projection dirty flag was not consumable")
T.falsy(World.ConsumeProjectionDirty(),
    "shared projection dirty flag was not coalesced")

-- Normal cadence remains bounded to one spawn per population check.
data.t = {}
movement = {}
spawnSequence = 0

local first = World.EnsurePopulation(now)
T.equal(first.spawned, 1, "common runtime did not create first trader")
local second = World.EnsurePopulation(now)
T.equal(second.spawned, 1, "common runtime did not fill bounded population")
T.equal(World.CountManaged("roaming"), 2,
    "common runtime population target mismatch")

local traderID = "trader:fixture:1"
local original = data.t[traderID]
local actorID = original.ca.actorID
local budget = original.b

local destination = assert(World.SelectDestination(
    traderID, "settlement:a", now))
T.equal(destination.settlementID, "settlement:b",
    "common route selection did not choose alternate settlement")

local journey = assert(World.BeginJourney(
    traderID, destination.settlementID, { now = now }))
T.equal(data.t[traderID].ca.lifecycleState, "traveling",
    "common lifecycle did not own departure state")
T.equal(data.t[traderID].ca.currentSettlementID, nil,
    "departure did not clear current settlement")
T.equal(data.t[traderID].ca.destinationSettlementID, "settlement:b",
    "departure did not persist destination")

movement[traderID].arrived = true
now = 12
local status, reason = World.AdvanceTrader(traderID, now)
T.equal(status, "arrived", reason)
T.equal(visitCount, 1, "arrival did not apply one commercial visit")
T.equal(data.t[traderID].ca.currentSettlementID, "settlement:b",
    "arrival did not set canonical current settlement")
T.equal(data.t[traderID].ca.lifecycleState, "cooldown",
    "arrival did not enter common cooldown")
T.truthy(data.t[traderID].ca.cooldownUntil > now,
    "common cooldown was not persisted")

local duplicate, duplicateReason = World.Arrive(
    traderID, "settlement:b", {
        now = now + 0.1,
        journeyID = journey.journeyID,
    })
T.truthy(duplicate, duplicateReason)
T.truthy(duplicate.duplicate, "repeated arrival was not idempotent")
T.equal(visitCount, 1, "repeated arrival duplicated commercial effects")

T.equal(data.t[traderID].ca.actorID, actorID,
    "common lifecycle changed actor identity")
T.equal(data.t[traderID].b, budget,
    "common lifecycle changed trader budget")

-- Provider set is open/registered rather than a hard-coded DTAbstract/DTHoomans
-- list. A newly registered provider lease is accepted.
Providers.Register("FixtureProviderTwo", { priority = 100 })
local leasePolicy, leaseReason = Policy.SetProviderLease(data.t[traderID], {
    actorID = actorID,
    provider = "FixtureProviderTwo",
    state = "abstract",
    leaseID = "lease:fixture:2",
    revision = 2,
})
T.truthy(leasePolicy, leaseReason)
T.equal(leasePolicy.provider, "FixtureProviderTwo",
    "registered provider was rejected by common policy")
T.equal(leasePolicy.actorID, actorID,
    "provider transition changed actor identity")

T.truthy(touches > 0 and transmissions > 0,
    "common lifecycle did not persist state")
T.equal(DTAbstract, nil, "common lifecycle required DTAbstract global")
T.equal(DTHoomans, nil, "common lifecycle required DTHoomans global")
T.equal(PNC, nil, "common lifecycle required PNC global")

T.finish("dt_trader_world_common_smoke")

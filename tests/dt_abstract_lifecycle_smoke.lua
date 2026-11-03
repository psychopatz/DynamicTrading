local T = require "tests/support/test"
T.addPackagePaths()

local coreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY")
    or "../psychopatzCore"
package.path = coreRepository
    .. "/Contents/mods/PsychopatzCore/common/media/lua/shared/?.lua;"
    .. package.path

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local World = Actors.World
local Journey = require "PsychopatzCore/Actors/PsychopatzActorJourney"
local actorRegistry = Actors.NewRegistry()

-- ---------------------------------------------------------------------------
-- Setup environment & mocks
-- ---------------------------------------------------------------------------
local sentCommands = {}
local clientCommandHandler = nil
local worldHours = 10

isServer = function() return true end
getGameTime = function()
    return {
        getWorldAgeHours = function() return worldHours end,
    }
end
sendServerCommand = function(player, module, command, args)
    sentCommands[#sentCommands + 1] = {
        player = player,
        module = module,
        command = command,
        args = args,
    }
end
Events = {
    OnClientCommand = {
        Add = function(fn) clientCommandHandler = fn end,
    },
    OnGameStart = { Add = function() end },
    OnTick = { Add = function() end },
}

PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = Actors
PsychopatzCore.RuntimeRole = {
    AllowsServerCode = function() return true end,
}
PsychopatzCore.Debug = {
    CanUse = function(player)
        return player and player.debugAllowed ~= false
    end,
}

DTCommon = DTCommon or {}
local Directory = T.load("DTCommon", "shared", "DTCommon/DTCommon_SettlementDirectory.lua")
T.truthy(Directory, "Directory loaded")
Directory.EnsureDefaults()

local Policy = T.load("DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")

-- Mock DTCommon Storage & TraderService
local storeData = { t = {} }
local visitCalls = {}

DTCommon.STATUS_READY = "READY"
DTCommon.Storage = {
    IsAuthority = function() return true end,
    GetData = function() return storeData end,
    SaveInventory = function(record, stock)
        record.i = { rows = {} }
        return true
    end,
}
DTCommon.TraderStock = {
    New = function() return {} end,
    SaveAndTransmit = function() return true end,
}
DTCommon.TraderService = {
    ForEach = function(callback)
        for id, record in pairs(storeData.t) do
            callback(id, record)
        end
    end,
    GetRecord = function(traderID)
        return storeData.t[traderID]
    end,
    Create = function(def)
        local id = def.traderID or "trader:test"
        local record = {
            n = def.displayName or "Trader",
            r = def.traderRole or "Roaming Trader",
            b = def.budget or 1000,
            s = DTCommon.STATUS_READY,
            v = 1,
            a = 1,
            ca = Policy.New(def),
        }
        storeData.t[id] = record
        return id, record
    end,
    Remove = function(traderID)
        if storeData.t[traderID] then
            storeData.t[traderID] = nil
            return true
        end
        return false
    end,
    MarkSettlementVisit = function(traderID, options)
        visitCalls[#visitCalls + 1] = { traderID = traderID, options = options }
        local record = storeData.t[traderID]
        if record and record.ca then
            record.ca.lastSettlementID = options.settlementID
            record.ca.visitCount = (record.ca.visitCount or 0) + 1
        end
        return true
    end,
}

DTAbstract = DTAbstract or {}
T.load("DTAbstract", "shared", "DTAbstract/DTAbstract_CoreProvider.lua")

-- ---------------------------------------------------------------------------
-- 1. Load DTAbstract Server and Lifecycle
-- ---------------------------------------------------------------------------
local Lifecycle = T.load("DTAbstract", "server", "DTAbstract/DTAbstract_Lifecycle.lua")
T.truthy(Lifecycle, "DTAbstract.Lifecycle loaded")
Lifecycle.SetActorRegistry(actorRegistry)

local Server = T.load("DTAbstract", "server", "DTAbstract/DTAbstract_Server.lua")
T.truthy(Server, "DTAbstract.Server loaded")
T.truthy(clientCommandHandler, "client command handler registered")

-- ---------------------------------------------------------------------------
-- 2. Debug spawn: SpawnAbstractTraderNearPlayer
-- ---------------------------------------------------------------------------
local testPlayer = {
    debugAllowed = true,
    getX = function() return 10600 end,
    getY = function() return 9950 end,
    getZ = function() return 0 end,
    getUsername = function() return "tester" end,
}

local spawned, reason = Server.SpawnAbstractTraderNearPlayer(testPlayer, {
    displayName = "Debug Trader One",
})
T.truthy(spawned, reason)
T.truthy(spawned.traderID, "spawned trader has ID")
T.truthy(spawned.actorID, "spawned trader has actor ID")
T.truthy(spawned.position, "spawned trader has position")
T.equal(Lifecycle.CountAbstractTraders(), 1, "exactly one abstract trader created")

-- Check server command result sent to player
T.truthy(#sentCommands >= 2, "commands sent to client")
local resultCmd = sentCommands[#sentCommands]
T.equal(resultCmd.command, "TraderDebugActionResult", "debug result command sent")
T.equal(resultCmd.args.action, "spawn_near", "action was spawn_near")
T.equal(resultCmd.args.accepted, true, "debug action accepted")
T.equal(resultCmd.args.provider, "DTAbstract", "provider is DTAbstract")

-- Non-debug player check
sentCommands = {}
local normalPlayer = { debugAllowed = false }
local rejected, rejReason = Server.SpawnAbstractTraderNearPlayer(normalPlayer, {})
T.falsy(rejected, "unauthorized player spawn rejected")
T.equal(rejReason, "not_authorized", "rejection reason is not_authorized")
T.equal(sentCommands[1].args.accepted, false, "rejected command sent to client")

-- ---------------------------------------------------------------------------
-- 3. Core Actor Binding Verification
-- ---------------------------------------------------------------------------
local traderID = spawned.traderID
local actorID = spawned.actorID
local actor = actorRegistry:Get(actorID)
T.truthy(actor, "actor exists in registry")
T.equal(actor.providerLease.provider, "DTAbstract", "actor lease is DTAbstract")
T.equal(actor.providerLease.state, "abstract", "actor state is abstract")

local record = DTCommon.TraderService.GetRecord(traderID)
T.truthy(record, "trader record exists")
T.equal(record.ca.actorID, actorID, "trader record references actorID")
T.equal(record.ca.provider, "DTAbstract", "trader record provider is DTAbstract")

-- ---------------------------------------------------------------------------
-- 4. Standalone Journey Progression & Midpoint Projection
-- ---------------------------------------------------------------------------
local destSettlementID = "settlement:westpoint"
local startOK, journey = Lifecycle.StartTraderJourney(traderID, destSettlementID, worldHours)
T.truthy(startOK, "journey started")
T.equal(journey.state, "en_route", "journey en route")

-- Check actor world state mid-journey
local updatedActor = actorRegistry:Get(actorID)
T.equal(updatedActor.world.journey.destinationAnchorID or destSettlementID, destSettlementID, "destination matches")

-- Advance half-way
local duration = journey.distanceTotal / Lifecycle.DEFAULT_SPEED
local midTime = worldHours + (duration * 0.5)
local midStatus = Lifecycle.AdvanceTrader(traderID, midTime)
T.equal(midStatus, "en_route", "mid-journey status is en_route")

local midActor = actorRegistry:Get(actorID)
local midPos = World.ProjectPosition(midActor.world, midTime)
T.truthy(midPos, "midpoint position projected")
local origPos = journey.origin
local targetPos = Directory.ResolvePosition(destSettlementID)
local expectedMidX = origPos.x + (targetPos.x - origPos.x) * 0.5
local expectedMidY = origPos.y + (targetPos.y - origPos.y) * 0.5
T.truthy(math.abs(midPos.x - expectedMidX) < 2, "midpoint X within 2 tiles")
T.truthy(math.abs(midPos.y - expectedMidY) < 2, "midpoint Y within 2 tiles")

-- ---------------------------------------------------------------------------
-- 5. Arrival and Exactly-Once Settlement Visit / Exchange
-- ---------------------------------------------------------------------------
local arrTime = worldHours + duration + 1
local arrStatus = Lifecycle.AdvanceTrader(traderID, arrTime)
T.equal(arrStatus, "arrived", "arrival status is arrived")

local arrivedRecord = DTCommon.TraderService.GetRecord(traderID)
T.equal(arrivedRecord.ca.currentSettlementID, destSettlementID, "current settlement updated to destination")
T.equal(arrivedRecord.ca.destinationSettlementID, nil, "destination cleared on arrival")
T.equal(#visitCalls, 1, "exactly one settlement visit recorded")
T.equal(visitCalls[1].options.settlementID, destSettlementID, "visit destination recorded")

-- 6. Repeat advance at same time: does NOT duplicate exchange
local repeatStatus = Lifecycle.AdvanceTrader(traderID, arrTime + 0.1)
T.equal(#visitCalls, 1, "repeat advance does NOT duplicate settlement visit")

-- ---------------------------------------------------------------------------
-- 7. OnClientCommand Router Verification
-- ---------------------------------------------------------------------------
sentCommands = {}
clientCommandHandler("DTAbstract", "ForceTick", testPlayer, { now = arrTime + 10 })
T.truthy(#sentCommands >= 1, "ForceTick responded")
T.equal(sentCommands[1].args.action, "force_tick", "action was force_tick")
T.equal(sentCommands[1].args.accepted, true, "force_tick accepted")

T.finish("dt_abstract_lifecycle_smoke")

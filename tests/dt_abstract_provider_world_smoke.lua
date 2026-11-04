local T = require "tests/support/test"
T.addPackagePaths()

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local actorRegistry = Actors.NewRegistry()

local sentCommands = {}
local clientCommandHandler
local worldHours = 10
local roots = {}

isClient = function() return false end
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
ModData = {
    get = function(key) return roots[key] end,
    getOrCreate = function(key)
        roots[key] = roots[key] or {}
        return roots[key]
    end,
}
Events = {
    OnClientCommand = {
        Add = function(fn) clientCommandHandler = fn end,
    },
    OnGameStart = { Add = function() end },
    OnTick = { Add = function() end },
    OnInitGlobalModData = { Add = function() end },
    OnSave = { Add = function() end },
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
local Directory = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_SettlementDirectory.lua")
T.truthy(Directory, "Directory loaded")
T.equal(#Directory.List(), 0,
    "standalone directory must not auto-register Kentucky defaults")

local Policy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")

local storeData = { t = {} }
local visitCalls = {}

DTCommon.STATUS_READY = "READY"
DTCommon.Storage = {
    IsAuthority = function() return true end,
    GetData = function() return storeData end,
    Touch = function() end,
    Transmit = function() end,
    SaveInventory = function(record)
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
        if storeData.t[id] then
            return nil, "trader_exists"
        end
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
        visitCalls[#visitCalls + 1] = {
            traderID = traderID,
            options = options,
        }
        local record = storeData.t[traderID]
        if record and record.ca then
            record.ca.lastSettlementID = options.settlementID
            record.ca.visitCount =
                (record.ca.visitCount or 0) + 1
        end
        return true
    end,
}

-- Register the Core-backed commercial settlement facade before the world
-- exists. It must become populated from SurvivorWorld, not static defaults.
T.load(
    "DTCommon",
    "server",
    "DTCommon/DTCommon_CoreSettlementDirectoryProvider.lua"
)

DTAbstract = DTAbstract or {}
T.load(
    "DTAbstract",
    "shared",
    "DTAbstract/DTAbstract_CoreProvider.lua"
)
local SurvivorRuntime = T.load(
    "DTAbstract",
    "server",
    "DTAbstract/DTAbstract_SurvivorWorldRuntime.lua"
)
SurvivorRuntime.SetActorRegistry(actorRegistry)

local bootstrapAnchor = { x = 10625, y = 9950, z = 0 }
local survivorWorld, bootstrapReason = SurvivorRuntime.Ensure({
    anchor = bootstrapAnchor,
    actorRegistry = actorRegistry,
})
T.truthy(survivorWorld, bootstrapReason)
local counts = survivorWorld:Counts()
T.truthy(counts.communities >= 3, "Core communities bootstrapped")
T.truthy(counts.groups >= 3, "Core groups bootstrapped")
T.truthy(#Directory.List() >= 3,
    "commercial settlement directory reads Core communities")
T.equal(Directory.Get("settlement:rosewood"), nil,
    "static Kentucky fallback is not active")

local actorCountBeforeBinding = actorRegistry:Count()
local groupCountBeforeBinding = counts.groups

local Provider = T.load(
    "DTAbstract",
    "server",
    "DTAbstract/DTAbstract_TraderWorldProvider.lua"
)
Provider.SetActorRegistry(actorRegistry)
local TraderWorld = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_TraderWorld.lua")
T.truthy(TraderWorld, "DTCommon.TraderWorld loaded")

local Server = T.load(
    "DTAbstract", "server", "DTAbstract/DTAbstract_Server.lua")
T.truthy(Server, "DTAbstract.Server loaded")
T.truthy(clientCommandHandler, "client command handler registered")

local testPlayer = {
    debugAllowed = true,
    getX = function() return 10600 end,
    getY = function() return 9950 end,
    getZ = function() return 0 end,
    getUsername = function() return "tester" end,
}

local spawned, reason = TraderWorld.SpawnTrader(
    "DTAbstract",
    {
        debug = true,
        position = {
            x = testPlayer:getX() + 25,
            y = testPlayer:getY(),
            z = testPlayer:getZ(),
        },
        displayName = "Debug Trader One",
    }
)
T.truthy(spawned, reason)
T.truthy(spawned.traderID, "spawned trader has ID")
T.truthy(spawned.actorID, "spawned trader has actor ID")
T.truthy(spawned.groupID, "spawned trader binds canonical group")
T.truthy(spawned.position, "spawned trader has canonical position")
T.equal(spawned.position.x, 10625,
    "shared debug spawn did not place canonical group at requested X")
T.equal(spawned.position.y, 9950,
    "shared debug spawn did not place canonical group at requested Y")
T.equal(
    actorRegistry:Count(),
    actorCountBeforeBinding,
    "binding a trader must not create another Core actor"
)
T.equal(
    SurvivorRuntime.GetRegistry():Counts().groups,
    groupCountBeforeBinding,
    "binding a trader must not create another survivor group"
)
T.equal(
    TraderWorld.CountByProvider("DTAbstract"),
    1,
    "exactly one commercial role bound"
)

local traderID = spawned.traderID
local actorID = spawned.actorID

sentCommands = {}
clientCommandHandler(
    "DTAbstract",
    "ConversationAccessRequest",
    testPlayer,
    { traderID = traderID, mode = "debug" }
)
T.equal(sentCommands[1].module, "DTAbstract",
    "debug Talk authorization used the wrong command module")
T.equal(sentCommands[1].command, "ConversationAccessResult",
    "debug Talk did not publish Core conversation access result")
T.truthy(sentCommands[1].args.accepted,
    "debug Talk Core authorization was not accepted")
T.equal(sentCommands[1].args.reason, "core_conversation_authorized",
    "debug Talk Core authorization reason mismatch")
T.equal(sentCommands[1].args.actorID, actorID,
    "debug Talk authorization lost canonical actor identity")
T.equal(sentCommands[1].args.mode, "debug",
    "debug Talk authorization mode mismatch")

local actor = actorRegistry:Get(actorID)
T.truthy(actor, "canonical actor exists")
T.equal(
    actor.providerLease.provider,
    "DTAbstract",
    "canonical actor lease is DTAbstract"
)
T.equal(
    actor.providerLease.state,
    "abstract",
    "canonical actor state is abstract"
)

local boundGroup = assert(
    SurvivorRuntime.FindGroupForActor(actorID)
)
T.equal(
    boundGroup.id,
    spawned.groupID,
    "commercial role bound to canonical group"
)
local record = DTCommon.TraderService.GetRecord(traderID)
T.truthy(record, "trader record exists")
T.equal(
    record.ca.actorID,
    actorID,
    "trader record references canonical actor"
)
T.equal(
    record.ca.provider,
    "DTAbstract",
    "trader record provider is DTAbstract"
)

T.load(
    "DTAbstract",
    "server",
    "DTAbstract/DTAbstract_CommonIntegration.lua"
)
local handled, nearbyAllowed, nearbyReason =
    DTCommon.Integrations.ValidateTraderAccess(
        testPlayer,
        record,
        "nearby"
    )
T.truthy(handled, "DTAbstract nearby access adapter did not claim the record")
T.truthy(nearbyAllowed,
    "DTAbstract nearby access rejected an in-range canonical trader")
T.equal(nearbyReason, nil,
    "DTAbstract nearby access returned an unexpected reason")
testPlayer = {
    debugAllowed = true,
    getX = function() return 10700 end,
    getY = function() return 9950 end,
    getZ = function() return 0 end,
}
local _, farAllowed, farReason =
    DTCommon.Integrations.ValidateTraderAccess(
        testPlayer,
        record,
        "nearby"
    )
T.falsy(farAllowed,
    "DTAbstract nearby access ignored the provider proximity radius")
T.equal(farReason, "access_denied",
    "DTAbstract nearby access denial reason changed")
testPlayer = {
    debugAllowed = true,
    getX = function() return 10600 end,
    getY = function() return 9950 end,
    getZ = function() return 0 end,
}

-- A second debug bind selects another unused canonical trader-group leader and
-- repositions that canonical group to the requested debug tile.
local explicit, explicitReason = TraderWorld.SpawnTrader(
    "DTAbstract",
    {
        debug = true,
        displayName = "Second Canonical Trader",
        position = { x = 4321, y = 8765, z = 0 },
    }
)
T.truthy(explicit, explicitReason)
T.truthy(explicit.groupID, "second bind has canonical group")
T.truthy(explicit.actorID ~= actorID,
    "second trader uses a distinct canonical actor")
T.equal(explicit.position.x, 4321,
    "second shared debug spawn X mismatch")
T.equal(explicit.position.y, 8765,
    "second shared debug spawn Y mismatch")
T.equal(
    actorRegistry:Count(),
    actorCountBeforeBinding,
    "second bind also creates no actor"
)
T.equal(
    SurvivorRuntime.GetRegistry():Counts().groups,
    groupCountBeforeBinding,
    "second bind creates no group"
)
T.equal(
    TraderWorld.CountByProvider("DTAbstract"),
    2,
    "second canonical trader role bound"
)

-- Once all bootstrap trader candidates are already bound, the shared debug
-- path asks Core to generate one additional canonical group instead of
-- inventing a DT-owned actor ID or failing the debug spawn.
local actorsBeforeGeneratedDebug = actorRegistry:Count()
local groupsBeforeGeneratedDebug =
    SurvivorRuntime.GetRegistry():Counts().groups
local generated, generatedReason = TraderWorld.SpawnTrader(
    "DTAbstract",
    {
        debug = true,
        position = { x = 2222, y = 3333, z = 0 },
    }
)
T.truthy(generated, generatedReason)
T.equal(generated.position.x, 2222,
    "generated debug trader X mismatch")
T.equal(generated.position.y, 3333,
    "generated debug trader Y mismatch")
T.equal(actorRegistry:Count(), actorsBeforeGeneratedDebug + 3,
    "Core debug group did not create its bounded three canonical actors")
T.equal(
    SurvivorRuntime.GetRegistry():Counts().groups,
    groupsBeforeGeneratedDebug + 1,
    "Core debug group was not committed to SurvivorWorld"
)
T.equal(
    TraderWorld.CountByProvider("DTAbstract"),
    3,
    "generated canonical debug trader was not commercially bound"
)
T.truthy(
    SurvivorRuntime.GetRegistry():GetGroup(generated.groupID),
    "generated debug trader group is missing from Core"
)
local persistedWorld = roots["PsychopatzCore.SurvivorWorld"]
T.truthy(
    persistedWorld and type(persistedWorld.registry) == "string",
    "generated debug trader did not leave a persisted Core world registry"
)
T.truthy(
    string.find(persistedWorld.registry, generated.groupID, 1, true),
    "generated debug trader group was not written to Core world persistence"
)

-- Select any other canonical community as the commercial destination.
local destinationID
for _, settlement in ipairs(Directory.List()) do
    if settlement.settlementID
        ~= record.ca.currentSettlementID
    then
        destinationID = settlement.settlementID
        break
    end
end
T.truthy(destinationID, "alternate Core community available")

local started, startReason = TraderWorld.BeginJourney(
    traderID,
    destinationID,
    { now = worldHours }
)
T.truthy(started, startReason)

local movingGroup = assert(
    SurvivorRuntime.FindGroupForActor(actorID)
)
local journey = movingGroup.journey
T.truthy(journey, "provider created Core group journey")
T.equal(journey.state, "en_route", "group journey en route")
T.equal(
    journey.destinationAnchorID,
    destinationID,
    "group destination matches commercial destination"
)
T.equal(
    actorRegistry:Get(actorID).world.journey,
    nil,
    "normal group travel must not duplicate actor journey state"
)

local duration =
    journey.distanceTotal / Provider.DEFAULT_SPEED
local midTime = worldHours + (duration * 0.5)
local midStatus = TraderWorld.AdvanceTrader(
    traderID,
    midTime
)
T.equal(
    midStatus,
    "en_route",
    "mid-journey status is en_route"
)

local midPos = assert(
    Provider.getPosition(
        traderID,
        DTCommon.TraderService.GetRecord(traderID),
        midTime
    )
)
local targetPos = Directory.ResolvePosition(destinationID)
local expectedMidX =
    journey.origin.x
    + (targetPos.x - journey.origin.x) * 0.5
local expectedMidY =
    journey.origin.y
    + (targetPos.y - journey.origin.y) * 0.5
T.truthy(
    math.abs(midPos.x - expectedMidX) < 2,
    "group midpoint X within 2 tiles"
)
T.truthy(
    math.abs(midPos.y - expectedMidY) < 2,
    "group midpoint Y within 2 tiles"
)

local arrTime = worldHours + duration + 1
local arrStatus = TraderWorld.AdvanceTrader(
    traderID,
    arrTime
)
T.equal(arrStatus, "arrived", "arrival status is arrived")

local arrivedRecord =
    DTCommon.TraderService.GetRecord(traderID)
T.equal(
    arrivedRecord.ca.currentSettlementID,
    destinationID,
    "current settlement updated to destination"
)
T.equal(
    arrivedRecord.ca.destinationSettlementID,
    nil,
    "destination cleared on arrival"
)
T.equal(#visitCalls, 1,
    "exactly one settlement visit recorded")
T.equal(
    visitCalls[1].options.settlementID,
    destinationID,
    "visit destination recorded"
)

local arrivedGroup = assert(
    SurvivorRuntime.FindGroupForActor(actorID)
)
T.equal(
    arrivedGroup.location.id,
    destinationID,
    "canonical group location arrived at same community"
)
T.equal(
    arrivedGroup.state,
    "ARRIVED",
    "canonical group lifecycle arrived"
)

TraderWorld.AdvanceTrader(traderID, arrTime + 0.1)
T.equal(
    #visitCalls,
    1,
    "repeat advance does not duplicate settlement visit"
)

sentCommands = {}
clientCommandHandler(
    "DTAbstract",
    "ForceTick",
    testPlayer,
    { now = arrTime + 10 }
)
T.truthy(#sentCommands >= 1, "ForceTick responded")
T.equal(
    sentCommands[1].args.action,
    "force_tick",
    "action was force_tick"
)
T.equal(
    sentCommands[1].args.accepted,
    true,
    "force_tick accepted"
)

T.finish("dt_abstract_provider_world_smoke")

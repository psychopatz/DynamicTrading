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

local registeredTools = {}
local clientCommandsSent = {}

PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = Actors
PsychopatzCore.Debug = { CanUse = function() return true end }
PsychopatzCore.DebugHub = {
    RegisterTool = function(tool)
        registeredTools[tool.id] = tool
        return true
    end,
}

sendClientCommand = function(module, command, args)
    clientCommandsSent[#clientCommandsSent + 1] = {
        module = module,
        command = command,
        args = args,
    }
    return true
end

DTCommon = DTCommon or {}
local traderStore = { t = {} }
local Policy = T.load("DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")

DTCommon.TraderService = {
    ForEach = function(callback)
        for id, record in pairs(traderStore.t) do
            callback(id, record)
        end
    end,
    GetRecord = function(id) return traderStore.t[id] end,
}

DTAbstract = DTAbstract or {}
DTAbstract.Lifecycle = {
    GetActorRegistry = function() return actorRegistry end,
}

-- Create test actor & trader
local actor = actorRegistry:Create({
    actorId = "actor:debug:1",
    identitySeed = "debug-seed",
    world = { position = { x = 10630, y = 9980, z = 0 } },
})
traderStore.t["trader:debug:1"] = {
    n = "Inspected Trader",
    s = "READY",
    b = 750,
    v = 2,
    ca = Policy.New({
        actorID = actor.actorId,
        provider = "DTAbstract",
        providerState = "abstract",
        homeSettlementID = "settlement:muldraugh",
        currentSettlementID = "settlement:muldraugh",
    }),
}

-- ---------------------------------------------------------------------------
-- 1. Load DTAbstract DebugHub Module & Check Registration
-- ---------------------------------------------------------------------------
local DebugHub = T.load("DTAbstract", "client", "DTAbstract/UI/DTAbstract_DebugHub.lua")
T.truthy(DebugHub, "DebugHub module loaded")

local tool = registeredTools["dtabstract:traders"]
T.truthy(tool, "tool 'dtabstract:traders' registered in DebugHub")
T.equal(tool.title, "Abstract Trader Manager", "tool title")
T.truthy(tool.available(), "tool is available for debug user")

-- ---------------------------------------------------------------------------
-- 2. Read-Only Inspection Verification
-- ---------------------------------------------------------------------------
local list = DebugHub.ListTraders(0)
T.equal(#list, 1, "one trader listed")
local row = list[1]
T.equal(row.traderID, "trader:debug:1", "traderID matches")
T.equal(row.displayName, "Inspected Trader", "name matches")
T.equal(row.actorID, "actor:debug:1", "actorID matches")
T.equal(row.provider, "DTAbstract", "provider is DTAbstract")
T.equal(row.providerState, "abstract", "provider state is abstract")
T.equal(row.budget, 750, "budget matches")
T.equal(row.stockVersion, 2, "stockVersion matches")
T.truthy(row.position, "position projected")
T.equal(row.position.x, 10630, "projected X")
T.equal(row.position.y, 9980, "projected Y")
T.equal(row.currentSettlementID, "settlement:muldraugh", "settlement matches")

-- ---------------------------------------------------------------------------
-- 3. Debug Action Server Command Dispatching
-- ---------------------------------------------------------------------------
clientCommandsSent = {}

DebugHub.SpawnNear({ displayName = "Near Player" })
T.equal(#clientCommandsSent, 1, "SpawnNear sent command")
T.equal(clientCommandsSent[1].module, "DTAbstract", "command target module")
T.equal(clientCommandsSent[1].command, "SpawnAbstractTraderNearPlayer", "spawn command name")
T.equal(clientCommandsSent[1].args.displayName, "Near Player", "spawn args passed")

DebugHub.ForceTick(12)
T.equal(#clientCommandsSent, 2, "ForceTick sent command")
T.equal(clientCommandsSent[2].command, "ForceTick", "force tick command name")

DebugHub.ForceArrival("trader:debug:1")
T.equal(#clientCommandsSent, 3, "ForceArrival sent command")
T.equal(clientCommandsSent[3].command, "ForceArrival", "force arrival command name")
T.equal(clientCommandsSent[3].args.traderID, "trader:debug:1", "target traderID passed")

DebugHub.TeleportToTrader("trader:debug:1")
T.equal(#clientCommandsSent, 4, "TeleportToTrader sent command")
T.equal(clientCommandsSent[4].command, "TeleportToTrader", "teleport command name")

DebugHub.RemoveTrader("trader:debug:1")
T.equal(#clientCommandsSent, 5, "RemoveTrader sent command")
T.equal(clientCommandsSent[5].command, "RemoveTrader", "remove trader command name")

-- ---------------------------------------------------------------------------
-- 4. Locate on Map
-- ---------------------------------------------------------------------------
local located, locPos = DebugHub.LocateOnMap("trader:debug:1")
T.truthy(located, "trader located on map")
T.equal(locPos.x, 10630, "located position matches")

T.finish("dt_abstract_debug_hub_smoke")

local T = require "tests/support/test"
T.addPackagePaths()

local clientHandler
local tickHandler
Events = {
    OnClientCommand = {
        Add = function(fn) clientHandler = fn end,
    },
    OnTick = {
        Add = function(fn) tickHandler = fn end,
    },
}

local selectedContext
local spawnProvider
local spawnSpec
DTCommon = {
    MOD_ID = "DTCommon",
    TraderService = {
        Snapshot = function() return {} end,
        ExecuteTradeBasket = function() return {} end,
    },
    TraderProviders = {
        Select = function(capability, context)
            T.equal(capability, "spawnTrader",
                "shared debug selected wrong provider capability")
            selectedContext = context
            return {
                id = "DTAbstract",
            }
        end,
    },
    TraderWorld = {
        SpawnTrader = function(providerID, spec)
            spawnProvider = providerID
            spawnSpec = spec
            return {
                traderID = "trader:debug:1",
                actorID = "actor:debug:1",
                position = spec.position,
            }
        end,
    },
}

local allowed = true
PsychopatzCore = {
    Debug = {
        CanUse = function() return allowed end,
    },
}

isServer = function() return true end
getSpecificPlayer = function() return nil end

local sent = {}
sendServerCommand = function(player, module, command, args)
    sent[#sent + 1] = {
        player = player,
        module = module,
        command = command,
        args = args,
    }
end

local Server = T.load(
    "DTCommon",
    "server",
    "DTCommon/DTCommon_Server.lua"
)
T.truthy(Server, "DTCommon server loaded")
T.truthy(clientHandler, "DTCommon client handler missing")

local player = {}
clientHandler("DTCommon", "DebugSpawnTrader", player, {
    x = 123,
    y = 456,
    z = 1,
})

T.truthy(tickHandler, "shared debug spawn queue tick hook missing")
T.equal(selectedContext, nil,
    "provider selection ran synchronously inside client command")
T.equal(spawnProvider, nil,
    "trader spawn ran synchronously inside client command")
T.equal(sent[1].command, "TraderDebugSpawnResult",
    "shared debug queue acknowledgement command mismatch")
T.truthy(sent[1].args.accepted,
    "shared debug queue acknowledgement was not accepted")
T.truthy(sent[1].args.pending,
    "shared debug queue acknowledgement was not pending")
T.equal(sent[1].args.reason, "queued",
    "shared debug queue acknowledgement reason mismatch")

tickHandler()

T.truthy(selectedContext and selectedContext.debug,
    "queued spawn provider selection lost debug context")
T.equal(spawnProvider, "DTAbstract",
    "queued spawn did not dispatch to selected provider")
T.truthy(spawnSpec and spawnSpec.debug,
    "queued provider call lost debug flag")
T.equal(spawnSpec.position.x, 123,
    "queued provider call lost X")
T.equal(spawnSpec.position.y, 456,
    "queued provider call lost Y")
T.equal(sent[2].command, "TraderDebugSpawnResult",
    "shared debug final result command mismatch")
T.truthy(sent[2].args.accepted,
    "shared debug final spawn was not accepted")
T.falsy(sent[2].args.pending,
    "shared debug final result remained pending")
T.equal(sent[2].args.provider, "DTAbstract",
    "shared debug final result lost provider identity")

allowed = false
sent = {}
clientHandler("DTCommon", "DebugSpawnTrader", player, {
    x = 1,
    y = 2,
    z = 0,
})
T.equal(sent[1].command, "TraderDebugSpawnResult",
    "unauthorized debug request did not respond")
T.falsy(sent[1].args.accepted,
    "unauthorized debug request was accepted")
T.equal(sent[1].args.reason, "not_authorized",
    "unauthorized debug reason mismatch")

T.finish("dt_common_trader_debug_server_smoke")

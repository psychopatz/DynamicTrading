local T = require "tests/support/test"
T.addPackagePaths()

local clientHandler
Events = {
    OnClientCommand = {
        Add = function(fn) clientHandler = fn end,
    },
}

local selectedContext
local spawnProvider
local spawnSpec
DTCommon = {
    MOD_ID = "DTCommon",
    TraderService = {
        Snapshot = function() return {} end,
        ExecuteTrade = function() return {} end,
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

T.truthy(selectedContext and selectedContext.debug,
    "shared debug provider selection lost debug context")
T.equal(spawnProvider, "DTAbstract",
    "shared debug did not dispatch to selected provider")
T.truthy(spawnSpec and spawnSpec.debug,
    "shared debug provider call lost debug flag")
T.equal(spawnSpec.position.x, 123,
    "shared debug provider call lost X")
T.equal(spawnSpec.position.y, 456,
    "shared debug provider call lost Y")
T.equal(sent[1].command, "TraderDebugSpawnResult",
    "shared debug result command mismatch")
T.truthy(sent[1].args.accepted,
    "shared debug spawn result was not accepted")
T.equal(sent[1].args.provider, "DTAbstract",
    "shared debug result lost provider identity")

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

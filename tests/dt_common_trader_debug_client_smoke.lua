local T = require "tests/support/test"
T.addPackagePaths()

local contextHandlers = {}
local serverHandlers = {}
Events = {
    OnFillWorldObjectContextMenu = {
        Add = function(fn)
            contextHandlers[#contextHandlers + 1] = fn
        end,
    },
    OnServerCommand = {
        Add = function(fn)
            serverHandlers[#serverHandlers + 1] = fn
        end,
    },
}

local square = {
    getX = function() return 321 end,
    getY = function() return 654 end,
    getZ = function() return 0 end,
}
local object = {
    getSquare = function() return square end,
}
local player = {
    getSquare = function() return square end,
}
getSpecificPlayer = function() return player end

local commands = {}
sendClientCommand = function(current, module, command, args)
    commands[#commands + 1] = {
        player = current,
        module = module,
        command = command,
        args = args,
    }
end

local notices = {}
local hubTools = {}
PsychopatzCore = {
    Debug = {
        CanUse = function() return true end,
    },
    DebugHub = {
        RegisterTool = function(definition)
            hubTools[definition.id] = definition
            return true
        end,
    },
    Notifications = {
        Show = function(def)
            notices[#notices + 1] = def
            return true
        end,
    },
}

DTCommon = {
    MOD_ID = "DTCommon",
    T = function(_, fallback) return fallback end,
}

local Debug = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_TraderDebug.lua"
)
T.truthy(Debug, "shared trader debug module loaded")
T.equal(#contextHandlers, 1,
    "shared trader debug context hook missing")
T.truthy(hubTools["dtcommon.spawnTrader"],
    "shared trader debug hub spawn tool missing")
T.equal(hubTools["dtcommon.spawnTrader"].title,
    "Spawn Trader at Player",
    "shared trader debug hub title changed")

local options = {}
local context = {
    addOption = function(_, title, _, callback, ...)
        options[#options + 1] = {
            title = title,
            callback = callback,
            args = { ... },
        }
        return options[#options]
    end,
}
contextHandlers[1](0, context, { object }, false)
T.equal(#options, 1,
    "shared trader debug did not add one spawn option")
T.equal(options[1].title, "[Debug] Spawn Trader",
    "shared trader debug option title changed")

options[1].callback(
    nil,
    options[1].args[1],
    options[1].args[2]
)
T.equal(commands[1].player, player,
    "shared debug spawn lost local player")
T.equal(commands[1].module, "DTCommon",
    "shared debug spawn used adopter module")
T.equal(commands[1].command, "DebugSpawnTrader",
    "shared debug spawn command mismatch")
T.equal(commands[1].args.x, 321,
    "shared debug spawn X mismatch")
T.equal(commands[1].args.y, 654,
    "shared debug spawn Y mismatch")

commands = {}
hubTools["dtcommon.spawnTrader"].action()
T.equal(commands[1].command, "DebugSpawnTrader",
    "debug hub spawn did not use shared command")
T.equal(commands[1].args.x, 321,
    "debug hub spawn did not use player square X")
T.equal(commands[1].args.y, 654,
    "debug hub spawn did not use player square Y")

for _, callback in ipairs(serverHandlers) do
    callback("DTCommon", "TraderDebugSpawnResult", {
        accepted = true,
        provider = "DTAbstract",
        traderID = "trader:debug:1",
        actorID = "actor:debug:1",
        reason = "spawned",
    })
end
T.truthy(Debug.LastSpawnResult
    and Debug.LastSpawnResult.accepted == true,
    "shared debug result was not retained")
T.truthy(#notices == 1,
    "shared debug result did not use common notification surface")
T.contains(notices[1].message, "trader:debug:1",
    "shared debug notification lost trader identity")

T.finish("dt_common_trader_debug_client_smoke")

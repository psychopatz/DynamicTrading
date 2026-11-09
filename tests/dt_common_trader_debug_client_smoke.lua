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
local managerResults = {}
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
    ActorNotifications = {
        Show = function(def)
            notices[#notices + 1] = def
            return true
        end,
    },
}

DTCommon = {
    MOD_ID = "DTCommon",
    T = function(_, fallback) return fallback end,
    TraderManager = {
        SetResult = function(message, args)
            managerResults[#managerResults + 1] = {
                message = message,
                args = args,
            }
        end,
    },
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
        pending = true,
        requestID = "dt_debug_spawn:1",
        position = { x = 321, y = 654, z = 0 },
        reason = "queued",
    })
end
T.truthy(Debug.LastSpawnResult
    and Debug.LastSpawnResult.pending == true,
    "shared debug queued result was not retained")
T.equal(#notices, 0,
    "shared debug queued result opened an actor notification")
T.equal(#managerResults, 1,
    "shared debug queued result did not reach the manager")
T.contains(managerResults[1].message, "queued",
    "shared debug queued manager wording missing")
T.contains(managerResults[1].message, "321,654",
    "shared debug queued manager result lost position")

for _, callback in ipairs(serverHandlers) do
    callback("DTCommon", "TraderDebugSpawnResult", {
        accepted = true,
        pending = false,
        requestID = "dt_debug_spawn:1",
        provider = "DTAbstract",
        traderID = "trader:debug:1",
        actorID = "actor:debug:1",
        position = { x = 321, y = 654, z = 0 },
        reason = "spawned",
    })
end
T.truthy(Debug.LastSpawnResult
    and Debug.LastSpawnResult.accepted == true
    and Debug.LastSpawnResult.pending == false,
    "shared debug final result was not retained")
T.equal(#notices, 1,
    "shared debug final result did not use common notification surface")
T.equal(#managerResults, 2,
    "shared debug final result did not reach the manager")
T.contains(notices[1].message, "trader:debug:1",
    "shared debug final notification lost trader identity")
T.contains(notices[1].message, "no visible world body",
    "abstract debug notification did not explain bodyless spawn")

for _, callback in ipairs(serverHandlers) do
    callback("DTCommon", "TraderDebugSpawnResult", {
        accepted = true,
        pending = false,
        requestID = "dt_debug_spawn:2",
        provider = "DTHoomans",
        traderID = "trader:physical:1",
        actorID = "actor:physical:1",
        position = { x = 321, y = 654, z = 0 },
        reason = "spawned",
    })
end
T.equal(#notices, 1,
    "physical debug spawn opened an actor notification")
T.equal(#managerResults, 3,
    "physical debug result did not reach the manager")
T.contains(managerResults[3].message, "trader:physical:1",
    "physical debug manager result lost trader identity")

T.finish("dt_common_trader_debug_client_smoke")

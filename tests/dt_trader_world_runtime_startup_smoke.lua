local T = require "tests/support/test"
T.addPackagePaths()

local gameStart
local tickHandler
Events = {
    OnGameStart = {
        Add = function(fn) gameStart = fn end,
    },
    OnTick = {
        Add = function(fn) tickHandler = fn end,
    },
}

local now = 12
getGameTime = function()
    return {
        getWorldAgeHours = function() return now end,
    }
end

local calls = {}
DTCommon = {
    TraderWorld = {
        INTERVAL_HOURS = 1,
        Tick = function(force, at)
            calls[#calls + 1] = {
                force = force,
                now = at,
            }
            return {
                managed = force and 2 or 1,
                spawned = force and 2 or 0,
            }
        end,
    },
}

local published = 0
PsychopatzCore = {
    SurvivorWorldProjectionServer = {
        Publish = function()
            published = published + 1
            return 1
        end,
    },
}

local Runtime = T.load(
    "DTCommon",
    "server",
    "DTCommon/DTCommon_TraderWorldRuntime.lua"
)

T.truthy(gameStart, "trader-world startup hook was not registered")
T.truthy(tickHandler, "trader-world cadence hook was not registered")
T.equal(#calls, 0, "trader world ticked before game start")

gameStart()

T.equal(#calls, 1, "game start did not bootstrap trader world")
T.truthy(calls[1].force,
    "game start must use the forced bounded population fill")
T.equal(calls[1].now, 12,
    "game start bootstrap used wrong world age")
T.equal(Runtime.LastSummary.spawned, 2,
    "startup summary lost full bounded population fill")
T.equal(published, 1,
    "startup did not immediately publish Core actor projections")
T.truthy(Runtime.NextTickAt > now,
    "startup bootstrap did not schedule normal next cadence")

now = 12.25
tickHandler()
T.equal(#calls, 1,
    "normal cadence tick ran before next scheduled world tick")

now = 13.1
tickHandler()
T.equal(#calls, 2,
    "normal cadence did not resume after startup interval")
T.falsy(calls[2].force,
    "normal cadence incorrectly used forced population fill")

T.finish("dt_trader_world_runtime_startup_smoke")

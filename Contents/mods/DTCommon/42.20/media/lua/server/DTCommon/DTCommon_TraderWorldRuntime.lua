-- Single authoritative cadence for DynamicTrading roaming trader-world
-- decisions. Providers may maintain their own body/group mechanics, but do not
-- own a second commercial lifecycle tick.

DTCommon = DTCommon or {}

local World = DTCommon.TraderWorld
    or require "DTCommon/DTCommon_TraderWorld"

local Runtime = DTCommon.TraderWorldRuntime or {}
DTCommon.TraderWorldRuntime = Runtime

Runtime.NextTickAt = Runtime.NextTickAt or nil
Runtime.LastSummary = Runtime.LastSummary or nil

local function worldAge()
    local time = getGameTime and getGameTime() or nil
    if time and type(time.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(time:getWorldAgeHours()) or 0)
    end
    return 0
end

function Runtime.Tick(force, now)
    now = tonumber(now) or worldAge()
    if force ~= true and Runtime.NextTickAt
        and now < Runtime.NextTickAt
    then
        return Runtime.LastSummary or {
            managed = 0,
            spawned = 0,
            skipped = "not_due",
        }
    end
    Runtime.NextTickAt = now + math.max(
        0.1, tonumber(World.INTERVAL_HOURS) or 1)
    Runtime.LastSummary = World.Tick(force, now)
    return Runtime.LastSummary
end

local function onTick()
    Runtime.Tick(false, worldAge())
end

if Events and Events.OnGameStart
    and type(Events.OnGameStart.Add) == "function"
    and not Runtime.StartHookRegistered
then
    Runtime.StartHookRegistered = true
    Events.OnGameStart.Add(function()
        Runtime.NextTickAt = worldAge() + math.max(
            0.1, tonumber(World.INTERVAL_HOURS) or 1)
    end)
end

if Events and Events.OnTick
    and type(Events.OnTick.Add) == "function"
    and not Runtime.TickHookRegistered
then
    Runtime.TickHookRegistered = true
    Events.OnTick.Add(onTick)
end

return Runtime

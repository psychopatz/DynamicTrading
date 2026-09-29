if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then return end

-- Roaming trading caravan lifecycle.
--
-- DynamicTrading owns when a caravan exists; Project Hoomans owns everything
-- that happens to it: `PNC.MobileGroupDirector` generates the group and its
-- abstract relocation, departures and pathing all run through the population
-- director. This module therefore only keeps a bounded number of dynamic
-- trading caravans alive in the world and re-raises one when the previous one
-- is gone, so a region is never permanently without trade access.
--
-- The trader's second variant - idle at its faction base - is not implemented
-- yet; only the roaming variant exists today.

DTHoomans = DTHoomans or {}
DTHoomans.CaravanLifecycle = DTHoomans.CaravanLifecycle or {}

local Lifecycle = DTHoomans.CaravanLifecycle

-- How many dynamic trading caravans may roam at once. Bounded work and a
-- bounded world footprint: each caravan is one faction plus its members.
local MAX_ROAMING_CARAVANS = 2
-- In-game hours between attempts. A caravan that is still alive is never
-- replaced, and the check is one faction scan, so this stays cheap.
local INTERVAL_HOURS = 6
-- The caravan is placed a short walk from a player instead of on top of them:
-- it is a roaming group, and Project Hoomans relocates it afterwards.
local MIN_DISTANCE = 45
local MAX_DISTANCE = 90
-- Bounded creations per pass, in case several caravans are missing at once.
local MAX_CREATIONS_PER_PASS = 1

local nextAttemptAt
local lastSummary = { roaming = 0, spawned = 0, skipped = "not_run" }

local function log(level, message)
    print("[DT][" .. tostring(level) .. "] " .. tostring(message))
end

local function isAuthority()
    return DTCommon and DTCommon.Storage
        and type(DTCommon.Storage.IsAuthority) == "function"
        and DTCommon.Storage.IsAuthority() == true
end

local function worldAge()
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and type(gameTime.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(gameTime:getWorldAgeHours()) or 0)
    end
    return 0
end

-- A roaming caravan is a dynamic trading faction that Project Hoomans marked as
-- a mobile group. The faction registry stays the only source of truth, so a
-- caravan destroyed or absorbed by Project Hoomans is automatically counted as
-- gone and replaced by the next pass.
local function isRoamingCaravan(faction)
    local tags = type(faction) == "table" and faction.tags or nil
    if type(tags) ~= "table" then return false end
    if tags.dynamicTrading ~= true then return false end
    if tags.mobileGroup ~= true then return false end
    if faction.status ~= "active" then return false end
    local factions = PNC and PNC.Factions or nil
    if factions and type(factions.IsMobileGroup) == "function" then
        return factions.IsMobileGroup(faction) == true
    end
    return true
end

function Lifecycle.CountRoaming()
    local factions = PNC and PNC.Factions or nil
    local list
    local index
    local count = 0
    if not factions or type(factions.List) ~= "function" then return 0 end
    list = factions.List()
    for index = 1, #(type(list) == "table" and list or {}) do
        if isRoamingCaravan(list[index]) then count = count + 1 end
    end
    return count
end

local function clamp(value, minimum, maximum)
    return math.max(minimum, math.min(maximum, value))
end

-- Deterministic offset from a player position: a bounded ring around the
-- player, biased by the spawn sequence so consecutive caravans do not stack.
local function placementFor(player, sequence)
    local offset = MIN_DISTANCE
        + (sequence or 0) % math.max(1, MAX_DISTANCE - MIN_DISTANCE + 1)
    local angle = ((sequence or 0) * 2.399963) % (math.pi * 2)
    return math.floor(player:getX() + math.cos(angle) * offset),
        math.floor(player:getY() + math.sin(angle) * offset),
        math.floor(player:getZ() or 0)
end

local function firstPlayer()
    local players = getOnlinePlayers and getOnlinePlayers() or nil
    local count = players and players:size() or 0
    local index
    local player
    for index = 0, count - 1 do
        player = players:get(index)
        if player then return player end
    end
    player = getPlayer and getPlayer() or nil
    return player
end

local function spawnRoamingCaravan(sequence)
    local caravan = DTHoomans.Caravan
    local player = firstPlayer()
    local x
    local y
    local z
    if not caravan or type(caravan.Spawn) ~= "function" then
        return false, "caravan_service_unavailable"
    end
    if not player then return false, "no_player" end
    x, y, z = placementFor(player, sequence)
    -- `presenceMode = "auto"` lets Project Hoomans keep an offscreen caravan
    -- abstract (it relocates abstract groups itself), so the lifecycle never
    -- forces a live spawn just to keep trade available.
    local request = caravan.Spawn(x, y, z, nil, nil, {
        debug = false,
        presenceMode = "auto",
    })
    if not request or request.status ~= "spawned" then
        return false, request and request.reason or "caravan_spawn_failed"
    end
    return true, request.traderID or request.factionID
end

-- One bounded pass. Returns a summary that is safe to log and to assert on.
function Lifecycle.Tick(force)
    local summary = { roaming = 0, spawned = 0, skipped = nil }
    local sequence
    local ok
    local reason
    local index
    if not isAuthority() then
        summary.skipped = "not_authority"
        return summary
    end
    summary.roaming = Lifecycle.CountRoaming()
    if type(DTHoomans.Caravan) ~= "table"
        or type(DTHoomans.Caravan.Spawn) ~= "function"
    then
        summary.skipped = "caravan_service_unavailable"
        return summary
    end
    if summary.roaming >= MAX_ROAMING_CARAVANS then
        summary.skipped = "at_capacity"
        return summary
    end
    for index = 1, MAX_CREATIONS_PER_PASS do
        if summary.roaming + summary.spawned >= MAX_ROAMING_CARAVANS then break end
        sequence = (DTHoomans.CaravanRuntime
            and tonumber(DTHoomans.CaravanRuntime.roamingSpawnCount) or 0)
            + summary.spawned
        ok, reason = spawnRoamingCaravan(sequence)
        if ok then
            summary.spawned = summary.spawned + 1
            DTHoomans.CaravanRuntime = DTHoomans.CaravanRuntime or {}
            DTHoomans.CaravanRuntime.roamingSpawnCount = sequence + 1
            log("INFO", "caravan_roaming_spawned id=" .. tostring(reason)
                .. " roaming=" .. tostring(summary.roaming + summary.spawned))
        else
            summary.skipped = reason or "spawn_failed"
            log("WARN", "caravan_roaming_skipped reason="
                .. tostring(summary.skipped))
        end
    end
    return summary
end

local function onTick()
    local at = worldAge()
    if nextAttemptAt and at < nextAttemptAt then return end
    nextAttemptAt = at + clamp(INTERVAL_HOURS, 0.5, 168)
    lastSummary = Lifecycle.Tick()
end

function Lifecycle.LastSummary()
    return lastSummary
end

Lifecycle.MAX_ROAMING_CARAVANS = MAX_ROAMING_CARAVANS
Lifecycle.INTERVAL_HOURS = INTERVAL_HOURS

if Events and Events.OnGameStart
    and type(Events.OnGameStart.Add) == "function"
    and not Lifecycle.StartHookRegistered
then
    Lifecycle.StartHookRegistered = true
    Events.OnGameStart.Add(function()
        nextAttemptAt = worldAge() + INTERVAL_HOURS
    end)
end

if Events and Events.OnTick
    and type(Events.OnTick.Add) == "function"
    and not Lifecycle.TickHookRegistered
then
    Lifecycle.TickHookRegistered = true
    Events.OnTick.Add(onTick)
end

return Lifecycle

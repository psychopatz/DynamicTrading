-- Bounded production orchestration between abstract and Hoomans providers.
-- Provider/body implementation stays in DTHoomans.ProviderRuntime.

DTAbstract = DTAbstract or {}
DTAbstract.Handoff = DTAbstract.Handoff or {}

local Handoff = DTAbstract.Handoff

Handoff.MATERIALIZE_RADIUS = 60
Handoff.DEMATERIALIZE_RADIUS = 90
Handoff.CHECK_INTERVAL_MS = 2000

local lastCheckAt = 0

local function nowMs()
    if getTimestampMs then
        local ok, value = pcall(getTimestampMs)
        if ok and tonumber(value) then return tonumber(value) end
    end
    if getTimeInMillis then
        local ok, value = pcall(getTimeInMillis)
        if ok and tonumber(value) then return tonumber(value) end
    end
    return 0
end

local function worldAge()
    local time = getGameTime and getGameTime() or nil
    if time and type(time.getWorldAgeHours) == "function" then
        return math.max(0, tonumber(time:getWorldAgeHours()) or 0)
    end
    return 0
end

local function eachPlayer(callback)
    if isServer and isServer() and getOnlinePlayers then
        local players = getOnlinePlayers()
        if players and type(players.size) == "function"
            and type(players.get) == "function"
        then
            for index = 0, players:size() - 1 do
                callback(players:get(index))
            end
            return
        elseif type(players) == "table" then
            for _, player in ipairs(players) do callback(player) end
            return
        end
    end
    local current = getSpecificPlayer and getSpecificPlayer(0)
        or (getPlayer and getPlayer() or nil)
    if current then callback(current) end
end

local function nearestDistance(position)
    if not position then return math.huge end
    local nearest = math.huge
    eachPlayer(function(player)
        local px = player and player.getX and tonumber(player:getX()) or nil
        local py = player and player.getY and tonumber(player:getY()) or nil
        if px and py then
            local dx = px - position.x
            local dy = py - position.y
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance < nearest then nearest = distance end
        end
    end)
    return nearest
end

local function runtime()
    return DTHoomans and DTHoomans.ProviderRuntime or nil
end

function Handoff.Tick(now)
    local physical = runtime()
    if not physical or not DTCommon or not DTCommon.TraderService then
        return { checked = 0, materialized = 0, dematerialized = 0,
            skipped = "physical_provider_unavailable" }
    end

    now = tonumber(now) or worldAge()
    local summary = {
        checked = 0,
        materialized = 0,
        dematerialized = 0,
    }

    DTCommon.TraderService.ForEach(function(traderID, record)
        local ca = record and record.ca or nil
        if not ca then return end

        local provider = ca.provider or ca.coreProvider
        local state = ca.providerState or ca.coreProviderState
        if provider ~= "DTAbstract" and provider ~= "DTHoomans" then
            return
        end

        if provider == "DTHoomans" and state == "materialized"
            and physical.RecoverMissingBody
        then
            local recovered, recoveryReason =
                physical.RecoverMissingBody(traderID, { now = now })
            if recovered and recoveryReason == "recovered_missing_body" then
                provider = "DTAbstract"
                state = "abstract"
                summary.recovered = (summary.recovered or 0) + 1
            end
        end

        local position = physical.GetPosition
            and physical.GetPosition(traderID, now) or nil
        local distance = nearestDistance(position)
        summary.checked = summary.checked + 1

        if provider == "DTAbstract"
            and (state == nil or state == "abstract")
            and distance <= Handoff.MATERIALIZE_RADIUS
        then
            local actor = physical.MaterializeTrader(traderID, {
                now = now,
                reason = "dt_nearby_materialize",
            })
            if actor then
                summary.materialized = summary.materialized + 1
            end
        elseif provider == "DTHoomans"
            and state == "materialized"
            and distance > Handoff.DEMATERIALIZE_RADIUS
        then
            local actor = physical.DematerializeTrader(traderID, {
                now = now,
                reason = "dt_out_of_range_dematerialize",
            })
            if actor then
                summary.dematerialized = summary.dematerialized + 1
            end
        end
    end)

    if (summary.materialized > 0 or summary.dematerialized > 0)
        and DTAbstract.ProjectionServer
        and DTAbstract.ProjectionServer.Publish
    then
        DTAbstract.ProjectionServer.Publish()
    end
    return summary
end

local function onTick()
    local at = nowMs()
    if at > 0 and at - lastCheckAt < Handoff.CHECK_INTERVAL_MS then return end
    lastCheckAt = at
    Handoff.Tick(worldAge())
end

if Events and Events.OnTick and Events.OnTick.Add
    and not Handoff.TickHookRegistered
then
    Handoff.TickHookRegistered = true
    Events.OnTick.Add(onTick)
end

return Handoff

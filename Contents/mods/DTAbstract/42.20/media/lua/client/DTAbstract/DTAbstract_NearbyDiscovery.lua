-- Client-side nearby trader discovery and notification for DTAbstract.
--
-- Discovers abstract traders when they pass near the local player using the
-- canonical projected world position. Emits exactly-once notification through
-- the PsychopatzCore notification UI with exit hysteresis and cooldown.

DTAbstract = DTAbstract or {}
DTAbstract.NearbyDiscovery = DTAbstract.NearbyDiscovery or {}

local Discovery = DTAbstract.NearbyDiscovery

Discovery.DETECTION_RADIUS = 60
Discovery.EXIT_RADIUS = 75
Discovery.COOLDOWN_SECONDS = 300
Discovery.CHECK_INTERVAL_SECONDS = 2

local traderStates = {}
local lastCheckTime = 0

local Presentation = DTCommon.TraderPresentation
    or require "DTCommon/DTCommon_TraderPresentation"

local function notifyTraderNearby(traderID, record, actorID)
    local title = "Trading Caravan Nearby"
    local name = record and record.n or traderID
    local message = tostring(name) .. " is operating nearby."

    if PsychopatzCore and PsychopatzCore.Notifications
        and type(PsychopatzCore.Notifications.Show) == "function"
    then
        PsychopatzCore.Notifications.Show({
            id = "dt_nearby:" .. tostring(traderID),
            title = title,
            message = message,
            text = message,
        })
    end
end

function Discovery.GetTraderState(traderID)
    traderID = tostring(traderID or "")
    if not traderStates[traderID] then
        traderStates[traderID] = {
            discovered = false,
            inside = false,
            lastNotifiedAt = 0,
            lastExitedAt = 0,
        }
    end
    return traderStates[traderID]
end

function Discovery.IsTraderDiscovered(traderID)
    local state = traderStates[tostring(traderID or "")]
    return state and state.discovered == true or false
end

function Discovery.ResetDiscovery(traderID)
    if traderID then
        traderStates[tostring(traderID)] = nil
    else
        traderStates = {}
    end
end

function Discovery.MarkDiscovered(traderID)
    traderID = tostring(traderID or "")
    if traderID == "" then return false end
    local state = Discovery.GetTraderState(traderID)
    state.discovered = true
    return true
end

function Discovery.CheckNearbyTraders(player, now)
    player = player or (getSpecificPlayer and getSpecificPlayer(0) or (getPlayer and getPlayer() or nil))
    if not player or not DTCommon or not DTCommon.TraderService then return 0 end

    local px = player.getX and tonumber(player:getX()) or nil
    local py = player.getY and tonumber(player:getY()) or nil
    if not px or not py then return 0 end

    now = tonumber(now) or (getTimeInMillis and getTimeInMillis() / 1000 or 0)
    local detectedCount = 0
    local gameTime = getGameTime and getGameTime() or nil
    local journeyNow = gameTime
        and type(gameTime.getWorldAgeHours) == "function"
        and tonumber(gameTime:getWorldAgeHours()) or nil

    for _, row in ipairs(Presentation.ListTraderRecords(false, now)) do
        local traderID = row.traderID
        local record = row.record
        local ca = record and record.ca or nil
        if ca and row.provider == "DTAbstract" then
            local actorID = ca.actorID or ca.coreActorID
            local pos = Presentation.GetPosition(record, journeyNow)

            if pos and pos.x and pos.y then
                local dx = px - pos.x
                local dy = py - pos.y
                local dist = math.sqrt(dx * dx + dy * dy)
                local state = Discovery.GetTraderState(traderID)

                if dist <= Discovery.DETECTION_RADIUS then
                    if not state.inside then
                        local elapsedSinceNotification = now - (state.lastNotifiedAt or 0)
                        local cooldownPassed = (state.lastNotifiedAt == 0)
                            or (elapsedSinceNotification >= Discovery.COOLDOWN_SECONDS)

                        state.inside = true
                        state.discovered = true

                        if cooldownPassed then
                            state.lastNotifiedAt = now
                            notifyTraderNearby(traderID, record, actorID)
                            detectedCount = detectedCount + 1
                        end
                    end
                elseif dist > Discovery.EXIT_RADIUS then
                    if state.inside then
                        state.inside = false
                        state.lastExitedAt = now
                    end
                end
            end
        end
    end

    return detectedCount
end

local function onTick()
    local now = getTimeInMillis and (getTimeInMillis() / 1000) or 0
    if now > 0 and (now - lastCheckTime) < Discovery.CHECK_INTERVAL_SECONDS then
        return
    end
    lastCheckTime = now
    Discovery.CheckNearbyTraders(nil, now)
end

if Events and Events.OnTick
    and type(Events.OnTick.Add) == "function"
    and not Discovery.TickHookRegistered
then
    Discovery.TickHookRegistered = true
    Events.OnTick.Add(onTick)
end

return Discovery

-- Nearby notification/hysteresis for canonical SurvivorWorld trader actors.
--
-- Discovery truth is owned by PsychopatzCore SurvivorWorld. This module keeps
-- only ephemeral notification state (inside/cooldown) and advances Core
-- discovery when a trader's canonical group/community is encountered.

DTAbstract = DTAbstract or {}
DTAbstract.NearbyDiscovery = DTAbstract.NearbyDiscovery or {}

local Discovery = DTAbstract.NearbyDiscovery

if not (PsychopatzCore and PsychopatzCore.Notifications) then
    pcall(require, "PsychopatzCore/UI/PsychopatzNotificationWindow")
end

local CoreClient = require
    "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
local Presentation = DTCommon.TraderPresentation
    or require "DTCommon/DTCommon_TraderPresentation"

Discovery.DETECTION_RADIUS = 60
Discovery.EXIT_RADIUS = 75
Discovery.COOLDOWN_SECONDS = 300
Discovery.CHECK_INTERVAL_SECONDS = 2
Discovery.CONTACT_PHASE = 3

local traderStates = {}
local lastCheckTime = 0

local function notifyTraderNearby(traderID, record)
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

local function traderRecord(traderID)
    return DTCommon
        and DTCommon.TraderService
        and DTCommon.TraderService.GetRecord
        and DTCommon.TraderService.GetRecord(
            tostring(traderID or "")
        )
        or nil
end

local function actorForRecord(record)
    local ca = record and record.ca or nil
    local actorID = ca and (ca.actorID) or nil
    if not actorID or not CoreClient then return nil, actorID end
    return CoreClient.GetActor(actorID), actorID
end

local function discoveryTarget(record)
    local actor = actorForRecord(record)
    if not actor then return nil end
    if actor.groupID then
        return "group", tostring(actor.groupID)
    end
    if actor.communityID then
        return "community", tostring(actor.communityID)
    end
    return nil
end

function Discovery.GetTraderState(traderID)
    traderID = tostring(traderID or "")
    if not traderStates[traderID] then
        traderStates[traderID] = {
            inside = false,
            lastNotifiedAt = 0,
            lastExitedAt = 0,
        }
    end
    return traderStates[traderID]
end

function Discovery.IsTraderDiscovered(traderID)
    local record = traderRecord(traderID)
    local kind, entityID = discoveryTarget(record)
    if not kind then return false end
    local entity = CoreClient.FindDiscovery(kind, entityID)
    return entity ~= nil
        and (tonumber(entity.phase) or 0)
            >= Discovery.CONTACT_PHASE
end

function Discovery.ResetDiscovery(traderID)
    if traderID ~= nil then
        local record = traderRecord(traderID)
        local kind, entityID = discoveryTarget(record)
        if not kind then return false, "discovery_target_unavailable" end
        return CoreClient.DiscoveryAction(
            "debug_reset_entity",
            {
                kind = kind,
                entityID = entityID,
            }
        )
    end
    traderStates = {}
    return CoreClient.DiscoveryAction("debug_reset", {})
end

function Discovery.MarkDiscovered(traderID)
    local record = traderRecord(traderID)
    local kind, entityID = discoveryTarget(record)
    if not kind then return false, "discovery_target_unavailable" end
    return CoreClient.DiscoveryAction(
        "mark_contacted",
        {
            kind = kind,
            entityID = entityID,
            source = "dtabstract_nearby",
        }
    )
end

function Discovery.CheckNearbyTraders(player, now)
    player = player
        or (getSpecificPlayer and getSpecificPlayer(0)
            or (getPlayer and getPlayer() or nil))
    if not player or not DTCommon or not DTCommon.TraderService then
        return 0
    end

    local px = player.getX and tonumber(player:getX()) or nil
    local py = player.getY and tonumber(player:getY()) or nil
    if not px or not py then return 0 end

    now = tonumber(now)
        or (getTimeInMillis and getTimeInMillis() / 1000 or 0)
    local detectedCount = 0

    if CoreClient and CoreClient.RequestActorsIfDue then
        CoreClient.RequestActorsIfDue(1000)
    end

    for _, row in ipairs(
        Presentation.ListTraderRecords(false, now)
    ) do
        local traderID = row.traderID
        local record = row.record
        local ca = record and record.ca or nil
        local abstractLineage = ca
            and (row.provider == "DTAbstract"
                or tostring(ca.returnProviderID or "")
                    == "DTAbstract")
        if abstractLineage then
            local actor, actorID = actorForRecord(record)
            local pos = actor and actor.position or nil
            if pos and tonumber(pos.x) and tonumber(pos.y) then
                local dx = px - tonumber(pos.x)
                local dy = py - tonumber(pos.y)
                local dist = math.sqrt(dx * dx + dy * dy)
                local state = Discovery.GetTraderState(traderID)

                if dist <= Discovery.DETECTION_RADIUS then
                    if not state.inside then
                        local elapsed = now
                            - (state.lastNotifiedAt or 0)
                        local cooldownPassed =
                            state.lastNotifiedAt == 0
                            or elapsed
                                >= Discovery.COOLDOWN_SECONDS

                        state.inside = true
                        Discovery.MarkDiscovered(traderID)

                        if cooldownPassed then
                            state.lastNotifiedAt = now
                            notifyTraderNearby(
                                traderID,
                                record,
                                actorID
                            )
                            detectedCount = detectedCount + 1
                        end
                    end
                elseif dist > Discovery.EXIT_RADIUS
                    and state.inside
                then
                    state.inside = false
                    state.lastExitedAt = now
                end
            end
        end
    end

    return detectedCount
end

local function onTick()
    local now = getTimeInMillis
        and (getTimeInMillis() / 1000) or 0
    if now > 0
        and (now - lastCheckTime)
            < Discovery.CHECK_INTERVAL_SECONDS
    then
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

-- ==============================================================================
-- Behavior_Departure_Shared.lua
-- Shared helpers and runtime cleanup for NPC departure behavior.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}
DTNPCLogic.Internal.Departure = DTNPCLogic.Internal.Departure or {}

local internal = DTNPCLogic.Internal.Departure

internal.DESPAWN_DIST = 45
internal.TARGET_REACHED_DIST = 2
internal.STUCK_TICKS = 15
internal.STUCK_ABORT_TICKS = 60
internal.RECOVERY_STEP_DIST = 5

function internal.isWeakenedDeparture(npcData)
    return tostring(npcData and npcData.healthState or "") == "Weakened"
        and tostring(npcData and npcData.state or "") == "Departure"
end

function internal.getDepartureLocomotionProfileKey(npcData)
    if internal.isWeakenedDeparture(npcData) then
        return DTNPCHealth and DTNPCHealth.WEAKENED_CROUCH_PROFILE_KEY or "weakened_crouch"
    end

    return "default"
end

function internal.isColonyRecruitmentDeparture(npcData)
    if not npcData then
        return false
    end

    if npcData.colonyRecruitmentPending == true or npcData.colonyRecruitmentRemoveSource == true then
        return true
    end

    local returnStatus = npcData.returnStatus or npcData.requestedReturnStatus
    if DTNPCManager and DTNPCManager.IsColonyRecruitmentReturnStatus then
        return DTNPCManager.IsColonyRecruitmentReturnStatus(returnStatus)
    end

    return tostring(returnStatus or "") == "ColonyRecruitment"
end

function internal.logDepartureTrace(npcData, suffix, message, force)
    local uuid = npcData and npcData.uuid or "unknown"
    DynamicTrading.Log("DTV2", "NPC", "Departure", message)

    if not isClient()
        and DTNPCManager
        and DTNPCManager.RespawnDebug
        and DTNPCManager.RespawnDebug.Log then
        DTNPCManager.RespawnDebug.Log(
            "departure_trace_" .. tostring(suffix or "event") .. "_" .. tostring(uuid),
            message,
            force == true
        )
    end
end

function internal.getDist(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

function internal.isTileSafe(x, y, z)
    local cell = getCell()
    local sq = cell and cell:getGridSquare(x, y, z) or nil
    if not sq then
        return true
    end
    if not sq:isFree(false) then
        return false
    end
    if sq:isSolid() or sq:isSolidTrans() then
        return false
    end
    return true
end

function internal.forceRunAnimation(zombie)
    zombie:setVariable("bMoving", true)
    zombie:setVariable("isMoving", true)
    zombie:setVariable("Speed", 1.2)
    zombie:setVariable("DTWalkType", "Run")
    zombie:setVariable("WalkType", "1")
    zombie:setRunning(true)
end

function internal.stopDepartureAnimation(zombie, npcData)
    if zombie and internal.isWeakenedDeparture(npcData) and DTNPCMobility and DTNPCMobility.SetLocomotionState then
        DTNPCMobility.SetLocomotionState(zombie, {
            profileKey = internal.getDepartureLocomotionProfileKey(npcData),
            moving = false,
        })
        return
    end

    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setVariable("DTWalkType", "")
    zombie:setVariable("WalkType", "")
    zombie:setRunning(false)
end

function internal.clearDepartureRuntime(npcData)
    npcData.removalRequested = nil
    npcData.isMovingState = nil
    npcData.departureTargetX = nil
    npcData.departureTargetY = nil
    npcData.departureTargetZ = nil
    npcData.departureTravelHours = nil
    npcData.departureBlockedTicks = nil
    npcData.departureStuckLastX = nil
    npcData.departureStuckLastY = nil
    npcData.departureLastDirX = nil
    npcData.departureLastDirY = nil
    npcData.departureStartedAt = nil
    npcData.departureForceDespawnAt = nil
    npcData.departureMode = nil
    npcData.departureTimeoutVisibleLogged = nil
    npcData.departureRecruitModeLogged = nil
    npcData.departureRecruitObserverLostLogged = nil
    npcData.departureRecruitFallbackLogged = nil
    npcData.departureRecruitNoDirectionLogged = nil
    if DTNPCBehaviorAntiStuck and DTNPCBehaviorAntiStuck.Reset then
        DTNPCBehaviorAntiStuck.Reset(npcData, "Departure")
    end
end

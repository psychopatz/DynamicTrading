-- ==============================================================================
-- Behavior_ColonyIdle.lua
-- Calm home-base loitering for colony residents while the base is clear.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "DT/V2/NPC/Sys/Colony/DTNPC_ColonyRuntime"

local MOVE_SPEED = 0.024
local STOP_DISTANCE = 0.45
local ANCHOR_PULL_DISTANCE = 5.5
local LOITER_RADIUS = 3
local MOVE_CHANCE_PERCENT = 45
local PAUSE_MIN_MS = 3500
local PAUSE_MAX_MS = 9000
local MOVE_GAP_MIN_MS = 4500
local MOVE_GAP_MAX_MS = 12000

local function nowMs()
    if getTimeInMillis then
        return getTimeInMillis()
    end
    return math.floor((getGameTime():getWorldAgeHours() or 0) * 3600000)
end

local function randomRange(minValue, maxValue)
    local minNumber = math.floor(tonumber(minValue) or 0)
    local maxNumber = math.floor(tonumber(maxValue) or minNumber)
    if maxNumber <= minNumber then
        return minNumber
    end
    return minNumber + ZombRand((maxNumber - minNumber) + 1)
end

local function buildPoint(source)
    if type(source) ~= "table" then
        return nil
    end

    local x = tonumber(source.x)
    local y = tonumber(source.y)
    if x == nil or y == nil then
        return nil
    end

    return {
        x = math.floor(x),
        y = math.floor(y),
        z = math.floor(tonumber(source.z) or 0),
    }
end

local function createPointTarget(point)
    if type(point) ~= "table" then
        return nil
    end

    return {
        getX = function() return point.x end,
        getY = function() return point.y end,
        getZ = function() return point.z or 0 end,
    }
end

local function syncStateChange(zombie, npcData)
    if not zombie or not npcData or not DTNPCServerCore or not DTNPCServerCore.SyncToAllClients then
        return
    end

    local ownedZombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(npcData.uuid) or nil
    if ownedZombie ~= zombie then
        return
    end

    DTNPCServerCore.SyncToAllClients(zombie, npcData)
    if DTNPCServerCore.BroadcastPosition then
        DTNPCServerCore.BroadcastPosition(zombie, npcData)
    end
end

local function stopMovement(zombie)
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
        return
    end

    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setRunning(false)
end

local function moveToPoint(zombie, npcData, point)
    local target = createPointTarget(point)
    if not target then
        stopMovement(zombie)
        return false, "invalid"
    end

    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    local moved, moveState = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
        target = target,
        speed = MOVE_SPEED,
        navigationMode = "planned",
        plannerProfile = "colony",
        staminaMode = "colony_idle",
        desiredRun = false,
        stopDistance = STOP_DISTANCE,
        allowObstacleInteract = true,
        allowDamageRetreat = true,
        blockCounterKey = "dcIdleBlockedTicks",
        stuckTicks = 16,
        faceX = point.x,
        faceY = point.y,
        anim = {
            animSpeed = 0.88,
            isRunning = false,
            dtWalkType = "Walk",
        },
    })

    if moved or moveState == "arrived" or moveState == "close_enough" or moveState == "damage_retreat" then
        npcData.dcIdleBlockedTicks = 0
        return true, moveState
    end

    if moveState and string.find(tostring(moveState), "interacted_", 1, true) then
        npcData.dcIdleBlockedTicks = 0
        return true, moveState
    end

    stopMovement(zombie)
    return false, moveState
end

local function shouldAlertFromLocalThreat(zombie, npcData, anchorPoint)
    if not DTNPCProtect or not DTNPCProtect.SelectNearestThreat then
        return false
    end
    if not DTNPCColonyRuntime.ShouldSenseThreat(npcData, 1400) then
        return false
    end

    local targetPoint = anchorPoint or { x = zombie:getX(), y = zombie:getY(), z = zombie:getZ() }
    local anchorTarget = createPointTarget(targetPoint)
    local target = DTNPCProtect.SelectNearestThreat(zombie, npcData, 10, anchorTarget, 10, true)
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    if not target then
        return false
    end

    DTNPCColonyRuntime.RaiseAlert(npcData, {
        source = "ColonyIdle",
        reason = "local_threat",
        target = target,
    })
    DTNPCColonyRuntime.PushAlertNotice(zombie, npcData, "civilian", target)
    return true
end

local function chooseLoiterPoint(anchorPoint)
    local anchor = buildPoint(anchorPoint)
    if not anchor then
        return nil
    end

    for _ = 1, 8 do
        local offsetX = ZombRand((LOITER_RADIUS * 2) + 1) - LOITER_RADIUS
        local offsetY = ZombRand((LOITER_RADIUS * 2) + 1) - LOITER_RADIUS
        if offsetX ~= 0 or offsetY ~= 0 then
            local point = {
                x = anchor.x + offsetX,
                y = anchor.y + offsetY,
                z = anchor.z,
            }
            if not DTNPCMobility or not DTNPCMobility.IsTileSafe or DTNPCMobility.IsTileSafe(point.x, point.y, point.z) then
                return point
            end
        end
    end

    return anchor
end

DTNPCLogic.Behaviors["ColonyIdle"] = function(zombie, npcData)
    if not zombie or not npcData then
        return
    end

    if not DTNPCColonyRuntime.IsLinkedResident(npcData) then
        if DTNPCLogic.Behaviors["PlayerZone"] then
            DTNPCLogic.Behaviors["PlayerZone"](zombie, npcData)
        end
        return
    end

    local desiredState = DTNPCColonyRuntime.SyncBehaviorIdentity(npcData)
    if desiredState ~= "ColonyIdle" then
        npcData.state = desiredState
        syncStateChange(zombie, npcData)
        return
    end

    local anchorPoint = DTNPCColonyRuntime.GetHomePoint(npcData)
        or DTNPCColonyRuntime.GetSafePoint(npcData, DTNPCColonyRuntime.GetWorker(npcData))
    local alert = DTNPCColonyRuntime.GetAlert(npcData)
    if alert or shouldAlertFromLocalThreat(zombie, npcData, anchorPoint) then
        npcData.dcIdleTarget = nil
        npcData.state = "ColonyCower"
        syncStateChange(zombie, npcData)
        return
    end

    if not anchorPoint then
        stopMovement(zombie)
        return
    end

    local targetPoint = buildPoint(npcData.dcIdleTarget)
    if targetPoint then
        local dxTarget = zombie:getX() - targetPoint.x
        local dyTarget = zombie:getY() - targetPoint.y
        if (dxTarget * dxTarget) + (dyTarget * dyTarget) <= (STOP_DISTANCE * STOP_DISTANCE) then
            npcData.dcIdleTarget = nil
            npcData.dcIdlePauseUntilMs = nowMs() + randomRange(PAUSE_MIN_MS, PAUSE_MAX_MS)
            stopMovement(zombie)
            zombie:faceLocation(anchorPoint.x, anchorPoint.y)
            return
        end

        local moved = moveToPoint(zombie, npcData, targetPoint)
        if not moved then
            npcData.dcIdleTarget = nil
            npcData.dcIdlePauseUntilMs = nowMs() + randomRange(PAUSE_MIN_MS, PAUSE_MAX_MS)
        end
        return
    end

    local dxAnchor = zombie:getX() - anchorPoint.x
    local dyAnchor = zombie:getY() - anchorPoint.y
    if (dxAnchor * dxAnchor) + (dyAnchor * dyAnchor) > (ANCHOR_PULL_DISTANCE * ANCHOR_PULL_DISTANCE) then
        moveToPoint(zombie, npcData, anchorPoint)
        return
    end

    local now = nowMs()
    if now < math.max(tonumber(npcData.dcIdlePauseUntilMs) or 0, tonumber(npcData.dcIdleNextMoveAtMs) or 0) then
        stopMovement(zombie)
        return
    end

    npcData.dcIdleNextMoveAtMs = now + randomRange(MOVE_GAP_MIN_MS, MOVE_GAP_MAX_MS)
    if ZombRand(100) >= MOVE_CHANCE_PERCENT then
        npcData.dcIdlePauseUntilMs = now + randomRange(PAUSE_MIN_MS, PAUSE_MAX_MS)
        stopMovement(zombie)
        return
    end

    targetPoint = chooseLoiterPoint(anchorPoint)
    if not targetPoint then
        npcData.dcIdlePauseUntilMs = now + randomRange(PAUSE_MIN_MS, PAUSE_MAX_MS)
        stopMovement(zombie)
        return
    end

    npcData.dcIdleTarget = targetPoint
    moveToPoint(zombie, npcData, targetPoint)
end

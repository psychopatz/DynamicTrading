-- ==============================================================================
-- Behavior_ColonyWork.lua
-- Resident worker movement toward their designated home-base work anchor.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "DT/V2/NPC/Sys/Colony/DTNPC_ColonyRuntime"

local MOVE_SPEED = 0.038
local STOP_DISTANCE = 0.45

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
        staminaMode = "colony_work",
        desiredRun = false,
        stopDistance = STOP_DISTANCE,
        allowObstacleInteract = true,
        allowDamageRetreat = true,
        blockCounterKey = "dcWorkBlockedTicks",
        stuckTicks = 15,
        faceX = point.x,
        faceY = point.y,
        anim = {
            animSpeed = 1.0,
            isRunning = false,
            dtWalkType = "Walk",
        },
    })

    if moved or moveState == "arrived" or moveState == "close_enough" or moveState == "damage_retreat" then
        npcData.dcWorkBlockedTicks = 0
        return true, moveState
    end

    if moveState and string.find(tostring(moveState), "interacted_", 1, true) then
        npcData.dcWorkBlockedTicks = 0
        return true, moveState
    end

    stopMovement(zombie)
    return false, moveState
end

local function shouldAlertFromLocalThreat(zombie, npcData, targetPoint)
    if not DTNPCProtect or not DTNPCProtect.SelectNearestThreat then
        return false
    end
    if not DTNPCColonyRuntime.ShouldSenseThreat(npcData, 1000) then
        return false
    end

    local anchorTarget = createPointTarget(targetPoint or { x = zombie:getX(), y = zombie:getY(), z = zombie:getZ() })
    local target = DTNPCProtect.SelectNearestThreat(zombie, npcData, 10, anchorTarget, 10, true)
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    if not target then
        return false
    end

    DTNPCColonyRuntime.RaiseAlert(npcData, {
        source = "ColonyWork",
        reason = "local_threat",
        target = target,
    })
    DTNPCColonyRuntime.PushAlertNotice(zombie, npcData, "civilian", target)
    return true
end

DTNPCLogic.Behaviors["ColonyWork"] = function(zombie, npcData)
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
    if desiredState ~= "ColonyWork" then
        npcData.state = desiredState
        syncStateChange(zombie, npcData)
        return
    end

    local targetPoint = DTNPCColonyRuntime.GetWorkPoint(npcData) or DTNPCColonyRuntime.GetSafePoint(npcData, DTNPCColonyRuntime.GetWorker(npcData))
    local alert = DTNPCColonyRuntime.GetAlert(npcData)
    if alert or shouldAlertFromLocalThreat(zombie, npcData, targetPoint) then
        npcData.state = "ColonyCower"
        syncStateChange(zombie, npcData)
        return
    end

    if not targetPoint then
        stopMovement(zombie)
        return
    end

    local dx = zombie:getX() - targetPoint.x
    local dy = zombie:getY() - targetPoint.y
    local distSq = (dx * dx) + (dy * dy)
    if distSq <= (STOP_DISTANCE * STOP_DISTANCE) then
        stopMovement(zombie)
        zombie:faceLocation(targetPoint.x, targetPoint.y)
        return
    end

    moveToPoint(zombie, npcData, targetPoint)
end

-- ==============================================================================
-- Behavior_ColonyCower.lua
-- Civilian colony behavior: alert nearby guards, move to safety, and hold.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "DT/V2/NPC/Sys/Colony/DTNPC_ColonyRuntime"

local MOVE_SPEED = 0.035
local STOP_DISTANCE = 0.4

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
        staminaMode = "colony_cower",
        desiredRun = false,
        stopDistance = STOP_DISTANCE,
        allowObstacleInteract = true,
        allowDamageRetreat = true,
        blockCounterKey = "dcCowerBlockedTicks",
        stuckTicks = 15,
        faceX = point.x,
        faceY = point.y,
        anim = {
            animSpeed = 0.95,
            isRunning = false,
            dtWalkType = "Walk",
        },
    })

    if moved or moveState == "arrived" or moveState == "close_enough" or moveState == "damage_retreat" then
        npcData.dcCowerBlockedTicks = 0
        return true, moveState
    end

    if moveState and string.find(tostring(moveState), "interacted_", 1, true) then
        npcData.dcCowerBlockedTicks = 0
        return true, moveState
    end

    stopMovement(zombie)
    return false, moveState
end

local function findLocalThreat(zombie, npcData)
    if not DTNPCProtect or not DTNPCProtect.SelectNearestThreat then
        return nil
    end
    if not DTNPCColonyRuntime.ShouldSenseThreat(npcData, 1200) then
        return nil
    end

    local target = DTNPCProtect.SelectNearestThreat(zombie, npcData, 9, zombie, 9, true)
    npcData.combatTargetID = nil
    npcData.combatTargetType = nil
    return target
end

DTNPCLogic.Behaviors["ColonyCower"] = function(zombie, npcData)
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
    local alert = DTNPCColonyRuntime.GetAlert(npcData)
    local threat = nil
    if not alert then
        threat = findLocalThreat(zombie, npcData)
        if threat then
            alert = DTNPCColonyRuntime.RaiseAlert(npcData, {
                source = "ColonyCower",
                reason = "local_threat",
                target = threat,
            })
            DTNPCColonyRuntime.PushAlertNotice(zombie, npcData, "civilian", threat)
        end
    end

    if not alert and desiredState ~= "ColonyCower" then
        npcData.state = desiredState
        syncStateChange(zombie, npcData)
        return
    end

    local safePoint = DTNPCColonyRuntime.GetSafePoint(npcData, DTNPCColonyRuntime.GetWorker(npcData))
    if not safePoint then
        if DTNPCLogic.Behaviors["PlayerZone"] then
            DTNPCLogic.Behaviors["PlayerZone"](zombie, npcData)
        end
        return
    end

    local dx = zombie:getX() - safePoint.x
    local dy = zombie:getY() - safePoint.y
    local distSq = (dx * dx) + (dy * dy)
    if distSq <= (STOP_DISTANCE * STOP_DISTANCE) then
        stopMovement(zombie)
        if alert and alert.x ~= nil and alert.y ~= nil then
            zombie:faceLocation(alert.x, alert.y)
        elseif DTNPCLogic.Stationary and DTNPCLogic.Stationary.AcquireNearbyPlayerTarget then
            local player = DTNPCLogic.Stationary.AcquireNearbyPlayerTarget(zombie, npcData)
            if player then
                zombie:faceLocation(player:getX(), player:getY())
            end
        end
        return
    end

    moveToPoint(zombie, npcData, safePoint)
end

-- ==============================================================================
-- Behavior_ReviveAlly.lua
-- Live-NPC ally rescue movement and application wrapper.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

local MOVE_SPEED = 0.035
local STOP_DISTANCE = 0.5

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
        return false
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
        staminaMode = "ally_revive",
        desiredRun = false,
        stopDistance = STOP_DISTANCE,
        allowObstacleInteract = true,
        allowDamageRetreat = true,
        blockCounterKey = "allyReviveBlockedTicks",
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
        npcData.allyReviveBlockedTicks = 0
        return true
    end

    if moveState and string.find(tostring(moveState), "interacted_", 1, true) then
        npcData.allyReviveBlockedTicks = 0
        return true
    end

    stopMovement(zombie)
    return false
end

DTNPCLogic.Behaviors["ReviveAlly"] = function(zombie, npcData)
    if not zombie or not npcData or not DTNPCHealth or not DTNPCHealth.ProcessAllyRevive then
        return
    end

    local result = DTNPCHealth.ProcessAllyRevive(zombie, npcData)
    if type(result) ~= "table" then
        stopMovement(zombie)
        return
    end

    local action = tostring(result.action or "")
    if action == "move" and type(result.point) == "table" then
        moveToPoint(zombie, npcData, result.point)
        return
    end

    stopMovement(zombie)
    local point = result.point
    if point and zombie.faceLocation then
        zombie:faceLocation(point.x, point.y)
    end
end

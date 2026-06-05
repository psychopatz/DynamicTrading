-- ==============================================================================
-- Behavior_ReturnHome.lua
-- Autonomous return-home maintenance behavior.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

local RETURN_HOME_SPEED = 0.05

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

local function resumeDefaultState(npcData)
    local nextState = tostring(npcData.returnHomeResumeState or "")
    if nextState == "" and DTNPCRoles and DTNPCRoles.ResolveDefaultState then
        nextState = tostring(DTNPCRoles.ResolveDefaultState(npcData) or "")
    end
    if nextState == "" or nextState == "ReturnHome" then
        nextState = "Idle"
    end

    npcData.returnHomeResumeState = nil
    npcData.returnHomeEligibleSince = nil
    npcData.state = nextState
end

DTNPCLogic.Behaviors["ReturnHome"] = function(zombie, npcData)
    if not zombie or not npcData or not DTNPCRoles then
        return
    end

    if DTNPCRoles.ShouldAutoReturnHome == nil or DTNPCRoles.ShouldAutoReturnHome(npcData) ~= true then
        stopMovement(zombie)
        resumeDefaultState(npcData)
        return
    end

    local home = DTNPCRoles.ResolveHomeTarget and DTNPCRoles.ResolveHomeTarget(npcData) or nil
    if type(home) ~= "table" or home.x == nil or home.y == nil then
        stopMovement(zombie)
        resumeDefaultState(npcData)
        return
    end

    local dx = zombie:getX() - tonumber(home.x)
    local dy = zombie:getY() - tonumber(home.y)
    local radius = math.max(1, tonumber(home.radius) or 30)
    if ((dx * dx) + (dy * dy)) <= (radius * radius) then
        stopMovement(zombie)
        resumeDefaultState(npcData)
        return
    end

    local target = {
        getX = function() return tonumber(home.x) end,
        getY = function() return tonumber(home.y) end,
        getZ = function() return tonumber(home.z) or 0 end,
    }

    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    local moved, moveState = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
        target = target,
        speed = RETURN_HOME_SPEED,
        navigationMode = "planned",
        plannerProfile = "colony",
        staminaMode = "return_home",
        desiredRun = false,
        stopDistance = 1.0,
        allowObstacleInteract = true,
        allowDamageRetreat = true,
        blockCounterKey = "returnHomeBlockedTicks",
        stuckTicks = 15,
        faceX = tonumber(home.x),
        faceY = tonumber(home.y),
        anim = {
            animSpeed = 1.0,
            isRunning = false,
            dtWalkType = "Walk",
        },
    })

    if not moved
        and moveState ~= "arrived"
        and moveState ~= "close_enough"
        and moveState ~= "damage_retreat"
        and not (moveState and string.find(tostring(moveState), "interacted_", 1, true)) then
        stopMovement(zombie)
    end
end

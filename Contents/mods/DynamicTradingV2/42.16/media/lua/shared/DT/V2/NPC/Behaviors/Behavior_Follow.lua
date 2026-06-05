-- ==============================================================================
-- Behavior_Follow.lua
-- Handles the logic for following the Master.
-- FIXED: Prevents rubber banding by clearing anchor on Follow state
-- Build 42 Compatible.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "DT/V2/NPC/Sys/Stamina/DTNPC_Stamina"
require "DT/V2/NPC/Behaviors/Behavior_AntiStuck"

-- MOVEMENT CONFIGURATION
local TELEPORT_DIST = 50
local STUCK_TICKS = 15

-- Speeds
local FOLLOW_SPEED_PHYSICAL = 0.075

local FOLLOW_SPACING_PROFILES = {
    near = {
        key = "near",
        startDistance = 7.0,
        stopDistance = 5.4,
    },
    far = {
        key = "far",
        startDistance = 11.5,
        stopDistance = 9.2,
    },
}

-- ==============================================================================
-- 1. UTILITIES
-- ==============================================================================

local function getDist(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

local function normalizeFollowSpacingMode(mode)
    local text = string.lower(tostring(mode or ""))
    if text == "far" then
        return "far"
    end
    if text == "near" then
        return "near"
    end
    return nil
end

local function resolveFollowSpacingProfile(npcData)
    local requested = normalizeFollowSpacingMode(npcData and npcData.followSpacingMode or nil)
    if not requested and npcData and npcData.doObjectiveEscortActive == true then
        requested = "far"
    end

    local profile = requested and FOLLOW_SPACING_PROFILES[requested] or FOLLOW_SPACING_PROFILES.near
    if npcData then
        npcData.followSpacingMode = profile.key
    end
    return profile
end

local function isTileSafe(x, y, z)
    local cell = getCell()
    local sq = cell:getGridSquare(x, y, z)
    if not sq then return true end
    if not sq:isFree(false) then return false end
    if sq:isSolid() or sq:isSolidTrans() then return false end
    return true
end

-- ==============================================================================
-- 2. ANIMATION HANDLERS
-- ==============================================================================

local function forceWalkAnimation(zombie, isRunning)
    if DTNPCMobility and DTNPCMobility.SetLocomotionState then
        DTNPCMobility.SetLocomotionState(zombie, {
            moving = true,
            isRunning = isRunning == true,
            dtWalkType = isRunning == true and "Run" or "Walk",
            animSpeed = isRunning == true and 1.2 or 1.0,
        })
        return
    end

    zombie:setVariable("bMoving", true)
    zombie:setVariable("isMoving", true)

    if isRunning then
        zombie:setVariable("Speed", 1.2)
        zombie:setRunning(true)
    else
        zombie:setVariable("Speed", 1.0)
        zombie:setRunning(false)
    end
end

local function stopAnimation(zombie)
    if DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
        return
    end

    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setRunning(false)
end

local function resetFollowStuck(npcData)
    npcData.followBlockedTicks = 0
end

local function resetFollowMoveState(npcData)
    if not npcData then
        return
    end

    npcData.followMovePrimed = nil
    npcData.followMoveReason = nil
end

local function resetFollowAntiStuck(npcData)
    if DTNPCBehaviorAntiStuck and DTNPCBehaviorAntiStuck.Reset then
        DTNPCBehaviorAntiStuck.Reset(npcData, "Follow")
    end
end

local function primeFollowMovement(zombie, npcData, target, isRunning)
    if not zombie or not npcData or not target then
        return true
    end

    local dx = target:getX() - zombie:getX()
    local dy = target:getY() - zombie:getY()
    local len = math.sqrt((dx * dx) + (dy * dy))
    if len <= 0.001 then
        return true
    end

    dx = dx / len
    dy = dy / len

    if npcData.followMovePrimed == true and npcData.followMoveReason == "follow" then
        return true
    end

    npcData.followMovePrimed = true
    npcData.followMoveReason = "follow"
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end
    forceWalkAnimation(zombie, isRunning == true)
    zombie:faceLocation(zombie:getX() + dx, zombie:getY() + dy)
    return false
end

local function tryUnstick(zombie, z, dirX, dirY)
    local zx = zombie:getX()
    local zy = zombie:getY()
    local candidates = {
        { x = zx + (dirX * 1.5), y = zy + (dirY * 1.5) },
        { x = zx + (dirX * 1.5) - dirY, y = zy + (dirY * 1.5) + dirX },
        { x = zx + (dirX * 1.5) + dirY, y = zy + (dirY * 1.5) - dirX },
        { x = zx - dirY, y = zy + dirX },
        { x = zx + dirY, y = zy - dirX },
    }

    for _, candidate in ipairs(candidates) do
        if isTileSafe(candidate.x, candidate.y, z) then
            zombie:setX(candidate.x)
            zombie:setY(candidate.y)
            zombie:setZ(z)
            return true
        end
    end

    return false
end

-- ==============================================================================
-- 3. BEHAVIOR LOGIC
-- ==============================================================================

DTNPCLogic.Behaviors["Follow"] = function(zombie, npcData, target, dist)
    local spacingProfile = resolveFollowSpacingProfile(npcData)
    local stopThresholdStart = spacingProfile.startDistance
    local stopThresholdEnd = spacingProfile.stopDistance
    
    -- CRITICAL FIX: Clear anchor when following
    -- This prevents rubber banding when switching from Stay to Follow
    npcData.anchorX = nil
    npcData.anchorY = nil
    npcData.anchorZ = nil
    
    if not target then 
        DynamicTrading.Log("DTV2", "NPC", "Follow", "Master not found (Target is nil)")
        if not zombie:isUseless() then zombie:setUseless(true) end
        resetFollowAntiStuck(npcData)
        stopAnimation(zombie)
        return 
    end

    -- print("[DTNPC-Follow] Following target " .. target:getUsername() .. " at dist " .. dist)

    -- 2. HYSTERESIS CHECK
    if not npcData.isMovingState then npcData.isMovingState = false end
    
    local wasMoving = npcData.isMovingState
    local shouldMove = npcData.isMovingState

    if npcData.isMovingState then
        if dist <= stopThresholdEnd then
            shouldMove = false
        end
    else
        if dist >= stopThresholdStart then
            shouldMove = true
        end
    end
    
    npcData.isMovingState = shouldMove

    -- 3. STOPPING LOGIC
    if not shouldMove then
        if not zombie:isUseless() then zombie:setUseless(true) end
        resetFollowStuck(npcData)
        resetFollowMoveState(npcData)
        resetFollowAntiStuck(npcData)
        stopAnimation(zombie)
        zombie:faceLocation(target:getX(), target:getY())
        npcData.tasks = {}
        return
    end

    if shouldMove and not wasMoving then
        resetFollowMoveState(npcData)
    end

    local movementProfile = DTNPCStamina and DTNPCStamina.BuildMovementProfile
        and DTNPCStamina.BuildMovementProfile(zombie, npcData, {
            speed = FOLLOW_SPEED_PHYSICAL,
            desiredRun = false,
            mode = "follow",
        })
        or nil
    if movementProfile and movementProfile.exhausted == true then
        if not zombie:isUseless() then zombie:setUseless(true) end
        resetFollowMoveState(npcData)
        stopAnimation(zombie)
        zombie:faceLocation(target:getX(), target:getY())
        npcData.tasks = {}
        return
    end

    local isRunning = movementProfile and movementProfile.isRunning == true or false
    if not primeFollowMovement(zombie, npcData, target, isRunning) then
        resetFollowStuck(npcData)
        npcData.tasks = {}
        return
    end

    -- 5. MOVING LOGIC
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    local speed = FOLLOW_SPEED_PHYSICAL
    local moved, moveState = DTNPCMobility.MoveTowardTarget(zombie, npcData, {
        target = target,
        speed = speed,
        navigationMode = "planned",
        plannerProfile = "follow",
        allowLeashTeleport = true,
        staminaMode = "follow",
        desiredRun = false,
        stopDistance = stopThresholdEnd,
        allowObstacleInteract = true,
        allowDamageRetreat = true,
        blockCounterKey = "followBlockedTicks",
        stuckTicks = STUCK_TICKS,
        closeDoorTarget = target,
        closeDoorSafeRadius = 3.0,
        faceX = target:getX(),
        faceY = target:getY(),
        anim = {
            animSpeed = isRunning and 1.2 or 1.0,
            isRunning = isRunning,
            dtWalkType = isRunning and "Run" or "Walk",
        },
    })

    if moveState == "exhausted" then
        resetFollowStuck(npcData)
        resetFollowMoveState(npcData)
        resetFollowAntiStuck(npcData)
        stopAnimation(zombie)
        zombie:faceLocation(target:getX(), target:getY())
    elseif moved or moveState == "arrived" or moveState == "close_enough" or moveState == "damage_retreat" then
        resetFollowStuck(npcData)
    elseif moveState and string.find(tostring(moveState), "interacted_", 1, true) then
        resetFollowStuck(npcData)
        zombie:faceLocation(target:getX(), target:getY())
    else
        local recovered = false
        if DTNPCBehaviorAntiStuck and DTNPCBehaviorAntiStuck.TryRecover then
            recovered = DTNPCBehaviorAntiStuck.TryRecover(zombie, npcData, {
                behaviorKey = "Follow",
                target = target,
                currentDist = dist,
                moved = moved,
                moveState = moveState,
                blockCounterKey = "followBlockedTicks",
                blockedTicks = npcData.followBlockedTicks,
                blockedThreshold = STUCK_TICKS + 4,
                hardBlockedThreshold = STUCK_TICKS + 12,
                stallThreshold = STUCK_TICKS + 6,
                minDistance = 2.0,
                farDistance = TELEPORT_DIST,
                farStallThreshold = STUCK_TICKS + 24,
                cooldownTicks = 220,
                maxRecoveries = 2,
                arrivalRadius = 1.0,
                allowExactTarget = false,
                faceX = target:getX(),
                faceY = target:getY(),
            })
        end

        if recovered then
            resetFollowStuck(npcData)
            resetFollowMoveState(npcData)
        else
            resetFollowMoveState(npcData)
            stopAnimation(zombie)
        end
    end

    npcData.tasks = {}
end

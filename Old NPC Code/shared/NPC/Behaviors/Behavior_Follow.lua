-- ==============================================================================
-- Behavior_Follow.lua
-- Handles the logic for following the Master.
-- FIXED: Prevents rubber banding by clearing anchor on Follow state
-- Build 42 Compatible.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

-- MOVEMENT CONFIGURATION
local STOP_THRESHOLD_START = 3.5
local STOP_THRESHOLD_END   = 2.0
local TELEPORT_DIST = 50

-- Speeds
local WALK_SPEED_PHYSICAL = 0.040
local RUN_SPEED_PHYSICAL = 0.075

-- ==============================================================================
-- 1. UTILITIES
-- ==============================================================================

local function getDist(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
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
    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setRunning(false)
end

-- ==============================================================================
-- 3. BEHAVIOR LOGIC
-- ==============================================================================

DTNPCLogic.Behaviors["Follow"] = function(zombie, brain, target, dist)
    
    -- CRITICAL FIX: Clear anchor when following
    -- This prevents rubber banding when switching from Stay to Follow
    brain.anchorX = nil
    brain.anchorY = nil
    brain.anchorZ = nil
    
    if not target then 
        if not zombie:isUseless() then zombie:setUseless(true) end
        stopAnimation(zombie)
        return 
    end

    -- 1. Teleport catch-up
    if dist > TELEPORT_DIST then
        zombie:setX(target:getX() + 1)
        zombie:setY(target:getY() + 1)
        zombie:setZ(target:getZ())
        stopAnimation(zombie)
        return
    end

    -- 2. HYSTERESIS CHECK
    if not brain.isMovingState then brain.isMovingState = false end
    
    local wasMoving = brain.isMovingState
    local shouldMove = brain.isMovingState

    if brain.isMovingState then
        if dist <= STOP_THRESHOLD_END then
            shouldMove = false
        end
    else
        if dist >= STOP_THRESHOLD_START then
            shouldMove = true
        end
    end
    
    brain.isMovingState = shouldMove

    -- 3. WAKE UP CALL
    if shouldMove and not wasMoving then
        if DTNPCLogic.Behaviors["Attack"] then
            DTNPCLogic.Behaviors["Attack"](zombie, brain, target, dist)
        end
        return 
    end

    -- 4. STOPPING LOGIC
    if not shouldMove then
        if not zombie:isUseless() then zombie:setUseless(true) end
        stopAnimation(zombie)
        zombie:faceLocation(target:getX(), target:getY())
        brain.tasks = {}
        return
    end

    -- 5. MOVING LOGIC
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    -- Movement Vector Calculation
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()
    
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt(dx * dx + dy * dy)
    
    if len > 0 then
        dx = dx / len
        dy = dy / len
    end

    -- Rotation
    local dirVector = zombie:getForwardDirection()
    if dirVector then
        dirVector:set(dx, dy)
        dirVector:normalize()
    end

    -- Speed & Collision
    local isRunning = dist > 7.0 or target:isRunning() or target:isSprinting()
    local speed = isRunning and RUN_SPEED_PHYSICAL or WALK_SPEED_PHYSICAL
    
    local nextX = zx + (dx * speed)
    local nextY = zy + (dy * speed)
    local canMove = isTileSafe(nextX, nextY, zz)
    
    if not canMove then
        if isTileSafe(nextX, zy, zz) then
            nextY = zy
            canMove = true
        elseif isTileSafe(zx, nextY, zz) then
            nextX = zx
            canMove = true
        end
    end

    -- Apply Movement
    if canMove then
        forceWalkAnimation(zombie, isRunning)
        zombie:setX(nextX)
        zombie:setY(nextY)
    else
        stopAnimation(zombie)
    end
    
    brain.tasks = {}
end
-- ==============================================================================
-- Behavior_Follow.lua
-- Handles the logic for following the Master.
-- REWRITTEN: Uses GoTo approach - disables AI, teleports incrementally.
-- Build 42 Compatible.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

local STOP_DIST = 2.5
local TELEPORT_DIST = 50

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

local function forceWalkAnimation(zombie, isRunning)
    if isRunning then
        zombie:setVariable("bMoving", true)
        zombie:setVariable("Speed", 1.0)
        zombie:setVariable("WalkType", "Run")
        zombie:setVariable("BanditWalkType", "Run")
    else
        zombie:setVariable("bMoving", true)
        zombie:setVariable("Speed", 0.6)
        zombie:setVariable("WalkType", "Walk")
        zombie:setVariable("BanditWalkType", "Walk")
    end
    zombie:setVariable("isMoving", true)
end

local function stopAnimation(zombie)
    zombie:setVariable("bMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setVariable("isMoving", false)
end

DTNPCLogic.Behaviors["Follow"] = function(zombie, brain, target, dist)
    
    -- 1. Force safety - disable AI
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end
    
    -- No target, just stand
    if not target then 
        stopAnimation(zombie)
        return 
    end

    -- 2. Teleport catch-up if too far
    if dist > TELEPORT_DIST then
        zombie:setX(target:getX() + 1)
        zombie:setY(target:getY() + 1)
        zombie:setZ(target:getZ())
        stopAnimation(zombie)
        return
    end

    -- 3. If close enough, stop
    if dist <= STOP_DIST then
        stopAnimation(zombie)
        zombie:faceLocation(target:getX(), target:getY())
        brain.tasks = {}
        return
    end

    -- 4. Movement calculation
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    local tx, ty = target:getX(), target:getY()
    
    local dx = tx - zx
    local dy = ty - zy
    local len = math.sqrt(dx * dx + dy * dy)
    
    if len > 0 then
        dx = dx / len
        dy = dy / len
    end

    -- Determine speed based on distance
    local isRunning = dist > 6.0 or target:isRunning() or target:isSprinting()
    local speed = isRunning and (brain.runSpeed or DTNPC.DefaultRunSpeed) or (brain.walkSpeed or DTNPC.DefaultWalkSpeed)

    -- 5. Calculate next position
    local nextX = zx + (dx * speed)
    local nextY = zy + (dy * speed)

    -- 6. Collision check
    local canMove = isTileSafe(nextX, nextY, zz)
    
    if not canMove then
        -- Try X only
        if isTileSafe(nextX, zy, zz) then
            nextY = zy
            canMove = true
        -- Try Y only
        elseif isTileSafe(zx, nextY, zz) then
            nextX = zx
            canMove = true
        end
    end

    -- 7. Apply movement
    if canMove then
        zombie:setX(nextX)
        zombie:setY(nextY)
        forceWalkAnimation(zombie, isRunning)
    else
        stopAnimation(zombie)
    end

    -- 8. Rotation
    local dirVector = zombie:getForwardDirection()
    if dirVector then
        dirVector:set(dx, dy)
        dirVector:normalize()
    end
    
    brain.tasks = {}
end
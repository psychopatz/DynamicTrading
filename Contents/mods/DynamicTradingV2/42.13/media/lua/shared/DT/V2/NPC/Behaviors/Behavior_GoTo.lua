-- ==============================================================================
-- Behavior_GoTo.lua
-- Handles specific movement orders (e.g., "Come Here" or Specific Coords).
-- REWRITTEN: Implements "Fake Attack" Wake-Up to fix Mannequin bug.
-- Build 42 Compatible.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

local STOP_DIST = 0.5 -- Stricter stopping distance for precise GoTo

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

local function forceRunAnimation(zombie)
    zombie:setVariable("bMoving", true)
    zombie:setVariable("isMoving", true)
    
    -- Rely on engine for WalkType to avoid read-only errors
    
    zombie:setVariable("Speed", 1.2) -- Force run speed for GoTo
    zombie:setVariable("BanditWalkType", "Run") -- Hint for Bandit layer if present
end

DTNPCLogic.Behaviors["GoTo"] = function(zombie, brain, target, dist)
    
    -- 1. Check if we have anywhere to go
    if not brain.tasks or #brain.tasks == 0 then
        brain.state = "Stay"
        brain.isMovingState = false
        zombie:setVariable("bMoving", false)
        zombie:setVariable("Speed", 0.0)
        
        -- Ensure safety when idle
        if not zombie:isUseless() then zombie:setUseless(true) end
        return
    end

    -- 2. WAKE UP CALL (The Fix)
    -- If we haven't started moving yet, kickstart the engine
    if not brain.isMovingState then
        brain.isMovingState = true
        
        -- Run Attack Logic for 1 tick to reset skeleton
        if DTNPCLogic.Behaviors["Attack"] then
            DTNPCLogic.Behaviors["Attack"](zombie, brain, target, dist)
        end
        return -- Exit and let the engine process the frame
    end

    -- 3. MANUAL MOVEMENT LOGIC
    -- If we are here, we are in Frame 2+ of movement. Take control.
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    local task = brain.tasks[1]
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    
    -- Check arrival
    local distToGoal = getDist(zx, zy, task.x, task.y)
    
    if distToGoal <= STOP_DIST then
        table.remove(brain.tasks, 1)
        
        if #brain.tasks == 0 then
            -- All done
            brain.state = "Stay"
            brain.isMovingState = false
            
            -- Face final direction
            local fd = zombie:getForwardDirection()
            if fd then
                fd:set(task.x - zx, task.y - zy)
                fd:normalize()
            end
            
            zombie:setVariable("bMoving", false)
            zombie:setVariable("Speed", 0.0)
            print("[DTNPC] GoTo: Destination Reached.")
        end
        return
    end

    -- Calculate Vector
    local dx = task.x - zx
    local dy = task.y - zy
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        dx = dx / len
        dy = dy / len
    end

    local speed = brain.runSpeed or DTNPC.DefaultRunSpeed
    local nextX = zx + (dx * speed)
    local nextY = zy + (dy * speed)

    -- Collision Check
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

    -- Apply
    if canMove then
        zombie:setX(nextX)
        zombie:setY(nextY)
        zombie:setZ(task.z or 0)
        forceRunAnimation(zombie)
        
        -- Rotation
        local dirVector = zombie:getForwardDirection()
        if dirVector then
            dirVector:set(dx, dy)
            dirVector:normalize()
        end
    else
        -- Stuck/Blocked logic
        print("[DTNPC] GoTo: Path blocked. Aborting.")
        brain.state = "Stay"
        brain.isMovingState = false
        brain.tasks = {}
        zombie:setVariable("bMoving", false)
    end
end
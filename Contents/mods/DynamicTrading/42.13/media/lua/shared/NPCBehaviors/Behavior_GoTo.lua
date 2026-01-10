-- ==============================================================================
-- Behavior_GoTo.lua
-- Handles specific movement orders (e.g., "Come Here" or Specific Coords).
-- UPDATED: Removed crashing 'isEmpty()' check. Uses safe Stop-and-Go waypoint logic.
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}
MyNPCLogic.Behaviors = MyNPCLogic.Behaviors or {}

-- Helper: Get distance between zombie and a point
local function distToPoint(zombie, x, y)
    local dx = zombie:getX() - x
    local dy = zombie:getY() - y
    return math.sqrt(dx * dx + dy * dy)
end

-- Helper: Calculate an intermediate point (Breadcrumb) 20 tiles away
local function getIntermediatePoint(zombie, targetX, targetY)
    local dx = targetX - zombie:getX()
    local dy = targetY - zombie:getY()
    local dist = math.sqrt(dx * dx + dy * dy)
    
    -- If target is close enough, just go straight there
    if dist <= 20 then return targetX, targetY end
    
    -- Normalize and scale to 20 tiles
    local stepX = (dx / dist) * 20
    local stepY = (dy / dist) * 20
    
    return zombie:getX() + stepX, zombie:getY() + stepY
end

MyNPCLogic.Behaviors["GoTo"] = function(zombie, brain, target, dist)
    
    -- 1. BANDIT TRICK: BLINDNESS
    -- Prevents the zombie from detecting nearby players and entering Combat Mode.
    zombie:setTarget(nil)
    zombie:setAttackedBy(nil)
    zombie:setEatBodyTarget(nil, false)

    -- 2. CHECK FOR TASKS
    if brain.tasks and #brain.tasks > 0 then
        local task = brain.tasks[1]
        
        -- Calculate distance to the FINAL destination
        local d = distToPoint(zombie, task.x, task.y)
        
        -- 3. CHECK ARRIVAL (Final Goal)
        if d < 1.5 then
            -- We have arrived.
            table.remove(brain.tasks, 1)
            zombie:setPath2(nil)
            
            -- If queue empty, switch to Guard
            if #brain.tasks == 0 then
                brain.state = "Stay"
                zombie:setUseless(true)
                print("[MyNPC] Destination Reached.")
            end
        else
            -- 4. MOVING LOGIC
            -- Enable AI so they can walk
            if zombie:isUseless() then zombie:setUseless(false) end
            
            -- 5. PATH UPDATE
            -- We only issue a new command if they have STOPPED moving.
            -- This creates a safe loop: Walk 20 tiles -> Stop -> Calculate Next 20 tiles -> Walk.
            if not zombie:isMoving() then
                
                -- Determine the next "Breadcrumb" waypoint
                local wayX, wayY = getIntermediatePoint(zombie, task.x, task.y)
                
                zombie:setRunning(true) 
                zombie:pathToLocation(wayX, wayY, task.z or 0)
            end
        end
    else
        -- Fallback
        brain.state = "Stay"
    end
end
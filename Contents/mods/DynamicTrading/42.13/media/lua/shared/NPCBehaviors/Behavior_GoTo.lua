-- ==============================================================================
-- Behavior_GoTo.lua
-- Handles specific movement orders (e.g., "Come Here" or Specific Coords).
-- UPDATED: Forces Animation variables to prevent "Ice Skating" while Useless.
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}
MyNPCLogic.Behaviors = MyNPCLogic.Behaviors or {}

-- MOVEMENT SETTINGS
local SPEED = 0.08 -- Tiles per tick (Approx Run Speed)
local STOP_DIST = 2.0 -- Stop 2 tiles away (Personal Space)

-- Helper: Get distance
local function getDist(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

-- Helper: Force Animation Variables
-- Since the zombie is "Useless", the engine thinks it's Idle. We must lie to it.
local function forceRunAnimation(zombie)
    -- 1. Vanilla Variables
    zombie:setVariable("bMoving", true)
    zombie:setVariable("Speed", 1.0)
    zombie:setVariable("WalkType", "Run")
    zombie:setVariable("isMoving", true)
    
    -- 2. Bandits/Custom Variables (If AnimSets are present)
    zombie:setVariable("BanditWalkType", "Run")
    
    -- 3. Force "Run" state if the engine ignores variables
    -- Note: "Run" is a generic state name, usually safe.
    -- If using Vanilla, this might not perfectly loop without velocity, but variables help.
end

MyNPCLogic.Behaviors["GoTo"] = function(zombie, brain, target, dist)
    
    -- 1. FORCE SAFETY
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    -- 2. VALIDATE TASKS
    if not brain.tasks or #brain.tasks == 0 then
        brain.state = "Stay"
        -- Reset variables when stopping
        zombie:setVariable("bMoving", false)
        zombie:setVariable("Speed", 0.0)
        return
    end

    local task = brain.tasks[1]
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    
    -- 3. CHECK ARRIVAL
    local distToGoal = getDist(zx, zy, task.x, task.y)
    
    if distToGoal <= STOP_DIST then
        table.remove(brain.tasks, 1)
        
        if #brain.tasks == 0 then
            brain.state = "Stay"
            -- Reset Facing
            local fd = zombie:getForwardDirection()
            if fd then
                fd:set(task.x - zx, task.y - zy)
                fd:normalize()
            end
            
            -- STOP ANIMATION
            zombie:setVariable("bMoving", false)
            zombie:setVariable("Speed", 0.0)
            
            print("[MyNPC] GoTo: Destination Reached (Manual).")
        end
        return
    end

    -- 4. VECTOR CALCULATION
    local dx = task.x - zx
    local dy = task.y - zy
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        dx = dx / len
        dy = dy / len
    end

    -- 5. CALCULATE NEXT POSITION
    local nextX = zx + (dx * SPEED)
    local nextY = zy + (dy * SPEED)

    -- 6. COLLISION CHECK
    local cell = getCell()
    local nextSq = cell:getGridSquare(nextX, nextY, zz)
    local currentSq = zombie:getSquare()
    local canMove = true

    if nextSq and nextSq ~= currentSq then
        if not nextSq:isFree(false) then canMove = false end
        -- Safe Boolean Check
        if nextSq:isSolid() or nextSq:isSolidTrans() then canMove = false end
    end

    -- 7. APPLY MOVEMENT
    if canMove then
        zombie:setX(nextX)
        zombie:setY(nextY)
        zombie:setZ(task.z or 0)
        
        -- FORCE ANIMATION NOW
        forceRunAnimation(zombie)
    else
        print("[MyNPC] GoTo: Path blocked. Stopping.")
        brain.state = "Stay"
        brain.tasks = {}
        zombie:setVariable("bMoving", false)
        return
    end

    -- 8. ROTATION (Server Safe)
    local dirVector = zombie:getForwardDirection()
    if dirVector then
        dirVector:set(dx, dy)
        dirVector:normalize()
    end
end
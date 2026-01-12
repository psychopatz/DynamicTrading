-- ==============================================================================
-- Behavior_GoTo.lua
-- Handles specific movement orders (e.g., "Come Here" or Specific Coords).
-- Build 42 Compatible.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

local STOP_DIST = 2.0

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
    zombie:setVariable("Speed", 1.0)
    zombie:setVariable("WalkType", "Run")
    zombie:setVariable("isMoving", true)
    zombie:setVariable("BanditWalkType", "Run")
end

DTNPCLogic.Behaviors["GoTo"] = function(zombie, brain, target, dist)
    
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    if not brain.tasks or #brain.tasks == 0 then
        brain.state = "Stay"
        zombie:setVariable("bMoving", false)
        zombie:setVariable("Speed", 0.0)
        return
    end

    local task = brain.tasks[1]
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    
    local distToGoal = getDist(zx, zy, task.x, task.y)
    
    if distToGoal <= STOP_DIST then
        table.remove(brain.tasks, 1)
        
        if #brain.tasks == 0 then
            brain.state = "Stay"
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

    if canMove then
        zombie:setX(nextX)
        zombie:setY(nextY)
        zombie:setZ(task.z or 0)
        forceRunAnimation(zombie)
    else
        print("[DTNPC] GoTo: Path blocked. Stopping.")
        brain.state = "Stay"
        brain.tasks = {}
        zombie:setVariable("bMoving", false)
        return
    end

    local dirVector = zombie:getForwardDirection()
    if dirVector then
        dirVector:set(dx, dy)
        dirVector:normalize()
    end
end
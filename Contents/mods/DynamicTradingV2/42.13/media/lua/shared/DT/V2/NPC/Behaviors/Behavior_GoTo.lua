-- ==============================================================================
-- Behavior_GoTo.lua
-- Handles specific movement orders (e.g., "Come Here" or Specific Coords).
-- REWRITTEN: Implements "Fake Attack" Wake-Up to fix Mannequin bug.
-- Build 42 Compatible.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

local STOP_DIST = 0.5 -- Stricter stopping distance for precise GoTo
local STUCK_TICKS = 15
local STUCK_ABORT_TICKS = 60

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
    zombie:setVariable("Speed", 1.2) -- Force run speed for GoTo
    zombie:setVariable("DTWalkType", "Run")
    zombie:setVariable("WalkType", "1")
    zombie:setRunning(true)
end

local function resetGoToStuck(npcData)
    npcData.goToBlockedTicks = 0
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

DTNPCLogic.Behaviors["GoTo"] = function(zombie, npcData, target, dist)
    
    -- 1. Check if we have anywhere to go
    if not npcData.tasks or #npcData.tasks == 0 then
        npcData.state = "Stay"
        npcData.isMovingState = false
        resetGoToStuck(npcData)
        zombie:setVariable("bMoving", false)
        zombie:setVariable("Speed", 0.0)
        
        -- Ensure safety when idle
        if not zombie:isUseless() then zombie:setUseless(true) end
        return
    end

    -- 2. WAKE UP CALL (The Fix)
    -- If we haven't started moving yet, kickstart the engine
    if not npcData.isMovingState then
        npcData.isMovingState = true
        
        -- Run Attack Logic for 1 tick to reset skeleton
        if DTNPCLogic.Behaviors["Attack"] then
            DTNPCLogic.Behaviors["Attack"](zombie, npcData, target, dist)
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

    local task = npcData.tasks[1]
    local zx, zy, zz = zombie:getX(), zombie:getY(), zombie:getZ()
    
    -- Check arrival
    local distToGoal = getDist(zx, zy, task.x, task.y)
    
    if distToGoal <= STOP_DIST then
        table.remove(npcData.tasks, 1)
        
        if #npcData.tasks == 0 then
            -- All done
            npcData.state = "Stay"
            npcData.isMovingState = false
            resetGoToStuck(npcData)
            
            -- Face final direction
            if math.abs(task.x - zx) > 0.001 or math.abs(task.y - zy) > 0.001 then
                zombie:faceLocation(task.x, task.y)
            end
            
            zombie:setVariable("bMoving", false)
            zombie:setVariable("Speed", 0.0)
            DynamicTrading.Log("DTV2", "NPC", "Order", "GoTo: Destination Reached.")
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

    local speed = DynamicTrading.GetNPCRunSpeed()
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
        resetGoToStuck(npcData)
        zombie:setX(nextX)
        zombie:setY(nextY)
        zombie:setZ(task.z or 0)
        forceRunAnimation(zombie)
        
        -- Rotation
        if math.abs(dx) > 0.001 or math.abs(dy) > 0.001 then
            zombie:faceLocation(nextX + dx, nextY + dy)
        end
    else
        npcData.goToBlockedTicks = (npcData.goToBlockedTicks or 0) + 1

        if npcData.goToBlockedTicks >= STUCK_TICKS and tryUnstick(zombie, zz, dx, dy) then
            resetGoToStuck(npcData)
            forceRunAnimation(zombie)
            return
        end

        if npcData.goToBlockedTicks >= STUCK_ABORT_TICKS then
            DynamicTrading.Log("DTV2", "NPC", "Order", "GoTo: Path blocked too long. Aborting.")
            npcData.state = "Stay"
            npcData.isMovingState = false
            npcData.tasks = {}
            resetGoToStuck(npcData)
            zombie:setVariable("bMoving", false)
            zombie:setVariable("Speed", 0.0)
        else
            zombie:setVariable("bMoving", false)
            zombie:setVariable("Speed", 0.0)
        end
    end
end

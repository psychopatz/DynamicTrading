-- ==============================================================================
-- Behavior_Flee.lua
-- Handles "Fleeing" and "Merchant Leaving" logic.
-- REWRITTEN: Implements "Fake Attack" Wake-Up to fix Mannequin bug.
-- Build 42 Compatible.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

local DESPAWN_DIST = 35

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
    
    -- Let engine handle WalkType
    
    zombie:setVariable("Speed", 1.2) -- Force run speed
    zombie:setVariable("BanditWalkType", "Run")
end

DTNPCLogic.Behaviors["Flee"] = function(zombie, brain, target, dist)
    
    -- 1. DESPAWN CHECK (Merchant Exit)
    -- Only despawn if we have a valid target and are actually far away.
    -- dist == 9999 means target not found, so we should NOT despawn yet.
    if target and dist > DESPAWN_DIST and dist < 1000 then
        if brain.removalRequested then return end -- Prevent flooding!
        
        local uuid = brain.uuid
        local returnTime = getGameTime():getWorldAgeHours() + ZombRand(2, 5) -- Returns in 2-4 hours
        
        if isClient() then
             print("[DTNPC-Flee] TARGET REACHED: Requesting removal for fleeing NPC: " .. (brain.name or uuid) .. " (Dist: " .. math.floor(dist) .. ")")
             local nextStatus = brain.requestedReturnStatus or "Resting"
             sendClientCommand(getPlayer(), "DTNPC", "RemoveNPC", { uuid = uuid, status = "Away", returnTime = returnTime, returnStatus = nextStatus })
             brain.removalRequested = true -- Prevent further requests
             -- We stop processing locally but let the server handle removeFromWorld to avoid sync issues
        elseif DTNPCManager then 
             print("[DTNPC-Flee] TARGET REACHED: Server-side removal for fleeing NPC: " .. (brain.name or uuid) .. " (Dist: " .. math.floor(dist) .. ")")
             local nextStatus = brain.requestedReturnStatus or "Resting"
             DTNPCManager.RemoveData(uuid, "Away", returnTime, nextStatus)
             zombie:removeFromWorld()
             zombie:removeFromSquare()
        end
        return
    end

    -- Periodic Fleeing Update
    if not brain.fleePrintTimer then brain.fleePrintTimer = 0 end
    brain.fleePrintTimer = brain.fleePrintTimer + 1
    if brain.fleePrintTimer >= 60 then
        brain.fleePrintTimer = 0
        print("[DTNPC-Flee] NPC " .. (brain.name or "NPC") .. " is running away. Dist: " .. math.floor(dist) .. "/" .. DESPAWN_DIST)
    end

    -- 2. DETERMINE MOVEMENT VECTOR
    local dx, dy = 0, 0
    local zx, zy = zombie:getX(), zombie:getY()
    local hasDestination = false

    if target then
        -- Run AWAY from target
        dx = zx - target:getX()
        dy = zy - target:getY()
        
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0 then
            dx = dx / len
            dy = dy / len
        end
        
        -- Store direction in case target vanishes/dies so we keep running
        brain.lastFleeX = dx
        brain.lastFleeY = dy
        hasDestination = true
    elseif brain.lastFleeX then
        -- Keep running in last known direction
        dx = brain.lastFleeX
        dy = brain.lastFleeY
        hasDestination = true
    else
        -- No target, no memory. Stand still.
        if not zombie:isUseless() then zombie:setUseless(true) end
        brain.isMovingState = false
        zombie:setVariable("bMoving", false)
        zombie:setVariable("Speed", 0.0)
        return
    end

    -- 3. WAKE UP CALL (The Fix)
    if not brain.isMovingState then brain.isMovingState = false end
    
    local wasMoving = brain.isMovingState
    brain.isMovingState = hasDestination -- Fleeing is binary: we run or we don't.

    if brain.isMovingState and not wasMoving then
        -- Trigger Attack logic for 1 tick to reset skeleton
        if DTNPCLogic.Behaviors["Attack"] then
            DTNPCLogic.Behaviors["Attack"](zombie, brain, target, dist)
        end
        return -- Let engine process the animation update
    end

    -- 4. MANUAL MOVEMENT
    -- Frame 2+ of fleeing. Take control.
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    local speed = brain.runSpeed or DTNPC.DefaultRunSpeed
    local nextX = zx + (dx * speed)
    local nextY = zy + (dy * speed)
    local z = zombie:getZ()

    local canMove = isTileSafe(nextX, nextY, z)
    
    -- Simple obstacle avoidance (Slide along walls)
    if not canMove then
        if isTileSafe(nextX, zy, z) then
            nextY = zy
            canMove = true
        elseif isTileSafe(zx, nextY, z) then
            nextX = zx
            canMove = true
        end
    end

    if canMove then
        zombie:setX(nextX)
        zombie:setY(nextY)
        forceRunAnimation(zombie)
        
        -- Rotation
        local dirVector = zombie:getForwardDirection()
        if dirVector then
            dirVector:set(dx, dy)
            dirVector:normalize()
        end
    else
        -- Blocked completely
        zombie:setVariable("bMoving", false)
        zombie:setVariable("Speed", 0.0)
    end
end
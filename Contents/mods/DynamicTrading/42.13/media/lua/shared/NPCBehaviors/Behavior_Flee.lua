-- ==============================================================================
-- Behavior_Flee.lua
-- Handles "Fleeing" and "Merchant Leaving" logic.
-- UPDATED: Forces Animation variables to prevent "Ice Skating" while Useless.
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}
MyNPCLogic.Behaviors = MyNPCLogic.Behaviors or {}

-- MOVEMENT SETTINGS
local SPEED = 0.09 -- Slightly faster than GoTo (Panic Run)
local DESPAWN_DIST = 35 -- Distance at which they escape the map

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
end

MyNPCLogic.Behaviors["Flee"] = function(zombie, brain, target, dist)
    
    -- 1. FORCE SAFETY
    -- Disable the AI so they don't lock onto the player for combat.
    if not zombie:isUseless() then
        zombie:setUseless(true)
        zombie:setPath2(nil)
        zombie:setRunning(false)
    end

    -- 2. DESPAWN CHECK
    if dist > DESPAWN_DIST then
        if MyNPCManager then MyNPCManager.Unregister(zombie) end
        zombie:removeFromWorld()
        zombie:removeFromSquare()
        print("[MyNPC] " .. brain.name .. " has escaped safely.")
        return
    end

    -- 3. DETERMINE DIRECTION
    local dx, dy = 0, 0
    local zx, zy = zombie:getX(), zombie:getY()

    if target then
        -- Vector: ZombiePos - TargetPos = Direction AWAY
        dx = zx - target:getX()
        dy = zy - target:getY()
        
        -- Normalize
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0 then
            dx = dx / len
            dy = dy / len
        end
        
        -- Save this direction in case we lose the target momentarily
        brain.lastFleeX = dx
        brain.lastFleeY = dy
    elseif brain.lastFleeX then
        -- Keep running in previous direction if target lost
        dx = brain.lastFleeX
        dy = brain.lastFleeY
    else
        -- No target, no memory? Just stand there.
        zombie:setVariable("bMoving", false)
        zombie:setVariable("Speed", 0.0)
        return
    end

    -- 4. CALCULATE NEXT POSITION
    local nextX = zx + (dx * SPEED)
    local nextY = zy + (dy * SPEED)
    local z = zombie:getZ()

    -- 5. COLLISION CHECK
    local cell = getCell()
    local nextSq = cell:getGridSquare(nextX, nextY, z)
    local currentSq = zombie:getSquare()
    local canMove = true

    if nextSq and nextSq ~= currentSq then
        if not nextSq:isFree(false) then
            canMove = false
        end
        -- Check for solid objects (Safe Boolean Method)
        if nextSq:isSolid() or nextSq:isSolidTrans() then
             canMove = false 
        end
    end

    -- 6. APPLY MOVEMENT
    if canMove then
        zombie:setX(nextX)
        zombie:setY(nextY)
        forceRunAnimation(zombie)
    else
        -- Wall Sliding Logic (Wiggle along walls)
        local moved = false
        
        -- Try moving ONLY X
        local tryX = cell:getGridSquare(nextX, zy, z)
        local xOk = tryX and tryX:isFree(false) and not tryX:isSolid() and not tryX:isSolidTrans()
        
        if xOk then
            zombie:setX(nextX)
            moved = true
        else
            -- Try moving ONLY Y
            local tryY = cell:getGridSquare(zx, nextY, z)
            local yOk = tryY and tryY:isFree(false) and not tryY:isSolid() and not tryY:isSolidTrans()
            
            if yOk then
                zombie:setY(nextY)
                moved = true
            end
        end
        
        if moved then
            forceRunAnimation(zombie)
        else
            -- Totally stuck
            zombie:setVariable("bMoving", false)
            zombie:setVariable("Speed", 0.0)
        end
    end

    -- 7. ROTATION (Server Safe)
    local dirVector = zombie:getForwardDirection()
    if dirVector then
        dirVector:set(dx, dy)
        dirVector:normalize()
    end
end
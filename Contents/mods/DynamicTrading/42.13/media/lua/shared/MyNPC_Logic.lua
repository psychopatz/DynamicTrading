-- ==============================================================================
-- MyNPC_Logic.lua
-- The "Driver": Controls the movement, facing, and behavior.
-- FIXED: Replaced deprecated path:clear() with zombie:setPath2(nil).
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}

-- Performance Settings
local TICK_LIMIT = 10 -- Run logic every 10 ticks
local tickCounter = 0

-- ==============================================================================
-- 1. UTILITY FUNCTIONS
-- ==============================================================================

-- Safe distance calculator (Math-based, crash-proof)
local function calculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end
    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end

-- ==============================================================================
-- 2. MAIN LOOP
-- ==============================================================================

function MyNPCLogic.OnTick()
    -- Run on Server (Dedicated/Host)
    if isClient() then return end

    tickCounter = tickCounter + 1
    if tickCounter < TICK_LIMIT then return end
    tickCounter = 0

    -- Get zombies in the current cell
    local cell = getCell()
    if not cell then return end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return end
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        
        -- Check if this zombie has our custom Brain
        local brain = MyNPC.GetBrain(zombie)
        if brain then
            MyNPCLogic.ProcessNPC(zombie, brain)
        end
    end
end

-- ==============================================================================
-- 3. HELPER: FIND CLOSEST ENTITY
-- ==============================================================================

function MyNPCLogic.GetClosestTarget(zombie)
    local bestTarget = nil
    local closestDist = 9999

    -- A. Check specific player slots (0-3 covers SP and Split-screen)
    for i = 0, 3 do
        local p = getSpecificPlayer(i)
        if p and not p:isDead() then
            local dist = calculateDistance(zombie, p)
            if dist < closestDist then
                closestDist = dist
                bestTarget = p
            end
        end
    end

    -- B. IF MULTIPLAYER: Check the online players list as well
    if isServer() then
        local onlinePlayers = getOnlinePlayers()
        if onlinePlayers then
            for i = 0, onlinePlayers:size() - 1 do
                local p = onlinePlayers:get(i)
                if p and not p:isDead() then
                    local dist = calculateDistance(zombie, p)
                    if dist < closestDist then
                        closestDist = dist
                        bestTarget = p
                    end
                end
            end
        end
    end

    return bestTarget, closestDist
end

-- ==============================================================================
-- 4. DECISION MAKING
-- ==============================================================================

function MyNPCLogic.ProcessNPC(zombie, brain)
    -- 1. Safety Override
    zombie:setTarget(nil)
    zombie:setUseless(true) 
    
    -- 2. Find Interest (Closest Entity)
    local target, dist = MyNPCLogic.GetClosestTarget(zombie)
    
    if not target then return end -- Nothing to do

    local isMoving = false

    -- 3. Behavior: "Follow" (Only follows Players)
    if brain.state == "Follow" and instanceof(target, "IsoPlayer") then
        
        -- TELEPORT (Rubber-banding)
        if dist > 50 then
            zombie:setX(target:getX() + 2)
            zombie:setY(target:getY() + 2)
            zombie:setZ(target:getZ())
            zombie:setLx(target:getX()) 
            zombie:setLy(target:getY())
            
        -- MOVE
        elseif dist > 3 then
            zombie:pathToLocation(target:getX(), target:getY(), target:getZ())
            isMoving = true
            
            if dist > 8 then
                zombie:setRunning(true)
            else
                zombie:setRunning(false)
            end
            
        -- STOP
        else
            -- FIXED: clear() does not exist in B42 path objects.
            -- setPath2(nil) forces the character to stop moving.
            zombie:setPath2(nil)
            isMoving = false
        end
    end

    -- 4. "Smart Look" (Face the target when not moving)
    if not isMoving then
        zombie:faceThisObject(target)
    end
end

-- Register the loop
Events.OnTick.Add(MyNPCLogic.OnTick)
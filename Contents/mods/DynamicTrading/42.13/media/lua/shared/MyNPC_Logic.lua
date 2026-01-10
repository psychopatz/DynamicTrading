-- ==============================================================================
-- MyNPC_Logic.lua
-- The "Driver": Controls the movement and behavior of the NPC.
-- FIXED: Replaced non-existent 'getClosestPlayer' with manual player search.
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}

-- Performance: Run logic only every 10 ticks (approx 6 times/sec)
local TICK_LIMIT = 10
local tickCounter = 0

-- ==============================================================================
-- 1. MAIN LOOP
-- ==============================================================================

function MyNPCLogic.OnTick()
    -- Run on Server (Dedicated/Host)
    if isClient() then return end

    tickCounter = tickCounter + 1
    if tickCounter < TICK_LIMIT then return end
    tickCounter = 0

    local zombieList = getCell():getZombieList()
    
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
-- 2. DECISION MAKING
-- ==============================================================================

function MyNPCLogic.ProcessNPC(zombie, brain)
    -- 1. Safety Override: Ensure it doesn't attack the player
    zombie:setTarget(nil)
    zombie:setUseless(true) 
    
    -- 2. Find the Master (Closest Player)
    local player = nil
    local closestDist = 9999
    
    -- Get list of all players currently in the server/game
    local players = getOnlinePlayers()
    
    if players then
        for i = 0, players:size() - 1 do
            local p = players:get(i)
            if p and not p:isDead() then
                local dist = zombie:getDistTo(p)
                if dist < closestDist then
                    closestDist = dist
                    player = p
                end
            end
        end
    end
    
    if not player then return end -- No master nearby, just idle

    -- 3. Behavior: "Follow"
    if brain.state == "Follow" then
        
        -- TELEPORT: If left way behind (Rubber-banding)
        if closestDist > 50 then
            zombie:setX(player:getX() + 2)
            zombie:setY(player:getY() + 2)
            zombie:setZ(player:getZ())
            zombie:setLx(player:getX()) 
            zombie:setLy(player:getY())
            
        -- MOVE: If too far away, walk to player
        elseif closestDist > 3 then
            zombie:pathToLocation(player:getX(), player:getY(), player:getZ())
            
            if closestDist > 8 then
                zombie:setRunning(true)
            else
                zombie:setRunning(false)
            end
            
        -- STOP: If close enough, stop moving
        else
            zombie:getPath():clear()
        end
        
        -- 4. Face the player when idle
        if closestDist <= 3 then
           zombie:faceThisObject(player)
        end
    end
end

-- Register the loop
Events.OnTick.Add(MyNPCLogic.OnTick)
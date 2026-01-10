-- ==============================================================================
-- MyNPC_Logic.lua
-- The "Driver": Controls the movement.
-- FIXED: Updated Teleport logic to use B42 function names (setLastX/setLastY).
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}

local TICK_LIMIT = 10 
local tickCounter = 0

-- ==============================================================================
-- 1. UTILITY FUNCTIONS
-- ==============================================================================

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
    if isClient() then return end

    tickCounter = tickCounter + 1
    if tickCounter < TICK_LIMIT then return end
    tickCounter = 0

    local cell = getCell()
    if not cell then return end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return end
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
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
-- 4. DECISION MAKING (STATE MACHINE)
-- ==============================================================================

function MyNPCLogic.ProcessNPC(zombie, brain)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    
    local target, dist = MyNPCLogic.GetClosestTarget(zombie)
    
    if not brain.pathTimer then brain.pathTimer = 0 end
    brain.pathTimer = brain.pathTimer - 1

    -- STATE: FOLLOW
    if brain.state == "Follow" and target then
        
        if dist > 50 then -- Teleport if lost
            -- FIXED: B42 uses setLastX instead of setLx
            local tx = target:getX() + 2
            local ty = target:getY() + 2
            local tz = target:getZ()

            zombie:setX(tx)
            zombie:setY(ty)
            zombie:setZ(tz)
            
            if zombie.setLastX then zombie:setLastX(tx) end
            if zombie.setLastY then zombie:setLastY(ty) end
            
            brain.lastTx = nil
            
        elseif dist > 3 then -- Move
            
            if brain.pathTimer <= 0 then
                local tx = math.floor(target:getX())
                local ty = math.floor(target:getY())
                local tz = math.floor(target:getZ())
                
                zombie:pathToLocation(tx, ty, tz)
                zombie:setRunning(false)
                
                brain.pathTimer = 20 
            end
            
        else -- Stop
            zombie:setPath2(nil)
            brain.pathTimer = 0
            zombie:faceThisObject(target)
        end

    -- STATE: STAY
    elseif brain.state == "Stay" then
        zombie:setPath2(nil)
        if target then
            zombie:faceThisObject(target)
        end

    -- STATE: GOTO
    elseif brain.state == "GoTo" and brain.targetX then
        local dx = zombie:getX() - brain.targetX
        local dy = zombie:getY() - brain.targetY
        local distToSpot = math.sqrt(dx * dx + dy * dy)

        if distToSpot > 1 then
            if brain.pathTimer <= 0 then
                zombie:pathToLocation(math.floor(brain.targetX), math.floor(brain.targetY), math.floor(brain.targetZ or 0))
                zombie:setRunning(false)
                brain.pathTimer = 20
            end
        else
            brain.state = "Stay"
            zombie:setPath2(nil)
        end
    end
end

Events.OnTick.Add(MyNPCLogic.OnTick)
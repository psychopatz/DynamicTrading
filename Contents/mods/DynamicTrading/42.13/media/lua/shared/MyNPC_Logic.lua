-- ==============================================================================
-- MyNPC_Logic.lua
-- The "Driver": Controls behavior.
-- UPDATED: Implements Bandits-style Task Queue (Sequencial Movement).
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}

local TICK_LIMIT = 10 
local tickCounter = 0

-- ==============================================================================
-- 1. UTILITY
-- ==============================================================================

local function calculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end
    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end

local function distToCoords(obj, x, y)
    local dx = obj:getX() - x
    local dy = obj:getY() - y
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
-- 3. TARGET FINDER
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
-- 4. TASK GENERATION (The Strategist)
-- ==============================================================================

function MyNPCLogic.GenerateFollowTasks(zombie, brain, target)
    if not target then return end
    
    -- Ensure brain memory exists
    if not brain.tasks then brain.tasks = {} end
    if not brain.lastFollowX then 
        brain.lastFollowX = math.floor(zombie:getX()) 
        brain.lastFollowY = math.floor(zombie:getY()) 
    end

    -- Where is the player NOW?
    local pX = math.floor(target:getX())
    local pY = math.floor(target:getY())
    local pZ = math.floor(target:getZ())

    -- Calculate distance from the LAST waypoint we added
    local dx = brain.lastFollowX - pX
    local dy = brain.lastFollowY - pY
    local distFromLast = math.sqrt(dx*dx + dy*dy)

    -- If player has moved 3 tiles away from the last breadcrumb, drop a new breadcrumb
    if distFromLast > 3 then
        local newTask = { x = pX, y = pY, z = pZ }
        
        -- Add to end of queue
        table.insert(brain.tasks, newTask)
        
        -- Update memory
        brain.lastFollowX = pX
        brain.lastFollowY = pY
        
        -- Cap queue size to prevent infinite memory if they get stuck
        if #brain.tasks > 10 then
            table.remove(brain.tasks, 1) -- Remove oldest
        end
    end
end

-- ==============================================================================
-- 5. TASK EXECUTION (The Driver)
-- ==============================================================================

function MyNPCLogic.ProcessNPC(zombie, brain)
    -- 1. Basics
    if not zombie:isUseless() then zombie:setUseless(true) end
    local target, dist = MyNPCLogic.GetClosestTarget(zombie)

    -- 2. State: FOLLOW (Generate tasks)
    if brain.state == "Follow" and target then
        -- Teleport safety
        if dist > 50 then
            zombie:setX(target:getX() + 2)
            zombie:setY(target:getY() + 2)
            zombie:setZ(target:getZ())
            zombie:setLastX(target:getX())
            zombie:setLastY(target:getY())
            brain.tasks = {} -- Clear queue on teleport
            brain.lastFollowX = math.floor(target:getX())
            brain.lastFollowY = math.floor(target:getY())
        else
            -- Add new waypoints if player moves
            MyNPCLogic.GenerateFollowTasks(zombie, brain, target)
        end
    end

    -- 3. EXECUTE QUEUE
    -- Do we have tasks?
    if brain.tasks and #brain.tasks > 0 then
        
        local currentTask = brain.tasks[1] -- Look at the first one
        local distToTask = distToCoords(zombie, currentTask.x, currentTask.y)
        
        -- ARE WE THERE YET?
        if distToTask < 1.0 then
            -- YES: Remove this task and proceed to next
            table.remove(brain.tasks, 1)
            zombie:setPath2(nil) -- Brief stop to retarget
            
            -- If that was the last task (queue empty now), and state is GoTo, switch to Stay
            if #brain.tasks == 0 and brain.state == "GoTo" then
                brain.state = "Stay"
            end
        else
            -- NO: Move towards task
            -- Only issue command if we stopped moving or target changed significantly
            if not zombie:isMoving() or not brain.currentTaskX or brain.currentTaskX ~= currentTask.x then
                
                zombie:pathToLocation(currentTask.x, currentTask.y, currentTask.z)
                zombie:setRunning(false)
                
                -- Remember what we are currently doing
                brain.currentTaskX = currentTask.x
            end
        end
        
    else
        -- QUEUE EMPTY
        zombie:setPath2(nil)
        
        -- Guard Mode facing
        if target and (brain.state == "Stay" or brain.state == "Follow") then
             zombie:faceThisObject(target)
        end
    end
end

Events.OnTick.Add(MyNPCLogic.OnTick)
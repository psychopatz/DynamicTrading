-- ==============================================================================
-- MyNPC_Logic.lua
-- The "Driver": Controls behavior.
-- UPDATED: Adds Sound Suppression and Aggressive Pathing Enforcement.
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}

-- Ticking every 10 ticks (approx 0.5s) to check status without killing FPS
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

local function suppressSound(zombie)
    if not zombie then return end
    
    -- Method 1: B42 / Late B41 Voice Prefix Hack
    -- Sets the voice family to something that doesn't exist, effectively muting them.
    local desc = zombie:getDescriptor()
    if desc then
        desc:setVoicePrefix("None") 
    end
    
    -- Method 2: Stop Emitter (Direct Silence)
    local emitter = zombie:getEmitter()
    if emitter then
        if emitter:isPlaying("MaleZombieCombined") then emitter:stopSoundByName("MaleZombieCombined") end
        if emitter:isPlaying("FemaleZombieCombined") then emitter:stopSoundByName("FemaleZombieCombined") end
        if emitter:isPlaying("ZombieIdle") then emitter:stopSoundByName("ZombieIdle") end
    end
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
        
        -- Check if this is our NPC
        if zombie:getModData().IsMyNPC then
            local brain = MyNPC.GetBrain(zombie)
            if brain then
                -- Always silence them
                suppressSound(zombie)
                -- Run logic
                MyNPCLogic.ProcessNPC(zombie, brain)
            end
        end
    end
end

-- ==============================================================================
-- 3. TARGET FINDER
-- ==============================================================================

function MyNPCLogic.GetClosestTarget(zombie)
    local brain = MyNPC.GetBrain(zombie)
    if brain and brain.masterID then
        local onlinePlayers = getOnlinePlayers()
        if onlinePlayers then
            for i = 0, onlinePlayers:size() - 1 do
                local p = onlinePlayers:get(i)
                if p and p:getOnlineID() == brain.masterID then
                    return p, calculateDistance(zombie, p)
                end
            end
        end
        
        local p = getSpecificPlayer(0)
        if p and p:getUsername() == brain.master then
             return p, calculateDistance(zombie, p)
        end
    end

    return nil, 9999
end

-- ==============================================================================
-- 4. BEHAVIOR LOGIC
-- ==============================================================================

function MyNPCLogic.ProcessNPC(zombie, brain)
    local target, dist = MyNPCLogic.GetClosestTarget(zombie)

    -- ==========================================================================
    -- STATE: FOLLOW
    -- ==========================================================================
    if brain.state == "Follow" and target then
        
        -- 1. Anti-Despawn / Stuck Teleport
        if dist > 50 then
            zombie:setX(target:getX())
            zombie:setY(target:getY())
            zombie:setZ(target:getZ())
            zombie:setPath2(nil)
            return
        end

        local stopDistance = 2.5
        
        if dist > stopDistance then
            -- == MOVING ==
            
            -- Ensure AI is active so they can walk
            if zombie:isUseless() then zombie:setUseless(false) end
            
            -- FORCEFULLY CLEAR TARGETS so they don't get distracted/aggressive
            zombie:setTarget(nil)
            zombie:setAttackedBy(nil)
            zombie:setEatBodyTarget(nil, false)
            
            local tx = target:getX()
            local ty = target:getY()
            local tz = target:getZ()
            
            local isRunning = (dist > 6.0) or target:isRunning() or target:isSprinting()
            
            -- If not moving, OR if target moved significantly, issue new command
            if not zombie:isMoving() or not brain.lastTargetX or 
               math.abs(brain.lastTargetX - tx) > 2.0 or 
               math.abs(brain.lastTargetY - ty) > 2.0 then
               
                zombie:setRunning(isRunning)
                zombie:pathToLocation(tx, ty, tz)
                
                brain.lastTargetX = tx
                brain.lastTargetY = ty
            end
            
        else
            -- == STOPPING ==
            -- We are close enough. Freeze them to stop wandering.
            if not zombie:isUseless() then
                zombie:setPath2(nil)
                zombie:setUseless(true)
                zombie:setRunning(false)
            end
            
            -- Manual Facing (Since AI is off)
            zombie:faceLocation(target:getX(), target:getY())
        end
        
        brain.tasks = {} -- Clear manual tasks

    -- ==========================================================================
    -- STATE: GOTO (Manual Order)
    -- ==========================================================================
    elseif brain.state == "GoTo" then
        
        if brain.tasks and #brain.tasks > 0 then
            local task = brain.tasks[1]
            local d = distToCoords(zombie, task.x, task.y)
            
            if d < 1.0 then
                -- Arrived
                table.remove(brain.tasks, 1)
                zombie:setPath2(nil)
                
                if #brain.tasks == 0 then
                    brain.state = "Stay"
                    zombie:setUseless(true)
                end
            else
                -- Moving
                if zombie:isUseless() then zombie:setUseless(false) end
                zombie:setTarget(nil) -- No aggression
                
                if not zombie:isMoving() then
                    zombie:setRunning(true)
                    zombie:pathToLocation(task.x, task.y, task.z)
                end
            end
        else
            brain.state = "Stay"
        end

    -- ==========================================================================
    -- STATE: STAY / GUARD
    -- ==========================================================================
    elseif brain.state == "Stay" then
        -- Freeze
        if not zombie:isUseless() then
            zombie:setUseless(true)
            zombie:setPath2(nil)
        end
        
        -- Look at player
        if target and dist < 10 then
            zombie:faceLocation(target:getX(), target:getY())
        end
    end
end

Events.OnTick.Add(MyNPCLogic.OnTick)
-- ==============================================================================
-- MyNPC_Logic.lua
-- The "Controller": Manages the NPC's decisions and delegates specific tasks.
-- UPDATED: Fixed Crash when NPCs are removed/despawned (Backwards Iteration).
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}

-- 1. BEHAVIOR REGISTRY
MyNPCLogic.Behaviors = {} 

-- Ticking limit to save performance (Run logic every ~0.5s)
local TICK_LIMIT = 10 
local tickCounter = 0

-- ==============================================================================
-- 2. HELPER UTILITIES
-- ==============================================================================

local function calculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end
    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end

-- Silence the zombie sounds so they don't groan while working
local function suppressSound(zombie)
    if not zombie then return end
    
    local desc = zombie:getDescriptor()
    if desc then
        desc:setVoicePrefix("None") 
    end
    
    local emitter = zombie:getEmitter()
    if emitter then
        if emitter:isPlaying("MaleZombieCombined") then emitter:stopSoundByName("MaleZombieCombined") end
        if emitter:isPlaying("FemaleZombieCombined") then emitter:stopSoundByName("FemaleZombieCombined") end
        if emitter:isPlaying("ZombieIdle") then emitter:stopSoundByName("ZombieIdle") end
    end
end

-- ==============================================================================
-- 3. CORE LOOP
-- ==============================================================================

function MyNPCLogic.OnTick()
    -- Only run on Server (Logic) or Singleplayer
    if isClient() then return end

    tickCounter = tickCounter + 1
    if tickCounter < TICK_LIMIT then return end
    tickCounter = 0

    local cell = getCell()
    if not cell then return end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return end
    
    -- CRITICAL FIX: Iterate BACKWARDS (size-1 to 0)
    -- This prevents crashes if a behavior (like Flee) removes the zombie from the world.
    for i = zombieList:size() - 1, 0, -1 do
        local zombie = zombieList:get(i)
        
        -- SAFETY CHECK: Ensure the zombie object is valid/loaded
        if zombie then
            
            -- Wrapped in pcall (protected call) to prevent mod crashes from breaking the whole loop
            local success, err = pcall(function()
                if zombie:getModData() and zombie:getModData().IsMyNPC then
                    local brain = MyNPC.GetBrain(zombie)
                    if brain then
                        suppressSound(zombie)
                        MyNPCLogic.ProcessNPC(zombie, brain)
                    end
                end
            end)
            
            -- Optional: Print error if one specific NPC crashes, but keep game running
            if not success then 
                print("[MyNPC] Error processing NPC: " .. tostring(err))
            end
        end
    end
end

Events.OnTick.Add(MyNPCLogic.OnTick)

-- ==============================================================================
-- 4. DECISION MAKER
-- ==============================================================================

function MyNPCLogic.ProcessNPC(zombie, brain)
    -- A. Find the Master
    local master, dist = MyNPCLogic.GetClosestTarget(zombie)

    -- B. CHECK FOR BETRAYAL (Self Defense)
    -- If the NPC is hit by their master, they become hostile.
    MyNPCLogic.CheckForBetrayal(zombie, brain, master)

    -- C. EXECUTE BEHAVIOR
    -- We look up the state in our Behaviors table (e.g., Behaviors["Follow"])
    local currentState = brain.state
    local behaviorFunc = MyNPCLogic.Behaviors[currentState]

    if behaviorFunc then
        -- Run the specific logic for this state (Follow, Guard, Attack, etc.)
        behaviorFunc(zombie, brain, master, dist)
    else
        -- Fallback if state is missing or typo
        if MyNPCLogic.Behaviors["Stay"] then
            MyNPCLogic.Behaviors["Stay"](zombie, brain, master, dist)
        end
    end
end

-- ==============================================================================
-- 5. TARGETING & EVENTS
-- ==============================================================================

function MyNPCLogic.GetClosestTarget(zombie)
    local brain = MyNPC.GetBrain(zombie)
    if not brain then return nil, 9999 end

    -- 1. If we are hostile, we don't care about the master, we target ANY nearby player
    if brain.isHostile then
        local player = zombie:getTarget() -- Built-in zombie target
        if player and instanceof(player, "Player") then
            return player, calculateDistance(zombie, player)
        end
        -- If no current target, check master ID to attack them
    end

    -- 2. Normal Behavior: Find the specific Master
    if brain.masterID then
        local onlinePlayers = getOnlinePlayers()
        if onlinePlayers then
            for i = 0, onlinePlayers:size() - 1 do
                local p = onlinePlayers:get(i)
                if p and p:getOnlineID() == brain.masterID then
                    return p, calculateDistance(zombie, p)
                end
            end
        end
        
        -- Singleplayer fallback
        local p = getSpecificPlayer(0)
        if p and p:getUsername() == brain.master then
             return p, calculateDistance(zombie, p)
        end
    end

    return nil, 9999
end

function MyNPCLogic.CheckForBetrayal(zombie, brain, master)
    -- Get the object that last attacked this zombie
    local attacker = zombie:getAttackedBy()
    
    if attacker and master and attacker == master then
        
        -- 1. Switch State to ATTACK or FLEE
        -- Change this to "Flee" if you want them to run away instead of fighting back.
        brain.state = "Attack" 
        brain.isHostile = true
        
        -- 2. Clear Tasks (Stop farming/following immediately)
        brain.tasks = {}
        
        -- 3. Visual/Debug Feedback
        print("[MyNPC] Betrayal! " .. brain.name .. " is now hostile towards " .. master:getUsername())
        
        -- 4. Clear the attacked flag so we don't spam this logic
        zombie:setAttackedBy(nil)
    end
end
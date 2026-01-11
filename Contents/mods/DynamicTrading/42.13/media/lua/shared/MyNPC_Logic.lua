-- ==============================================================================
-- MyNPC_Logic.lua
-- The "Controller": Manages the NPC's decisions and delegates specific tasks.
-- UPDATED: Hybrid Tick Rate. "Sliding" logic runs at 60Hz, "AI" logic runs at ~6Hz.
-- ==============================================================================

MyNPCLogic = MyNPCLogic or {}

-- 1. BEHAVIOR REGISTRY
MyNPCLogic.Behaviors = {} 

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

    local cell = getCell()
    if not cell then return end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return end
    
    -- Iterate BACKWARDS to prevent crashes if an NPC is despawned
    for i = zombieList:size() - 1, 0, -1 do
        local zombie = zombieList:get(i)
        
        if zombie and zombie:getModData().IsMyNPC then
            -- Wrapped in pcall to protect the loop from one bad NPC
            local success, err = pcall(function()
                MyNPCLogic.ProcessNPC(zombie)
            end)
            
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

function MyNPCLogic.ProcessNPC(zombie)
    local brain = MyNPC.GetBrain(zombie)
    if not brain then return end

    -- Always suppress sound
    suppressSound(zombie)

    local state = brain.state or "Stay"

    -- ==========================================================
    -- HYBRID TICK SYSTEM
    -- ==========================================================
    
    -- GROUP A: MANUAL MOVEMENT (GoTo, Flee)
    -- These must run EVERY FRAME for smooth sliding and to keep AI suppressed.
    if state == "GoTo" or state == "Flee" then
        MyNPCLogic.ExecuteBehavior(zombie, brain, state)
        return
    end

    -- GROUP B: VANILLA AI (Follow, Stay, Attack)
    -- These use the engine's pathfinder. Calling them every frame is bad.
    -- We throttle them to run only once every 10 ticks (approx 0.16s).
    
    -- Init timer if missing
    if not brain.tickTimer then brain.tickTimer = 0 end
    brain.tickTimer = brain.tickTimer + 1
    
    if brain.tickTimer >= 10 then
        brain.tickTimer = 0 -- Reset timer
        MyNPCLogic.ExecuteBehavior(zombie, brain, state)
    end
end

function MyNPCLogic.ExecuteBehavior(zombie, brain, state)
    -- A. Find the Master
    local master, dist = MyNPCLogic.GetClosestTarget(zombie)

    -- B. Check for Betrayal (Self Defense)
    -- We do this before executing the behavior logic
    MyNPCLogic.CheckForBetrayal(zombie, brain, master)
    
    -- If betrayal changed the state to Attack, update local var
    if brain.state ~= state then
        state = brain.state
    end

    -- C. Run the Behavior Function
    local behaviorFunc = MyNPCLogic.Behaviors[state]

    if behaviorFunc then
        behaviorFunc(zombie, brain, master, dist)
    else
        -- Fallback
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

    -- 1. Hostile Targeting
    if brain.isHostile then
        local player = zombie:getTarget()
        if player and instanceof(player, "Player") then
            return player, calculateDistance(zombie, player)
        end
    end

    -- 2. Master Targeting
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
    local attacker = zombie:getAttackedBy()
    
    if attacker and master and attacker == master then
        brain.state = "Attack" 
        brain.isHostile = true
        brain.tasks = {}
        
        print("[MyNPC] Betrayal! " .. brain.name .. " is attacking " .. master:getUsername())
        zombie:setAttackedBy(nil)
    end
end
-- ==============================================================================
-- DTNPC_Logic.lua
-- The "Controller": Manages the NPC's decisions and delegates specific tasks.
-- Build 42 Compatible. Runs on Server only in multiplayer.
-- ==============================================================================
DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

require "NPC/Behaviors/Behavior_GoTo"
require "NPC/Behaviors/Behavior_Attack"
require "NPC/Behaviors/Behavior_AttackRange"
require "NPC/Behaviors/Behavior_Flee"
require "NPC/Behaviors/Behavior_Follow"
require "NPC/Behaviors/Behavior_Guard" 

-- ==============================================================================
-- 2. HELPER UTILITIES
-- ==============================================================================

local function calculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end
    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end

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

function DTNPCLogic.OnTick()
    -- Run on both Client and Server, but only for Local (Owned) zombies
    
    local cell = getCell()
    if not cell then return end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return end
    
    for i = zombieList:size() - 1, 0, -1 do
        local zombie = zombieList:get(i)
        
        -- CRITICAL: Only run logic if we own the zombie (Authority)
        if zombie and zombie:isLocal() and zombie:getModData().IsDTNPC then
            local success, err = pcall(function()
                DTNPCLogic.ProcessNPC(zombie)
            end)
            
            if not success then 
                print("[DTNPC] Error processing NPC: " .. tostring(err))
            end
        end
    end
end

Events.OnTick.Add(DTNPCLogic.OnTick)

-- ==============================================================================
-- 4. DECISION MAKER
-- ==============================================================================

function DTNPCLogic.ProcessNPC(zombie)
    local brain = DTNPC.GetBrain(zombie)
    if not brain then return end

    suppressSound(zombie)

    local state = brain.state or "Stay"

    -- HIGH SPEED BEHAVIORS (Every Frame)
    if state == "GoTo" or state == "Flee" or state == "AttackRange" or state == "Follow" then
        DTNPCLogic.ExecuteBehavior(zombie, brain, state)
        return
    end

    -- THROTTLED BEHAVIORS (Every 10 ticks)
    if not brain.tickTimer then brain.tickTimer = 0 end
    brain.tickTimer = brain.tickTimer + 1
    
    if brain.tickTimer >= 10 then
        brain.tickTimer = 0
        DTNPCLogic.ExecuteBehavior(zombie, brain, state)
    end
end

function DTNPCLogic.ExecuteBehavior(zombie, brain, state)
    local master, dist = DTNPCLogic.GetClosestTarget(zombie)

    DTNPCLogic.CheckForBetrayal(zombie, brain, master)
    
    if brain.state ~= state then
        state = brain.state
    end

    local behaviorFunc = DTNPCLogic.Behaviors[state]

    if behaviorFunc then
        behaviorFunc(zombie, brain, master, dist)
    else
        if DTNPCLogic.Behaviors["Stay"] then
            DTNPCLogic.Behaviors["Stay"](zombie, brain, master, dist)
        end
    end
end

-- ==============================================================================
-- 5. TARGETING & EVENTS
-- ==============================================================================

function DTNPCLogic.GetClosestTarget(zombie)
    local brain = DTNPC.GetBrain(zombie)
    if not brain then return nil, 9999 end

    -- 1. Hostile Targeting
    if brain.isHostile then
        local player = zombie:getTarget()
        
        if player and instanceof(player, "IsoPlayer") then
            return player, calculateDistance(zombie, player)
        end
        
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
            local p = getSpecificPlayer(0)
            if p and p:getUsername() == brain.master then
                 return p, calculateDistance(zombie, p)
            end
        end
    end

    -- 2. Master Targeting (Friendly)
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
        
        local p = getSpecificPlayer(0)
        if p and p:getUsername() == brain.master then
             return p, calculateDistance(zombie, p)
        end
    end

    return nil, 9999
end

function DTNPCLogic.CheckForBetrayal(zombie, brain, master)
    local attacker = zombie:getAttackedBy()
    
    if attacker and master and attacker == master then
        brain.state = "Attack" 
        brain.isHostile = true
        brain.tasks = {}
        
        print("[DTNPC] Betrayal! " .. brain.name .. " is attacking " .. master:getUsername())
        zombie:setAttackedBy(nil)
    end
end

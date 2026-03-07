-- ==============================================================================
-- DTNPC_Logic.lua
-- The "Controller": Manages the NPC's decisions and delegates specific tasks.
-- FIXED: Added aggressive wander prevention for Stay state
-- Build 42 Compatible. Runs on Server only in multiplayer.
-- ==============================================================================
DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

-- Anchor stabilization tuning.
-- In SP, zombie movement jitter can cause repeated tiny drift corrections.
local ANCHOR_DRIFT_TOLERANCE = 1.5
local ANCHOR_SNAP_COOLDOWN_HOURS = 2 / 3600
local DTNPC_IDLE_STATE_COUNT = 3
local DTNPC_IDLE_CYCLE_TICKS = 240

-- Forward declarations used by ProcessNPC.
local isIdleCycleState
local resetIdleCycle
local updateIdleCycle

require "DT/V2/NPC/Behaviors/Behavior_GoTo"
require "DT/V2/NPC/Behaviors/Behavior_Attack"
require "DT/V2/NPC/Behaviors/Behavior_AttackRange"
require "DT/V2/NPC/Behaviors/Behavior_Flee"
require "DT/V2/NPC/Behaviors/Behavior_Follow"
require "DT/V2/NPC/Behaviors/Behavior_Guard" 
require "DT/V2/NPC/Behaviors/Behavior_Trade"

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
            -- print("[DTNPC-Logic] Processing Local NPC: " .. tostring(zombie:getModData().DTNPC_UUID)) 
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

    -- Tag DynamicTrading NPCs for AnimSet-based posture overrides.
    zombie:setVariable("DTNPC", true)
    if zombie:getVariableString("DTIdleState") == "" then
        zombie:setVariable("DTIdleState", "0")
    end

    local state = brain.state or "Stay"
    updateIdleCycle(zombie, brain, state)
    
    -- AGGRESSIVE WANDER PREVENTION
    -- Lock down zombies that should be stationary
    if state == "Stay" or state == "Guard" then
        zombie:setPath2(nil)
        zombie:setTarget(nil)
        
        -- Store anchor position if not set
        if not brain.anchorX then
            brain.anchorX = zombie:getX()
            brain.anchorY = zombie:getY()
            brain.anchorZ = zombie:getZ()
            if DTNPC_DEBUG_ANCHOR then
                print("[DTNPC] Set anchor for " .. (brain.name or "NPC") .. " at " .. math.floor(brain.anchorX) .. "," .. math.floor(brain.anchorY))
            end
        end
        
        -- Check if they've drifted from anchor
        local dx = math.abs(zombie:getX() - brain.anchorX)
        local dy = math.abs(zombie:getY() - brain.anchorY)
        local nowHours = getGameTime() and getGameTime():getWorldAgeHours() or 0
        local lastSnap = brain.anchorLastSnapTime or 0
        
        if (dx > ANCHOR_DRIFT_TOLERANCE or dy > ANCHOR_DRIFT_TOLERANCE)
            and ((nowHours - lastSnap) >= ANCHOR_SNAP_COOLDOWN_HOURS) then
            -- Snap back to anchor
            if DTNPC_DEBUG_ANCHOR then
                print("[DTNPC] NPC " .. (brain.name or "Unknown") .. " drifted from anchor. Snapping back.")
            end
            zombie:setX(brain.anchorX)
            zombie:setY(brain.anchorY)
            zombie:setZ(brain.anchorZ)
            brain.anchorLastSnapTime = nowHours
        end
    else
        -- Clear anchor when moving
        brain.anchorX = nil
        brain.anchorY = nil
        brain.anchorZ = nil
        brain.anchorLastSnapTime = nil
    end
    
    -- Track health for betrayal detection (ignores pushes/non-damaging hits)
    local currentHealth = zombie:getHealth()
    if not brain.lastHealth then brain.lastHealth = currentHealth end
    local wasDamaged = currentHealth < brain.lastHealth
    brain.lastHealth = currentHealth

    -- HIGH SPEED BEHAVIORS (Every Frame)
    if state == "GoTo" or state == "Flee" or state == "AttackRange" or state == "Follow" then
        DTNPCLogic.ExecuteBehavior(zombie, brain, state, wasDamaged)
        return
    end

    -- THROTTLED BEHAVIORS (Every 10 ticks)
    if not brain.tickTimer then brain.tickTimer = 0 end
    brain.tickTimer = brain.tickTimer + 1
    
    if brain.tickTimer >= 10 then
        brain.tickTimer = 0
        DTNPCLogic.ExecuteBehavior(zombie, brain, state, wasDamaged)
    end
end

function DTNPCLogic.ExecuteBehavior(zombie, brain, state, wasDamaged)
    local master, dist = DTNPCLogic.GetClosestTarget(zombie)

    DTNPCLogic.CheckForCombatInitiation(zombie, brain, master, wasDamaged)
    
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
    if brain.masterID or brain.master then
        local onlinePlayers = getOnlinePlayers()
        if onlinePlayers then
            for i = 0, onlinePlayers:size() - 1 do
                local p = onlinePlayers:get(i)
                if p and ((brain.masterID and p:getOnlineID() == brain.masterID) or (brain.master and p:getUsername() == brain.master)) then
                    return p, calculateDistance(zombie, p)
                end
            end
        end
        
        local p = getSpecificPlayer(0)
        if p and p:getUsername() == brain.master then
             return p, calculateDistance(zombie, p)
        end
        
        -- print("[DTNPC-Logic] Master not found for: " .. (brain.name or "NPC") .. " (Master: " .. tostring(brain.master) .. ")")
    end

    return nil, 9999
end

function DTNPCLogic.CheckForCombatInitiation(zombie, brain, master, wasDamaged)
    local attacker = zombie:getAttackedBy()
    
    -- Only initiate combat if damaged by a PLAYER (ignores pushes)
    if wasDamaged and attacker and instanceof(attacker, "IsoPlayer") then
        local isMaster = (master and attacker == master)
        
        -- If master betrayed us OR any other player attacked us
        if isMaster or not brain.isHostile then
            brain.state = "AttackRange" 
            brain.isHostile = true
            brain.tasks = {}
            
            local attackerName = attacker:getUsername() or "Unknown Player"
            print("[DTNPC] Combat Initiated! " .. brain.name .. " is attacking " .. attackerName)
            
            zombie:setTarget(attacker)
            zombie:setAttackedBy(nil)
        end
    end
end

isIdleCycleState = function(state)
    return state == "Stay" or state == "Guard" or state == "Trading"
end

resetIdleCycle = function(zombie, brain)
    brain.idleCycleCounter = 0
    brain.idleCycleIndex = 0
    zombie:setVariable("DTIdleState", "0")
end

updateIdleCycle = function(zombie, brain, state)
    if not isIdleCycleState(state) then
        resetIdleCycle(zombie, brain)
        return
    end

    if brain.idleCycleIndex == nil then brain.idleCycleIndex = 0 end
    if not brain.idleCycleCounter then brain.idleCycleCounter = 0 end

    local moving = zombie:isMoving() or (brain.isMovingState == true)
    if moving then
        resetIdleCycle(zombie, brain)
        return
    end

    brain.idleCycleCounter = brain.idleCycleCounter + 1
    if brain.idleCycleCounter >= DTNPC_IDLE_CYCLE_TICKS then
        brain.idleCycleCounter = 0
        brain.idleCycleIndex = (brain.idleCycleIndex + 1) % DTNPC_IDLE_STATE_COUNT
        zombie:setVariable("DTIdleState", tostring(brain.idleCycleIndex))
    end
end
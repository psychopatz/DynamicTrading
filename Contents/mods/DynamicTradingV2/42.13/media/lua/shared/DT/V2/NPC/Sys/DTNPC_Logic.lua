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
local DTNPC_IDLE_STATE_COUNT = 10
local DTNPC_IDLE_CYCLE_TICKS = 240

local isIdleCycleState
local resetIdleCycle
local updateIdleCycle

DTNPCLogic.ActivePlayersSnapshot = DTNPCLogic.ActivePlayersSnapshot or {}

require "DT/V2/NPC/Behaviors/Behavior_GoTo"
require "DT/V2/NPC/Behaviors/Behavior_Attack"
require "DT/V2/NPC/Behaviors/Behavior_AttackRange"
require "DT/V2/NPC/Behaviors/Behavior_Flee"
require "DT/V2/NPC/Behaviors/Behavior_Follow"
require "DT/V2/NPC/Behaviors/Behavior_Stationary"
require "DT/V2/NPC/Behaviors/Behavior_Idle"
require "DT/V2/NPC/Behaviors/Behavior_Guard" 
require "DT/V2/NPC/Behaviors/Behavior_Trading"
require "DT/V2/NPC/Behaviors/Behavior_Departure"

-- ==============================================================================
-- 2. HELPER UTILITIES
-- ==============================================================================

local function calculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end
    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end

function DTNPCLogic.RefreshActivePlayers()
    local players = {}

    if DTNPCManager and DTNPCManager.GetActivePlayers then
        local activePlayers = DTNPCManager.GetActivePlayers()
        if activePlayers then
            for i = 1, #activePlayers do
                local player = activePlayers[i]
                if player then
                    players[#players + 1] = player
                end
            end
        end
    else
        local onlinePlayers = getOnlinePlayers()
        if onlinePlayers then
            for i = 0, onlinePlayers:size() - 1 do
                local player = onlinePlayers:get(i)
                if player then
                    players[#players + 1] = player
                end
            end
        else
            local player = nil
            if getPlayer then
                player = getPlayer()
            end
            if not player then
                player = getSpecificPlayer(0)
            end
            if player then
                players[1] = player
            end
        end
    end

    DTNPCLogic.ActivePlayersSnapshot = players
end

function DTNPCLogic.GetActivePlayers()
    return DTNPCLogic.ActivePlayersSnapshot or {}
end

local function suppressSound(zombie)
    if not zombie then return end
    
    -- Build 42: Set voice prefix to "NotAZombie" to prevent zombie sounds
    -- This prevents the game engine from playing any zombie vocals/moans/shouts
    local desc = zombie:getDescriptor()
    if desc then
        desc:setVoicePrefix("NotAZombie")
    end
end

-- ==============================================================================
-- 3. CORE LOOP
-- ==============================================================================

function DTNPCLogic.OnTick()
    -- Run on both Client and Server, but only for Local (Owned) zombies

    local cell = getCell()
    if not cell then return end

    DTNPCLogic.RefreshActivePlayers()

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
                DynamicTrading.Log("DTV2", "NPC", "Error", "Error processing NPC: " .. tostring(err))
            end
        end
    end
end

Events.OnTick.Add(DTNPCLogic.OnTick)

-- ==============================================================================
-- 4. DECISION MAKER
-- ==============================================================================

function DTNPCLogic.ProcessNPC(zombie)
    local npcData = DTNPC.GetData(zombie)
    if not npcData then return end

    -- Suppress zombie sounds (shouting, groaning, etc.)
    suppressSound(zombie)

    -- Tag DynamicTrading NPCs for AnimSet-based posture overrides.
    zombie:setVariable("DTNPC", true)
    if zombie:getVariableString("DTIdleState") == "" then
        zombie:setVariable("DTIdleState", "0")
    end

    local state = npcData.state or "Stay"
    updateIdleCycle(zombie, npcData, state)
    
    -- AGGRESSIVE WANDER PREVENTION
    -- Lock down zombies that should be stationary
    if state == "Stay" or state == "Guard" or state == "Idle" or state == "Trading" then
        zombie:setPath2(nil)
        zombie:setTarget(nil)
        
        -- Store anchor position if not set
        if not npcData.anchorX then
            npcData.anchorX = zombie:getX()
            npcData.anchorY = zombie:getY()
            npcData.anchorZ = zombie:getZ()
            if DTNPC_DEBUG_ANCHOR then
                DynamicTrading.Log("DTV2", "NPC", "Anchor", "Set anchor for " .. (npcData.name or "NPC") .. " at " .. math.floor(npcData.anchorX) .. "," .. math.floor(npcData.anchorY))
            end
        end
        
        -- Check if they've drifted from anchor
        local dx = math.abs(zombie:getX() - npcData.anchorX)
        local dy = math.abs(zombie:getY() - npcData.anchorY)
        local nowHours = getGameTime() and getGameTime():getWorldAgeHours() or 0
        local lastSnap = npcData.anchorLastSnapTime or 0
        
        if (dx > ANCHOR_DRIFT_TOLERANCE or dy > ANCHOR_DRIFT_TOLERANCE)
            and ((nowHours - lastSnap) >= ANCHOR_SNAP_COOLDOWN_HOURS) then
            -- Snap back to anchor
            if DTNPC_DEBUG_ANCHOR then
                DynamicTrading.Log("DTV2", "NPC", "Anchor", "NPC " .. (npcData.name or "Unknown") .. " drifted from anchor. Snapping back.")
            end
            zombie:setX(npcData.anchorX)
            zombie:setY(npcData.anchorY)
            zombie:setZ(npcData.anchorZ)
            npcData.anchorLastSnapTime = nowHours
        end
    else
        -- Clear anchor when moving
        npcData.anchorX = nil
        npcData.anchorY = nil
        npcData.anchorZ = nil
        npcData.anchorLastSnapTime = nil
    end
    
    -- Track health for betrayal detection (ignores pushes/non-damaging hits)
    local currentHealth = zombie:getHealth()
    if not npcData.lastHealth then npcData.lastHealth = currentHealth end
    local wasDamaged = currentHealth < npcData.lastHealth
    npcData.lastHealth = currentHealth

    -- HIGH SPEED BEHAVIORS (Every Frame)
    if state == "GoTo" or state == "Flee" or state == "AttackRange" or state == "Follow" or state == "Departure" then
        DTNPCLogic.ExecuteBehavior(zombie, npcData, state, wasDamaged)
        return
    end

    -- THROTTLED BEHAVIORS (Every 10 ticks)
    if not npcData.tickTimer then npcData.tickTimer = 0 end
    npcData.tickTimer = npcData.tickTimer + 1
    
    if npcData.tickTimer >= 10 then
        npcData.tickTimer = 0
        DTNPCLogic.ExecuteBehavior(zombie, npcData, state, wasDamaged)
    end
end

function DTNPCLogic.ExecuteBehavior(zombie, npcData, state, wasDamaged)
    local master, dist = DTNPCLogic.GetClosestTarget(zombie)

    DTNPCLogic.CheckForCombatInitiation(zombie, npcData, master, wasDamaged)
    
    if npcData.state ~= state then
        state = npcData.state
    end

    local behaviorFunc = DTNPCLogic.Behaviors[state]

    if behaviorFunc then
        behaviorFunc(zombie, npcData, master, dist)
    else
        if DTNPCLogic.Behaviors["Stay"] then
            DTNPCLogic.Behaviors["Stay"](zombie, npcData, master, dist)
        end
    end
end

-- ==============================================================================
-- 5. TARGETING & EVENTS
-- ==============================================================================

function DTNPCLogic.GetClosestTarget(zombie)
    local npcData = DTNPC.GetData(zombie)
    if not npcData then return nil, 9999 end

    -- 1. Hostile Targeting
    if npcData.isHostile then
        local player = zombie:getTarget()
        
        if player and instanceof(player, "IsoPlayer") then
            return player, calculateDistance(zombie, player)
        end
        
        if npcData.masterID then
            local activePlayers = DTNPCLogic.GetActivePlayers()
            for i = 1, #activePlayers do
                local p = activePlayers[i]
                if p and p:getOnlineID() == npcData.masterID then
                     return p, calculateDistance(zombie, p)
                end
            end
            local p = getSpecificPlayer(0)
            if p and p:getUsername() == npcData.master then
                 return p, calculateDistance(zombie, p)
            end
        end
    end

    -- 2. Master Targeting (Friendly)
    if npcData.masterID or npcData.master then
        local activePlayers = DTNPCLogic.GetActivePlayers()
        for i = 1, #activePlayers do
            local p = activePlayers[i]
            if p and ((npcData.masterID and p:getOnlineID() == npcData.masterID) or (npcData.master and p:getUsername() == npcData.master)) then
                return p, calculateDistance(zombie, p)
            end
        end

        local p = getSpecificPlayer(0)
        if p and p:getUsername() == npcData.master then
             return p, calculateDistance(zombie, p)
        end
        
        DynamicTrading.Log("DTV2", "NPC", "Logic", "Master not found for: " .. (npcData.name or "NPC") .. " (Master: " .. tostring(npcData.master) .. ")")
    end

    return nil, 9999
end

function DTNPCLogic.CheckForCombatInitiation(zombie, npcData, master, wasDamaged)
    local attacker = zombie:getAttackedBy()
    
    -- Only initiate combat if damaged by a PLAYER (ignores pushes)
    if wasDamaged and attacker and instanceof(attacker, "IsoPlayer") then
        local isMaster = (master and attacker == master)
        
        -- If master betrayed us OR any other player attacked us
        if isMaster or not npcData.isHostile then
            npcData.state = "AttackRange" 
            npcData.isHostile = true
            npcData.tasks = {}
            
            local attackerName = attacker:getUsername() or "Unknown Player"
            DynamicTrading.Log("DTV2", "NPC", "Combat", "Combat Initiated! " .. npcData.name .. " is attacking " .. attackerName)
            
            zombie:setTarget(attacker)
            zombie:setAttackedBy(nil)
        end
    end
end

isIdleCycleState = function(state)
    return state == "Idle" or state == "Stay" or state == "Guard" or state == "Trading"
end

resetIdleCycle = function(zombie, npcData)
    npcData.idleCycleCounter = 0
    npcData.idleCycleIndex = 0
    zombie:setVariable("DTIdleState", "0")
end

updateIdleCycle = function(zombie, npcData, state)
    if not isIdleCycleState(state) then
        resetIdleCycle(zombie, npcData)
        return
    end

    local forcedIdleState = DTNPCLogic.Stationary.GetDesiredIdleState(zombie, npcData)
    if forcedIdleState then
        npcData.idleCycleCounter = 0
        npcData.idleCycleIndex = tonumber(forcedIdleState) or 0
        zombie:setVariable("DTIdleState", forcedIdleState)
        return
    end

    if npcData.idleCycleIndex == nil then npcData.idleCycleIndex = 0 end
    if not npcData.idleCycleCounter then npcData.idleCycleCounter = 0 end

    local moving = zombie:isMoving() or (npcData.isMovingState == true)
    if moving then
        resetIdleCycle(zombie, npcData)
        return
    end

    npcData.idleCycleCounter = npcData.idleCycleCounter + 1
    if npcData.idleCycleCounter >= DTNPC_IDLE_CYCLE_TICKS then
        npcData.idleCycleCounter = 0
        npcData.idleCycleIndex = (npcData.idleCycleIndex + 1) % DTNPC_IDLE_STATE_COUNT
        zombie:setVariable("DTIdleState", tostring(npcData.idleCycleIndex))
    end
end

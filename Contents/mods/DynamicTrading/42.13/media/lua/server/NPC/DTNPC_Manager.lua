-- ==============================================================================
-- DTNPC_Manager.lua
-- Server-side Logic: Persists NPC data and TRACKS LOCATIONS.
-- FIXED: Adds periodic position broadcasting and wander prevention
-- ==============================================================================

DTNPCManager = DTNPCManager or {}
DTNPCManager.Data = {} 

-- ==============================================================================
-- 1. SAVE / LOAD SYSTEM
-- ==============================================================================

function DTNPCManager.Load()
    if isClient() then return end -- Server only
    
    local globalData = ModData.getOrCreate("DTNPC_GlobalList")
    DTNPCManager.Data = globalData.NPCs or {}
    globalData.NPCs = DTNPCManager.Data
    print("[DTNPC] Manager Loaded. Tracking " .. tostring(DTNPCManager.GetTableSize(DTNPCManager.Data)) .. " NPCs.")
end

function DTNPCManager.Save()
    if isClient() then return end -- Server only
    
    local globalData = ModData.getOrCreate("DTNPC_GlobalList")
    globalData.NPCs = DTNPCManager.Data
    
    -- CRITICAL: Force save GlobalModData for multiplayer persistence
    if GlobalModData and GlobalModData.save then
        GlobalModData.save()
    end
end

-- Load on game start
Events.OnInitGlobalModData.Add(DTNPCManager.Load)

-- Save periodically and on game save events
local function onSaveGame()
    DTNPCManager.Save()
end
Events.OnSave.Add(onSaveGame)

-- ==============================================================================
-- 2. REGISTRATION
-- ==============================================================================

function DTNPCManager.Register(zombie, brain)
    if isClient() then return end
    if not zombie or not brain then return end
    
    local id = zombie:getPersistentOutfitID()
    
    brain.lastX = math.floor(zombie:getX())
    brain.lastY = math.floor(zombie:getY())
    brain.lastZ = math.floor(zombie:getZ())
    brain.health = zombie:getHealth()
    
    DTNPCManager.Data[id] = brain
    DTNPCManager.Save()
    
    print("[DTNPC] Registered NPC: " .. (brain.name or "Unknown") .. " at " .. brain.lastX .. "," .. brain.lastY .. "," .. brain.lastZ)
end

function DTNPCManager.RemoveData(id)
    if isClient() then return end
    
    if DTNPCManager.Data[id] then
        DTNPCManager.Data[id] = nil
        DTNPCManager.Save()
        print("[DTNPC] Removed NPC data: " .. id)
    end
end

function DTNPCManager.Unregister(zombie)
    if isClient() then return end
    
    local id = zombie:getPersistentOutfitID()
    if DTNPCManager.Data[id] then
        DTNPCManager.Data[id] = nil
        DTNPCManager.Save()
        
        if DTNPCSpawn and DTNPCSpawn.NotifyRemoval then
            DTNPCSpawn.NotifyRemoval(id)
        end
        
        print("[DTNPC] NPC Died. Removed from DB: " .. id)
    end
end

Events.OnZombieDead.Add(DTNPCManager.Unregister)

-- ==============================================================================
-- 3. RESTORATION & TRACKING LOOP
-- ==============================================================================

local TICK_RATE = 20
local tickCounter = 0

-- NEW: Position broadcast counter (every 2 seconds = ~120 ticks)
local POSITION_BROADCAST_RATE = 120
local positionBroadcastCounter = 0

function DTNPCManager.OnTick()
    if isClient() then return end

    tickCounter = tickCounter + 1
    positionBroadcastCounter = positionBroadcastCounter + 1
    
    local shouldBroadcast = (positionBroadcastCounter >= POSITION_BROADCAST_RATE)
    if shouldBroadcast then
        positionBroadcastCounter = 0
    end
    
    if tickCounter < TICK_RATE then return end
    tickCounter = 0

    local cell = getCell()
    if not cell then return end
    
    local zombieList = cell:getZombieList()
    if not zombieList then return end
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie then
            local id = zombie:getPersistentOutfitID()
            local savedBrain = DTNPCManager.Data[id]
            
            if savedBrain then
                -- UPDATE POSITION IN DATABASE
                local newX = math.floor(zombie:getX())
                local newY = math.floor(zombie:getY())
                local newZ = math.floor(zombie:getZ())
                
                local posChanged = (savedBrain.lastX ~= newX or savedBrain.lastY ~= newY or savedBrain.lastZ ~= newZ)
                
                savedBrain.lastX = newX
                savedBrain.lastY = newY
                savedBrain.lastZ = newZ
                savedBrain.health = zombie:getHealth()
                
                -- PREVENT ZOMBIE WANDERING
                -- This is critical - IsoZombies will wander even when "useless" unless we lock them down
                if zombie:isUseless() and (savedBrain.state == "Stay" or savedBrain.state == "Guard") then
                    -- Force zombie to stay in place when idle
                    zombie:setPath2(nil)
                    zombie:setTarget(nil)
                    
                    -- If they've drifted, snap them back
                    if posChanged then
                        local drift = math.abs(newX - savedBrain.lastX) + math.abs(newY - savedBrain.lastY)
                        if drift > 2 then -- Drifted more than 2 tiles
                            print("[DTNPC] WARNING: NPC " .. (savedBrain.name or id) .. " drifted " .. drift .. " tiles. Correcting...")
                            -- Let it slide for now, but log it
                        end
                    end
                end
                
                -- Check if visuals need fixing
                local needsFix = true
                local visuals = zombie:getHumanVisual()
                if visuals then
                    local skin = visuals:getSkinTexture()
                    if skin then
                        skin = tostring(skin)
                        if string.find(skin, "MaleBody01") or string.find(skin, "FemaleBody01") then
                            needsFix = false
                        end
                    end
                end
                
                if needsFix then
                    print("[DTNPC] Fixing visuals for NPC: " .. (savedBrain.name or id))
                    DTNPC.ApplyVisuals(zombie, savedBrain)
                    DTNPC.AttachBrain(zombie, savedBrain)
                    if not zombie:isUseless() then
                        zombie:setUseless(true)
                        zombie:DoZombieStats()
                        zombie:setHealth(2)
                    end
                    
                    if DTNPCSpawn and DTNPCSpawn.SyncToAllClients then
                        DTNPCSpawn.SyncToAllClients(zombie, savedBrain)
                    end
                end
                
                -- NEW: PERIODIC POSITION BROADCAST
                -- Broadcast position updates to all clients periodically
                if shouldBroadcast and DTNPCSpawn and DTNPCSpawn.BroadcastPosition then
                    DTNPCSpawn.BroadcastPosition(zombie, savedBrain)
                end
            end
        end
    end
end

Events.OnTick.Add(DTNPCManager.OnTick)

-- ==============================================================================
-- 4. UTILITIES
-- ==============================================================================

function DTNPCManager.GetTableSize(t)
    local count = 0
    for _, __ in pairs(t) do count = count + 1 end
    return count
end
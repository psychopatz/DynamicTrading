-- ==============================================================================
-- DTNPC_Manager.lua
-- Server-side Logic: Persists NPC data and TRACKS LOCATIONS.
-- FIXED: Prevents duplicate NPCs and enforces unique IDs
-- ==============================================================================

DTNPCManager = DTNPCManager or {}
DTNPCManager.Data = {} 
DTNPCManager.PendingRegistrations = {} -- Track in-progress registrations

-- ==============================================================================
-- 1. SAVE / LOAD SYSTEM
-- ==============================================================================

function DTNPCManager.Load()
    if isClient() then return end
    
    local globalData = ModData.getOrCreate("DTNPC_GlobalList")
    DTNPCManager.Data = globalData.NPCs or {}
    globalData.NPCs = DTNPCManager.Data
    
    -- CLEANUP: Remove duplicates on load
    local seen = {}
    local toRemove = {}
    
    for id, brain in pairs(DTNPCManager.Data) do
        -- Check if this brain instance was already seen
        local key = brain.name .. "_" .. (brain.lastX or 0) .. "_" .. (brain.lastY or 0)
        
        if seen[key] then
            -- Duplicate found! Keep the one with higher health or more recent data
            local existing = seen[key]
            local existingBrain = DTNPCManager.Data[existing]
            
            if not existingBrain or (brain.health or 0) > (existingBrain.health or 0) then
                -- This one is better, remove the old one
                table.insert(toRemove, existing)
                seen[key] = id
                print("[DTNPC] Duplicate detected. Keeping ID: " .. id .. ", removing: " .. existing)
            else
                -- Keep the existing one, remove this one
                table.insert(toRemove, id)
                print("[DTNPC] Duplicate detected. Keeping ID: " .. existing .. ", removing: " .. id)
            end
        else
            seen[key] = id
        end
    end
    
    -- Remove duplicates
    for _, id in ipairs(toRemove) do
        DTNPCManager.Data[id] = nil
    end
    
    if #toRemove > 0 then
        print("[DTNPC] Removed " .. #toRemove .. " duplicate NPCs on load")
        DTNPCManager.Save()
    end
    
    print("[DTNPC] Manager Loaded. Tracking " .. tostring(DTNPCManager.GetTableSize(DTNPCManager.Data)) .. " NPCs.")
end

function DTNPCManager.Save()
    if isClient() then return end
    
    local globalData = ModData.getOrCreate("DTNPC_GlobalList")
    globalData.NPCs = DTNPCManager.Data
    
    if GlobalModData and GlobalModData.save then
        GlobalModData.save()
    end
end

Events.OnInitGlobalModData.Add(DTNPCManager.Load)

local function onSaveGame()
    DTNPCManager.Save()
end
Events.OnSave.Add(onSaveGame)

-- ==============================================================================
-- 2. REGISTRATION WITH DUPLICATE PREVENTION
-- ==============================================================================

function DTNPCManager.Register(zombie, brain)
    if isClient() then return end
    if not zombie or not brain then return end
    
    local id = zombie:getPersistentOutfitID()
    
    -- CRITICAL FIX: Check if already being registered
    if DTNPCManager.PendingRegistrations[id] then
        print("[DTNPC] WARNING: Registration for " .. id .. " already in progress. Skipping duplicate.")
        return
    end
    
    -- CRITICAL FIX: Check if this exact NPC already exists
    if DTNPCManager.Data[id] then
        local existing = DTNPCManager.Data[id]
        
        -- If same name and roughly same position, it's likely a duplicate spawn attempt
        local dx = math.abs((existing.lastX or 0) - zombie:getX())
        local dy = math.abs((existing.lastY or 0) - zombie:getY())
        
        if existing.name == brain.name and dx < 5 and dy < 5 then
            print("[DTNPC] WARNING: NPC " .. brain.name .. " (ID: " .. id .. ") already registered. Updating instead of creating duplicate.")
            -- Just update position and health
            existing.lastX = math.floor(zombie:getX())
            existing.lastY = math.floor(zombie:getY())
            existing.lastZ = math.floor(zombie:getZ())
            existing.health = zombie:getHealth()
            DTNPCManager.Save()
            return
        end
    end
    
    -- Mark as pending
    DTNPCManager.PendingRegistrations[id] = true
    
    -- Set position data
    brain.lastX = math.floor(zombie:getX())
    brain.lastY = math.floor(zombie:getY())
    brain.lastZ = math.floor(zombie:getZ())
    brain.health = zombie:getHealth()
    brain.registeredTime = os.time() -- Track when registered
    
    -- Register
    DTNPCManager.Data[id] = brain
    DTNPCManager.Save()
    
    -- Clear pending flag
    DTNPCManager.PendingRegistrations[id] = nil
    
    print("[DTNPC] Registered NPC: " .. (brain.name or "Unknown") .. " (ID: " .. id .. ") at " .. brain.lastX .. "," .. brain.lastY .. "," .. brain.lastZ)
end

function DTNPCManager.RemoveData(id)
    if isClient() then return end
    
    if DTNPCManager.Data[id] then
        DTNPCManager.Data[id] = nil
        DTNPCManager.PendingRegistrations[id] = nil
        DTNPCManager.Save()
        print("[DTNPC] Removed NPC data: " .. id)
    end
end

function DTNPCManager.Unregister(zombie)
    if isClient() then return end
    
    local id = zombie:getPersistentOutfitID()
    if DTNPCManager.Data[id] then
        DTNPCManager.Data[id] = nil
        DTNPCManager.PendingRegistrations[id] = nil
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
                -- Update position
                local newX = math.floor(zombie:getX())
                local newY = math.floor(zombie:getY())
                local newZ = math.floor(zombie:getZ())
                
                local posChanged = (savedBrain.lastX ~= newX or savedBrain.lastY ~= newY or savedBrain.lastZ ~= newZ)
                
                savedBrain.lastX = newX
                savedBrain.lastY = newY
                savedBrain.lastZ = newZ
                savedBrain.health = zombie:getHealth()
                
                -- Prevent wandering
                if zombie:isUseless() and (savedBrain.state == "Stay" or savedBrain.state == "Guard") then
                    zombie:setPath2(nil)
                    zombie:setTarget(nil)
                    
                    if posChanged then
                        local drift = math.abs(newX - savedBrain.lastX) + math.abs(newY - savedBrain.lastY)
                        if drift > 2 then
                            print("[DTNPC] WARNING: NPC " .. (savedBrain.name or id) .. " drifted " .. drift .. " tiles.")
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
                    
                    local modData = zombie:getModData()
                    modData.DTNPCVisualID = savedBrain.visualID
                    
                    if not zombie:isUseless() then
                        zombie:setUseless(true)
                        zombie:DoZombieStats()
                        zombie:setHealth(2)
                    end
                    
                    zombie:resetModelNextFrame()
                    
                    if DTNPCSpawn and DTNPCSpawn.SyncToAllClients then
                        DTNPCSpawn.SyncToAllClients(zombie, savedBrain)
                    end
                end
                
                -- Periodic position broadcast
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
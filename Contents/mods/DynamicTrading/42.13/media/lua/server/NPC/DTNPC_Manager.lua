-- ==============================================================================
-- DTNPC_Manager.lua
-- Server-side Logic: Persists NPC data and TRACKS LOCATIONS.
-- Uses GlobalModData.save() for multiplayer persistence.
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
    
    DTNPCManager.Data[id] = brain
    DTNPCManager.Save()
end

function DTNPCManager.RemoveData(id)
    if isClient() then return end
    
    if DTNPCManager.Data[id] then
        DTNPCManager.Data[id] = nil
        DTNPCManager.Save()
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
-- 3. RESTORATION & ENSURE NPC STATUS
-- ==============================================================================

function DTNPCManager.EnsureNPC(zombie, brain)
    if not zombie or not brain then return end
    if isClient() then return end

    -- Ensure brain has a visualID (for NPCs spawned before this update)
    if not brain.visualID then
        brain.visualID = ZombRand(1000000)
    end

    local modData = zombie:getModData()
    
    -- Check if initialization is needed
    local needsFix = false
    if not modData.IsDTNPC then needsFix = true end
    if not zombie:isUseless() then needsFix = true end
    
    -- Also ensure visuals are applied (this helps if they load "naked")
    if needsFix or not modData.LastVisualID or modData.LastVisualID ~= brain.visualID then
        DTNPC.ApplyVisuals(zombie, brain)
        DTNPC.AttachBrain(zombie, brain)
        
        -- Override LastVisualID in ModData to sync to clients
        modData.LastVisualID = brain.visualID
        
        zombie:setUseless(true)
        zombie:DoZombieStats()
        zombie:setHealth(1.5)
        
        if DTNPCSpawn and DTNPCSpawn.SyncToAllClients then
            DTNPCSpawn.SyncToAllClients(zombie, brain)
        end
        
        -- print("[DTNPC] Re-initialized NPC: " .. tostring(brain.name))
    end
end

local function onObjectAdded(obj)
    if not isServer() then return end
    if not instanceof(obj, "IsoZombie") then return end
    
    local id = obj:getPersistentOutfitID()
    local brain = DTNPCManager.Data[id]
    if brain then
        DTNPCManager.EnsureNPC(obj, brain)
    end
end
Events.OnObjectAdded.Add(onObjectAdded)


-- ==============================================================================
-- 3. RESTORATION & TRACKING LOOP
-- ==============================================================================

local TICK_RATE = 20
local tickCounter = 0

function DTNPCManager.OnTick()
    if isClient() then return end

    tickCounter = tickCounter + 1
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
                savedBrain.lastX = math.floor(zombie:getX())
                savedBrain.lastY = math.floor(zombie:getY())
                savedBrain.lastZ = math.floor(zombie:getZ())
                
                DTNPCManager.EnsureNPC(zombie, savedBrain)
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

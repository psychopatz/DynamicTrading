-- ==============================================================================
-- DTNPC_Manager.lua
-- Server-side Logic: Persists NPC data and TRACKS LOCATIONS.
-- FIXED: Use persistent UUID instead of outfit ID to prevent duplicates
-- ==============================================================================

DTNPCManager = DTNPCManager or {}
DTNPCManager.Data = {} 
DTNPCManager.PendingRegistrations = {}
DTNPCManager.OutfitIDToUUID = {} -- Maps current outfit IDs to persistent UUIDs

-- ==============================================================================
-- 1. SAVE / LOAD SYSTEM
-- ==============================================================================

function DTNPCManager.Load()
    if isClient() then return end
    
    local globalData = ModData.getOrCreate("DTNPC_GlobalList")
    DTNPCManager.Data = globalData.NPCs or {}
    globalData.NPCs = DTNPCManager.Data
    
    -- Rebuild outfit ID mapping
    DTNPCManager.OutfitIDToUUID = {}
    for uuid, brain in pairs(DTNPCManager.Data) do
        if brain.currentOutfitID then
            DTNPCManager.OutfitIDToUUID[brain.currentOutfitID] = uuid
        end
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
-- 2. UUID UTILITIES
-- ==============================================================================

function DTNPCManager.GenerateUUID()
    -- Simple UUID generation
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and ZombRand(0, 16) or ZombRand(8, 12)
        return string.format('%x', v)
    end)
end

function DTNPCManager.GetUUIDFromOutfitID(outfitID)
    return DTNPCManager.OutfitIDToUUID[outfitID]
end

function DTNPCManager.GetUUIDFromZombie(zombie)
    if not zombie then return nil end
    
    -- First check modData for UUID
    local modData = zombie:getModData()
    if modData.DTNPC_UUID then
        return modData.DTNPC_UUID
    end
    
    -- Fallback: check outfit ID mapping
    local outfitID = zombie:getPersistentOutfitID()
    return DTNPCManager.GetUUIDFromOutfitID(outfitID)
end

-- ==============================================================================
-- 3. REGISTRATION WITH UUID SYSTEM
-- ==============================================================================

function DTNPCManager.Register(zombie, brain)
    if isClient() then return end
    if not zombie or not brain then return end
    
    local outfitID = zombie:getPersistentOutfitID()
    
    -- Get or create UUID
    local uuid = brain.uuid
    if not uuid then
        -- Check if this zombie already has a UUID in modData
        local modData = zombie:getModData()
        uuid = modData.DTNPC_UUID
        
        if not uuid then
            -- Check outfit ID mapping (in case of respawn)
            uuid = DTNPCManager.GetUUIDFromOutfitID(outfitID)
            
            if not uuid then
                -- Brand new NPC, generate UUID
                uuid = DTNPCManager.GenerateUUID()
                print("[DTNPC] Generated new UUID for NPC: " .. (brain.name or "Unknown") .. " - " .. uuid)
            else
                print("[DTNPC] Found existing UUID from outfit mapping: " .. uuid)
            end
        else
            print("[DTNPC] Found UUID in zombie modData: " .. uuid)
        end
        
        brain.uuid = uuid
    end
    
    -- Store UUID in zombie modData for future lookups
    local modData = zombie:getModData()
    modData.DTNPC_UUID = uuid
    
    -- Check for duplicate registration
    if DTNPCManager.PendingRegistrations[uuid] then
        print("[DTNPC] WARNING: Registration for UUID " .. uuid .. " already in progress. Skipping duplicate.")
        return
    end
    
    -- Update outfit ID mapping
    DTNPCManager.OutfitIDToUUID[outfitID] = uuid
    
    DTNPCManager.PendingRegistrations[uuid] = true
    
    -- Update brain data
    brain.currentOutfitID = outfitID
    brain.lastX = math.floor(zombie:getX())
    brain.lastY = math.floor(zombie:getY())
    brain.lastZ = math.floor(zombie:getZ())
    brain.health = zombie:getHealth()
    brain.registeredTime = os.time()
    
    -- Store in database by UUID
    DTNPCManager.Data[uuid] = brain
    DTNPCManager.Save()
    
    DTNPCManager.PendingRegistrations[uuid] = nil
    
    print("[DTNPC] Registered NPC: " .. (brain.name or "Unknown") .. " (UUID: " .. uuid .. ", OutfitID: " .. outfitID .. ") at " .. brain.lastX .. "," .. brain.lastY .. "," .. brain.lastZ)
end

function DTNPCManager.RemoveData(uuid)
    if isClient() then return end
    
    if DTNPCManager.Data[uuid] then
        local brain = DTNPCManager.Data[uuid]
        
        -- Remove from outfit mapping
        if brain.currentOutfitID then
            DTNPCManager.OutfitIDToUUID[brain.currentOutfitID] = nil
        end
        
        -- Remove from database
        DTNPCManager.Data[uuid] = nil
        DTNPCManager.PendingRegistrations[uuid] = nil
        DTNPCManager.Save()
        
        print("[DTNPC] Removed NPC data: " .. uuid)
        
        -- Broadcast removal to all clients
        if DTNPCSpawn and DTNPCSpawn.NotifyRemoval then
            DTNPCSpawn.NotifyRemoval(uuid, brain.currentOutfitID)
        end
    end
end

function DTNPCManager.Unregister(zombie)
    if isClient() then return end
    
    local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
    
    if uuid and DTNPCManager.Data[uuid] then
        print("[DTNPC] NPC Died: " .. uuid)
        DTNPCManager.RemoveData(uuid)
    else
        -- Fallback: try outfit ID
        local outfitID = zombie:getPersistentOutfitID()
        local fallbackUUID = DTNPCManager.GetUUIDFromOutfitID(outfitID)
        if fallbackUUID and DTNPCManager.Data[fallbackUUID] then
            print("[DTNPC] NPC Died (fallback lookup): " .. fallbackUUID)
            DTNPCManager.RemoveData(fallbackUUID)
        end
    end
end

Events.OnZombieDead.Add(DTNPCManager.Unregister)

-- ==============================================================================
-- 4. RESPAWN SYSTEM
-- ==============================================================================

function DTNPCManager.CheckForRespawn(brain, uuid)
    if not brain or not brain.lastX or not brain.lastY then return end
    
    local onlinePlayers = getOnlinePlayers()
    if not onlinePlayers then return end
    
    local RESPAWN_RANGE = 50
    
    for i = 0, onlinePlayers:size() - 1 do
        local player = onlinePlayers:get(i)
        if player then
            local dx = player:getX() - brain.lastX
            local dy = player:getY() - brain.lastY
            local dz = player:getZ() - (brain.lastZ or 0)
            
            if math.abs(dz) == 0 and math.sqrt(dx*dx + dy*dy) < RESPAWN_RANGE then
                -- Check if zombie exists by UUID
                local zombie = DTNPCSpawn.FindZombieByUUID(uuid)
                
                if not zombie then
                    print("[DTNPC] Respawning NPC: " .. (brain.name or uuid) .. " near player " .. player:getUsername())
                    DTNPCSpawn.RespawnNPC(brain, uuid)
                    return true
                end
            end
        end
    end
    
    return false
end

-- ==============================================================================
-- 5. RESTORATION & TRACKING LOOP
-- ==============================================================================

local TICK_RATE = 20
local tickCounter = 0

local POSITION_BROADCAST_RATE = 120
local positionBroadcastCounter = 0

local RESPAWN_CHECK_RATE = 300
local respawnCheckCounter = 0

function DTNPCManager.OnTick()
    if isClient() then return end

    tickCounter = tickCounter + 1
    positionBroadcastCounter = positionBroadcastCounter + 1
    respawnCheckCounter = respawnCheckCounter + 1
    
    local shouldBroadcast = (positionBroadcastCounter >= POSITION_BROADCAST_RATE)
    if shouldBroadcast then
        positionBroadcastCounter = 0
    end
    
    local shouldCheckRespawn = (respawnCheckCounter >= RESPAWN_CHECK_RATE)
    if shouldCheckRespawn then
        respawnCheckCounter = 0
    end
    
    -- Respawn check
    if shouldCheckRespawn then
        for uuid, brain in pairs(DTNPCManager.Data) do
            DTNPCManager.CheckForRespawn(brain, uuid)
        end
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
            local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
            
            if uuid then
                local savedBrain = DTNPCManager.Data[uuid]
                
                if savedBrain then
                    -- Update outfit ID mapping in case it changed
                    local currentOutfitID = zombie:getPersistentOutfitID()
                    if savedBrain.currentOutfitID ~= currentOutfitID then
                        -- Outfit ID changed (respawn), update mapping
                        if savedBrain.currentOutfitID then
                            DTNPCManager.OutfitIDToUUID[savedBrain.currentOutfitID] = nil
                        end
                        DTNPCManager.OutfitIDToUUID[currentOutfitID] = uuid
                        savedBrain.currentOutfitID = currentOutfitID
                        print("[DTNPC] Updated outfit ID for " .. (savedBrain.name or uuid) .. ": " .. currentOutfitID)
                    end
                    
                    -- Update position
                    local newX = math.floor(zombie:getX())
                    local newY = math.floor(zombie:getY())
                    local newZ = math.floor(zombie:getZ())
                    
                    savedBrain.lastX = newX
                    savedBrain.lastY = newY
                    savedBrain.lastZ = newZ
                    savedBrain.health = zombie:getHealth()
                    
                    -- Prevent wandering
                    if zombie:isUseless() and (savedBrain.state == "Stay" or savedBrain.state == "Guard") then
                        zombie:setPath2(nil)
                        zombie:setTarget(nil)
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
                        print("[DTNPC] Fixing visuals for NPC: " .. (savedBrain.name or uuid))
                        DTNPC.ApplyVisuals(zombie, savedBrain)
                        DTNPC.AttachBrain(zombie, savedBrain)
                        
                        local modData = zombie:getModData()
                        modData.DTNPCVisualID = savedBrain.visualID
                        modData.DTNPC_UUID = uuid
                        
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
end

Events.OnTick.Add(DTNPCManager.OnTick)

-- ==============================================================================
-- 6. UTILITIES
-- ==============================================================================

function DTNPCManager.GetTableSize(t)
    local count = 0
    for _, __ in pairs(t) do count = count + 1 end
    return count
end
-- ==============================================================================
-- DTNPC_Manager.lua
-- Server-side Logic: Persists NPC data and TRACKS LOCATIONS.
-- FIXED: Use persistent UUID instead of outfit ID to prevent duplicates
-- ==============================================================================

DTNPCManager = DTNPCManager or {}
DTNPCManager.Data = {} -- The Registry (lightweight)
DTNPCManager.ActiveBrains = {} -- Cache for full brains of manifested NPCs
DTNPCManager.PendingRegistrations = {}
DTNPCManager.OutfitIDToUUID = {} -- Maps current outfit IDs to persistent UUIDs

-- ==============================================================================
-- 1. SAVE / LOAD SYSTEM
-- ==============================================================================

require "DynamicTrading_Roster"

function DTNPCManager.Load()
    if isClient() then return end
    
    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData then
        DynamicTrading_Roster.Init()
        rosterData = ModData.get("DynamicTrading_Roster")
    end
    
    DTNPCManager.Data = rosterData.Souls or {}
    
    -- Rebuild outfit ID mapping
    DTNPCManager.OutfitIDToUUID = {}
    for uuid, soul in pairs(DTNPCManager.Data) do
        -- A soul in Roster has a 'brain' field containing visuals and state
        local brain = soul.brain or soul
        if brain.currentOutfitID then
            DTNPCManager.OutfitIDToUUID[brain.currentOutfitID] = uuid
        end
    end
    
    print("[DTNPC] Manager Unified with Roster. Tracking " .. tostring(DTNPCManager.GetTableSize(DTNPCManager.Data)) .. " souls.")
end

function DTNPCManager.Save()
    if isClient() then return end
    -- ModData.transmit for the Roster key handles the actual transmission
    ModData.transmit("DynamicTrading_Roster")
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
    DynamicTrading_Roster.SaveSoul(uuid, brain)
    DTNPCManager.ActiveBrains[uuid] = brain -- Keep in cache since it's active
    
    DTNPCManager.PendingRegistrations[uuid] = nil
    
    print("[DTNPC] Registered NPC: " .. (brain.name or "Unknown") .. " (UUID: " .. uuid .. ", OutfitID: " .. outfitID .. ") at " .. brain.lastX .. "," .. brain.lastY .. "," .. brain.lastZ)
end

function DTNPCManager.RemoveData(uuid)
    if isClient() then return end
    
    local soulRegistry = DTNPCManager.Data[uuid]
    if soulRegistry then
        -- Remove from outfit mapping
        if soulRegistry.currentOutfitID then
            DTNPCManager.OutfitIDToUUID[soulRegistry.currentOutfitID] = nil
        end
        
        -- Remove from Roster (Handles individual deletion)
        DynamicTrading_Roster.RemoveSoul(soulRegistry.factionID, 1) -- Note: this removes A soul, we need internal logic to remove SPECIFIC uuid if we go that deep
        -- For now, let's manually clean up if Roster.RemoveSoul doesn't support specific UUID
        local rosterData = ModData.get("DynamicTrading_Roster")
        rosterData.Souls[uuid] = nil
        DTNPCManager.Data[uuid] = nil
        DTNPCManager.ActiveBrains[uuid] = nil
        if ModData.remove then ModData.remove("DTSOUL_" .. uuid) end
        
        DynamicTrading_Roster.Save()
        
        print("[DTNPC] Removed NPC data: " .. uuid)
        
        -- Broadcast removal to all clients
        if DTNPCSpawn and DTNPCSpawn.NotifyRemoval then
            DTNPCSpawn.NotifyRemoval(uuid, soulRegistry.currentOutfitID)
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
            local targetX = brain.lastX or (brain.homeCoords and brain.homeCoords.x)
            local targetY = brain.lastY or (brain.homeCoords and brain.homeCoords.y)
            local targetZ = brain.lastZ or (brain.homeCoords and brain.homeCoords.z) or 0
            
            if not targetX or not targetY then return false end

            local dx = player:getX() - targetX
            local dy = player:getY() - targetY
            local dz = player:getZ() - targetZ
            
            if math.abs(dz) <= 1 and math.sqrt(dx*dx + dy*dy) < RESPAWN_RANGE then
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
                local registry = DTNPCManager.Data[uuid]
                
                if registry then
                    -- Lazy Load Brain if not in cache
                    local brain = DTNPCManager.ActiveBrains[uuid]
                    if not brain then
                        brain = DynamicTrading_Roster.GetSoul(uuid)
                        DTNPCManager.ActiveBrains[uuid] = brain
                    end
                    
                    if brain then
                        -- Update outfit ID mapping in case it changed
                        local currentOutfitID = zombie:getPersistentOutfitID()
                        if brain.currentOutfitID ~= currentOutfitID then
                            -- Outfit ID changed (respawn), update mapping
                            if brain.currentOutfitID then
                                DTNPCManager.OutfitIDToUUID[brain.currentOutfitID] = nil
                            end
                            DTNPCManager.OutfitIDToUUID[currentOutfitID] = uuid
                            brain.currentOutfitID = currentOutfitID
                            print("[DTNPC] Updated outfit ID for " .. (brain.name or uuid) .. ": " .. currentOutfitID)
                        end
                        
                        -- Update position
                        local newX = math.floor(zombie:getX())
                        local newY = math.floor(zombie:getY())
                        local newZ = math.floor(zombie:getZ())
                        
                        brain.lastX = newX
                        brain.lastY = newY
                        brain.lastZ = newZ
                        brain.health = zombie:getHealth()
                        
                        -- Periodically persist brain data
                        if tickCounter == 0 then
                            DynamicTrading_Roster.SaveSoul(uuid, brain)
                        end

                        -- Prevent wandering
                        if zombie:isUseless() and (brain.state == "Stay" or brain.state == "Guard") then
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
                            print("[DTNPC] Fixing visuals for NPC: " .. (brain.name or uuid))
                            DTNPC.ApplyVisuals(zombie, brain)
                            DTNPC.AttachBrain(zombie, brain)
                            
                            local modData = zombie:getModData()
                            modData.DTNPCVisualID = brain.visualID
                            modData.DTNPC_UUID = uuid
                            
                            if not zombie:isUseless() then
                                zombie:setUseless(true)
                                zombie:DoZombieStats()
                                zombie:setHealth(2)
                            end
                            
                            zombie:resetModelNextFrame()
                            
                            if DTNPCSpawn and DTNPCSpawn.SyncToAllClients then
                                DTNPCSpawn.SyncToAllClients(zombie, brain)
                            end
                        end
                        
                        -- Periodic position broadcast
                        if shouldBroadcast and DTNPCSpawn and DTNPCSpawn.BroadcastPosition then
                            DTNPCSpawn.BroadcastPosition(zombie, brain)
                        end
                    end
                end
            end
        end
    end
    
    -- Cleanup Cache: If no zombie is using the brain, eventually remove from memory
    -- Simple check: if tickCounter == 0, check which cached brains are actually manifested
    if tickCounter == 0 then
        local manifested = {}
        for i = 0, zombieList:size() - 1 do
            local z = zombieList:get(i)
            local zid = DTNPCManager.GetUUIDFromZombie(z)
            if zid then manifested[zid] = true end
        end
        
        for uuid, _ in pairs(DTNPCManager.ActiveBrains) do
            if not manifested[uuid] then
                DTNPCManager.ActiveBrains[uuid] = nil
                -- print("[DTNPC] Purged inactive brain from cache: " .. uuid)
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
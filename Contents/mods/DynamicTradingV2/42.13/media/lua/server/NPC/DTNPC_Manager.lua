-- ==============================================================================
-- DTNPC_Manager.lua
-- Server-side Logic: Persists NPC data and TRACKS LOCATIONS.
-- FIXED: Use persistent UUID instead of outfit ID to prevent duplicates
-- ==============================================================================

DTNPCManager = DTNPCManager or {}
DTNPCManager.Data = {} 
DTNPCManager.PendingRegistrations = {}
DTNPCManager.OutfitIDToUUID = {} -- Maps current outfit IDs to persistent UUIDs

require "Faction/TradingSys/DynamicTrading_Roster" -- V2 Roster Bridge

-- Helper for SP/MP Compatibility
function DTNPCManager.GetActivePlayers()
    local players = {}
    if not isServer() and not isClient() then
         -- Single Player
         local p = getSpecificPlayer(0)
         if p then table.insert(players, p) end
    else
         -- Dedicated Server / Host
         local online = getOnlinePlayers()
         if online then
             for i=0, online:size()-1 do
                 local p = online:get(i)
                 if p then table.insert(players, p) end
             end
         end
    end
    return players
end

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

-- ==============================================================================
-- 1. SAVE / LOAD SYSTEM
-- ==============================================================================

function DTNPCManager.Load()
    -- if isClient() then return end -- REMOVED for Single Player Support
    
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
    -- if isClient() then return end -- REMOVED for SP Support
    
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
    -- if isClient() then return end -- REMOVED for SP Support
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

function DTNPCManager.RemoveData(uuid, status, returnTime, returnStatus)
    -- if isClient() then return end -- REMOVED for SP Support
    
    if DTNPCManager.Data[uuid] then
        local brain = DTNPCManager.Data[uuid]
        
        -- Remove from outfit mapping
        if brain.currentOutfitID then
            DTNPCManager.OutfitIDToUUID[brain.currentOutfitID] = nil
        end
        
        -- Update persistent status in Roster
        if DynamicTrading_Roster and status then
            DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
        end

        -- Remove from database
        DTNPCManager.Data[uuid] = nil
        DTNPCManager.PendingRegistrations[uuid] = nil
        DTNPCManager.Save()
        
        print("[DTNPC] Removed NPC data: " .. (brain.name or uuid) .. " (Status: " .. (status or "Removed") .. ")")
        
        -- Broadcast removal to all clients
        if DTNPCSpawn and DTNPCSpawn.NotifyRemoval then
            DTNPCSpawn.NotifyRemoval(uuid, brain.currentOutfitID, brain.name)
        end
    end
end

function DTNPCManager.Unregister(zombie)
    -- if isClient() then return end -- REMOVED for SP Support
    
    local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
    
    if uuid and DTNPCManager.Data[uuid] then
        local brain = DTNPCManager.Data[uuid]
        print("[DTNPC] NPC Died: " .. (brain.name or uuid))
        DTNPCManager.RemoveData(uuid, "Dead")
    else
        -- Fallback: try outfit ID
        local outfitID = zombie:getPersistentOutfitID()
        local fallbackUUID = DTNPCManager.GetUUIDFromOutfitID(outfitID)
        if fallbackUUID and DTNPCManager.Data[fallbackUUID] then
            local brain = DTNPCManager.Data[fallbackUUID]
            print("[DTNPC] NPC Died (fallback lookup): " .. (brain.name or fallbackUUID))
            DTNPCManager.RemoveData(fallbackUUID, "Dead")
        end
    end
end

Events.OnZombieDead.Add(DTNPCManager.Unregister)

-- ==============================================================================
-- 4. RESPAWN SYSTEM
-- ==============================================================================

local RESPAWN_RANGE = 100 -- Distance at which NPCs hydrate/spawn near players

function DTNPCManager.CheckForRespawn(brain, uuid)
    if not brain or not brain.lastX or not brain.lastY then return end
    
    local players = DTNPCManager.GetActivePlayers()
    for _, player in ipairs(players) do
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
    
    return false
end

function DTNPCManager.CheckRosterSpawns()
    if not DynamicTrading_Roster then return end
    
    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData or not rosterData.Souls then return end
    
    local players = DTNPCManager.GetActivePlayers()
    if #players == 0 then return end
    
    
    for uuid, registry in pairs(rosterData.Souls) do
        -- Skip if already active/tracked by the Manager
        if not DTNPCManager.Data[uuid] then
            -- ONLY spawn if status is Resting, Working, or Trading
            local status = registry.status or "Resting"
            if status == "Resting" or status == "Working" or status == "Trading" then
                local targetX, targetY, targetZ
                
                -- Prefer last known position, otherwise home
                if registry.lastX then
                    targetX, targetY, targetZ = registry.lastX, registry.lastY, registry.lastZ or 0
                elseif registry.homeCoords then
                     targetX, targetY, targetZ = registry.homeCoords.x, registry.homeCoords.y, registry.homeCoords.z or 0
                end
                
                if targetX then
                    for _, player in ipairs(players) do
                        local dx = player:getX() - targetX
                        local dy = player:getY() - targetY
                        local dz = player:getZ() - targetZ
                            
                        -- Relaxed Z-check: Allow +/- 1 floor (e.g. player on ground, NPC on 2nd floor)
                        if math.abs(dz) <= 1 and math.sqrt(dx*dx + dy*dy) < RESPAWN_RANGE then
                            -- Player is near this Roster soul. Hydrate it!
                            print("[DTNPC] Found Roster Soul nearby: " .. (registry.name or uuid) .. " Dist: " .. math.sqrt(dx*dx + dy*dy))
                            local fullBrain = DynamicTrading_Roster.GetSoul(uuid)
                            
                            if fullBrain then
                                -- Ensure coordinates are set for spawn
                                if not fullBrain.lastX then
                                    print("[DTNPC] Hydrating brain coordinates from registry for spawn.")
                                    fullBrain.lastX = targetX
                                    fullBrain.lastY = targetY
                                    fullBrain.lastZ = targetZ
                                end
                                
                                local zombie = DTNPCSpawn.RespawnNPC(fullBrain, uuid)
                                if zombie then
                                        print("[DTNPC] Roster Spawn SUCCESS for " .. uuid)
                                else
                                        print("[DTNPC] Roster Spawn FAILED for " .. uuid)
                                end
                            else
                                print("[DTNPC] ERROR: Could not retrieve full brain for " .. uuid)
                            end
                            break -- Spawned, move to next soul
                        end
                    end
                end
            end
        end
    end
end

function DTNPCManager.ProcessAwayTransitions()
    if not DynamicTrading_Roster then return end
    
    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData or not rosterData.Souls then return end
    
    local currentHours = getGameTime():getWorldAgeHours()
    
    for uuid, registry in pairs(rosterData.Souls) do
        if registry.status == "Away" and registry.returnTime then
            if currentHours >= registry.returnTime then
                local nextStatus = registry.returnStatus or "Resting"
                print("[DTNPC] Away Transition TIMER EXPIRED for " .. (registry.name or uuid) .. ". Returning to: " .. nextStatus)
                DynamicTrading_Roster.UpdateSoulStatus(uuid, nextStatus)
            end
        end
    end
end

local TICK_RATE = 20
local tickCounter = 0

local POSITION_BROADCAST_RATE = 120
local positionBroadcastCounter = 0

local RESPAWN_CHECK_RATE = 60 -- Check every 3 seconds (was 300/15s) for responsiveness
local respawnCheckCounter = 0

local TRANSITION_CHECK_RATE = 600 -- Check transitions every 30 seconds
local transitionCheckCounter = 0

function DTNPCManager.OnTick()
    -- Run on Server or Single Player

    tickCounter = tickCounter + 1
    positionBroadcastCounter = positionBroadcastCounter + 1
    respawnCheckCounter = respawnCheckCounter + 1
    transitionCheckCounter = transitionCheckCounter + 1
    
    local shouldBroadcast = (positionBroadcastCounter >= POSITION_BROADCAST_RATE)
    if shouldBroadcast then
        positionBroadcastCounter = 0
    end
    
    local shouldCheckRespawn = (respawnCheckCounter >= RESPAWN_CHECK_RATE)
    if shouldCheckRespawn then
        respawnCheckCounter = 0
    end

    local shouldCheckTransitions = (transitionCheckCounter >= TRANSITION_CHECK_RATE)
    if shouldCheckTransitions then
        transitionCheckCounter = 0
        DTNPCManager.ProcessAwayTransitions()
    end
    
    -- Respawn check
    if shouldCheckRespawn then
        -- 1. Check existing tracked NPCs
        for uuid, brain in pairs(DTNPCManager.Data) do
            DTNPCManager.CheckForRespawn(brain, uuid)
        end
        
        -- 2. Check for new spawns from Roster (Bridge)
        DTNPCManager.CheckRosterSpawns()
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
                        -- print("[DTNPC] Updated outfit ID for " .. (savedBrain.name or uuid) .. ": " .. currentOutfitID)
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
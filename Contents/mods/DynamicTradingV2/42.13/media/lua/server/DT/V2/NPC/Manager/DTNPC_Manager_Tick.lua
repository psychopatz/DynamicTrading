-- ==============================================================================
-- DTNPC_Manager_Tick.lua
-- Main tick loop: position tracking, visual fixes, and periodic broadcasts.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

DynamicTrading.Log("DTV2", "NPC", "Init", "Loading optimization modules...")

require "DT/V2/NPC/Manager/DTNPC_DistanceFrequency"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_DistanceFrequency loaded: " .. tostring(DTNPC_DistanceFrequency ~= nil))

require "DT/V2/NPC/Manager/DTNPC_SpatialHash/DTNPC_SpatialHash"
DynamicTrading.Log("DTV2", "NPC", "Init", "DTNPC_SpatialHash loaded: " .. tostring(DTNPC_SpatialHash ~= nil))

-- Guard: Create fallback tables with stub functions if modules didn't load
if not DTNPC_SpatialHash then
    DynamicTrading.Log("DTV2", "NPC", "Warn", "DTNPC_SpatialHash is nil, creating fallback")
    DTNPC_SpatialHash = {
        Grid = {},
        NPCToCell = {},
        IsInitialized = false,
        RebuildFromRoster = function() end,
        InsertNPC = function() end,
        RemoveNPC = function() end,
        GetNPCsInRadius = function() return {} end,
        GetNearestNPCs = function() return {} end,
        CleanupEmptyCells = function() end,
        Clear = function() end,
        GetGridStats = function() return {} end,
        ClearDirtyFlags = function() end,
        GetDirtyCells = function() return {} end
    }
end

if not DTNPC_DistanceFrequency then
    DynamicTrading.Log("DTV2", "NPC", "Warn", "DTNPC_DistanceFrequency is nil, creating fallback")
    DTNPC_DistanceFrequency = {
        NPCTimers = {},
        GetTierForDistance = function() return 4 end,
        GetUpdateFrequencyForDistance = function() return 6 end,
        InitializeNPC = function() end,
        ShouldUpdateNPC = function() return true end,
        UpdateNPC = function() end,
        RemoveNPC = function() end,
        Clear = function() end,
        GetUpdateStats = function() return {} end
    }
end

DynamicTrading.Log("DTV2", "NPC", "Init", "Module loading complete")

local TICK_RATE = 20
local tickCounter = 0

-- Bandwidth-first tuning: 12s position cadence at 20 ticks/sec.
local POSITION_BROADCAST_RATE = 240
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
        DTNPCManager.ProcessTradeCycles()
    end
    
    -- Respawn check
    if shouldCheckRespawn then
        -- 1. Check existing tracked NPCs
        for uuid, npcData in pairs(DTNPCManager.Data) do
            DTNPCManager.CheckForRespawn(npcData, uuid)
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
    
    -- Get active players for distance-based frequency updates
    local players = DTNPCManager.GetActivePlayers()
    
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie then
            local uuid = DTNPCManager.GetUUIDFromZombie(zombie)
            
            if uuid then
                local savedData = DTNPCManager.Data[uuid]
                
                if savedData then
                    -- 1. Sync Outfit ID (for outfitID-to-uuid mapping)
                    local currentOutfitID = zombie:getPersistentOutfitID()
                    if savedData.currentOutfitID ~= currentOutfitID then
                        -- Clear old mapping
                        if savedData.currentOutfitID then
                            DTNPCManager.OutfitIDToUUID[savedData.currentOutfitID] = nil
                        end
                        -- Set new mapping
                        savedData.currentOutfitID = currentOutfitID
                        -- print("[DTNPC] Updated outfit ID for " .. (savedData.name or uuid) .. ": " .. currentOutfitID)
                        DTNPCManager.OutfitIDToUUID[currentOutfitID] = uuid
                    end
                    
                    -- 2. Update Position History (used for respawn/teleport)
                    local newX, newY, newZ = math.floor(zombie:getX()), math.floor(zombie:getY()), math.floor(zombie:getZ())
                    savedData.lastX = newX
                    savedData.lastY = newY
                    savedData.lastZ = newZ
                    savedData.health = zombie:getHealth()
                    
                    -- Update spatial hash with current position
                    DTNPC_SpatialHash.InsertNPC(uuid, newX, newY, newZ, nil)
                    
                    -- Update distance-based frequency for this NPC (Phase 2.2)
                    if #players > 0 then
                        DTNPC_DistanceFrequency.UpdateNPC(uuid, newX, newY, players)
                    end
                    
                    -- Prevent wandering
                    if zombie:isUseless() and (savedData.state == "Stay" or savedData.state == "Guard") then
                        zombie:setPath2(nil)
                        zombie:setTarget(nil)
                    end
                    
                    -- 3. Visual & Data Sanity Check (Multiplayer Jitter fix)
                    -- If zombie exists but has lost its DTNPC modData (e.g. after weird cell transition or server lag)
                    local modData = zombie:getModData()
                    if modData.IsDTNPC and (not modData.DTNPCVisualID or modData.DTNPCVisualID == 0) then
                        -- This zombie is a DTNPC but visual ID is missing. Re-apply.
                        DynamicTrading.Log("DTV2", "NPC", "Fix", "Fixing visuals for NPC: " .. (savedData.name or uuid))
                        DTNPC.ApplyVisuals(zombie, savedData)
                        DTNPC.AttachData(zombie, savedData)
                        
                        local modData = zombie:getModData()
                        modData.DTNPCVisualID = savedData.visualID
                        modData.DTNPC_UUID = uuid
                        
                        if not zombie:isUseless() then
                            zombie:setUseless(true)
                            zombie:DoZombieStats()
                            zombie:setHealth(2)
                        end
                        
                        zombie:resetModelNextFrame()
                        
                        if DTNPCServerCore and DTNPCServerCore.SyncToAllClients then
                            DTNPCServerCore.SyncToAllClients(zombie, savedData)
                        end
                    end
                    
                    -- Periodic position broadcast
                    if shouldBroadcast and DTNPCServerCore and DTNPCServerCore.BroadcastPosition then
                        DTNPCServerCore.BroadcastPosition(zombie, savedData)
                    end
                end
            end
        end
    end
end

Events.OnTick.Add(DTNPCManager.OnTick)

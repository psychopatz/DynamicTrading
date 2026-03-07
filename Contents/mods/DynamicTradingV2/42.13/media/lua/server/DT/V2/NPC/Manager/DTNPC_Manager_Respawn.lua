-- ==============================================================================
-- DTNPC_Manager_Respawn.lua
-- Respawn checks, Roster hydration, Away transitions, and Trade cycles.
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

print("[DTNPC_Manager_Respawn] Loading optimization modules...")

-- Load spatial hash and distance frequency modules
require "DT/V2/NPC/Manager/DTNPC_SpatialHash"
print("[DTNPC_Manager_Respawn] DTNPC_SpatialHash loaded: " .. tostring(DTNPC_SpatialHash ~= nil))

require "DT/V2/NPC/Manager/DTNPC_DistanceFrequency"
print("[DTNPC_Manager_Respawn] DTNPC_DistanceFrequency loaded: " .. tostring(DTNPC_DistanceFrequency ~= nil))

-- Guard: Create fallback tables with stub functions if modules didn't load
if not DTNPC_SpatialHash then
    print("[DTNPC_Manager_Respawn] WARNING: DTNPC_SpatialHash is nil, creating fallback")
    DTNPC_SpatialHash = {
        Grid = {},
        NPCToCell = {},
        IsInitialized = false,
        RebuildFromRoster = function() print("[Fallback] RebuildFromRoster called") end,
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
    print("[DTNPC_Manager_Respawn] WARNING: DTNPC_DistanceFrequency is nil, creating fallback")
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

print("[DTNPC_Manager_Respawn] Module loading complete")

local RESPAWN_RANGE = 120 -- Maximum distance for respawn + buffer zone

function DTNPCManager.CheckForRespawn(brain, uuid)
    if not brain or not brain.lastX or not brain.lastY then return end
    
    local players = DTNPCManager.GetActivePlayers()
    for _, player in ipairs(players) do
        local dx = player:getX() - brain.lastX
        local dy = player:getY() - brain.lastY
        local dz = player:getZ() - (brain.lastZ or 0)
        
        local dist = math.sqrt(dx*dx + dy*dy)
        if math.abs(dz) <= 1 and dist < RESPAWN_RANGE then
            -- Check if zombie exists by UUID
            local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
            
            if not zombie then
                print("[DTNPC] Respawning NPC: " .. (brain.name or uuid) .. " near player " .. player:getUsername() .. " (dist: " .. string.format("%.1f", dist) .. ")")
                DTNPCServerCore.RespawnNPC(brain, uuid)
                return true
            end
        end
    end
    
    return false
end

function DTNPCManager.CheckRosterSpawns()
    print("[CheckRosterSpawns] Called")
    if not DynamicTrading_Roster then return end
    
    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData or not rosterData.Souls then return end
    
    local players = DTNPCManager.GetActivePlayers()
    if #players == 0 then return end
    
    print("[CheckRosterSpawns] DTNPC_SpatialHash type: " .. type(DTNPC_SpatialHash))
    print("[CheckRosterSpawns] DTNPC_SpatialHash.Grid type: " .. type(DTNPC_SpatialHash.Grid))
    print("[CheckRosterSpawns] DTNPC_SpatialHash.RebuildFromRoster type: " .. type(DTNPC_SpatialHash.RebuildFromRoster))
    print("[CheckRosterSpawns] DTNPC_SpatialHash.IsInitialized: " .. tostring(DTNPC_SpatialHash.IsInitialized))
    
    -- Initialize spatial hash if needed
    if not DTNPC_SpatialHash.IsInitialized then
        print("[CheckRosterSpawns] Calling RebuildFromRoster...")
        DTNPC_SpatialHash.RebuildFromRoster(rosterData)
        print("[CheckRosterSpawns] RebuildFromRoster completed")
    end
    
    -- Cleanup empty cells periodically (dirty flag optimization)
    DTNPC_SpatialHash.CleanupEmptyCells()
    
    local currentHours = getGameTime():getWorldAgeHours()
    local spawnedCount = 0
    
    -- Query NPCs near each player using spatial hash (O(n) instead of O(n²))
    local hashCandidates = 0
    for _, player in ipairs(players) do
        local playerX = player:getX()
        local playerY = player:getY()
        local playerZ = player:getZ()
        
        -- Get NPCs in spawn range + buffer
        local nearbySpawns = DTNPC_SpatialHash.GetNPCsInRadius(playerX, playerY, RESPAWN_RANGE)
        
        for uuid, npcData in pairs(nearbySpawns) do
            hashCandidates = hashCandidates + 1
            -- Skip if already active
            if not DTNPCManager.Data[uuid] then
                local registry = rosterData.Souls[uuid]
                
                if registry then
                    local status = registry.status or "Resting"
                    
                    -- Skip if spawn backoff active
                    if not (registry.spawnRetryTime and currentHours < registry.spawnRetryTime) then
                        -- Only spawn spawnnable statuses
                        if status == "Resting" or status == "Working" or status == "Trading" then
                            local targetX = npcData.x or (registry.lastX or (registry.homeCoords and registry.homeCoords.x))
                            local targetY = npcData.y or (registry.lastY or (registry.homeCoords and registry.homeCoords.y))
                            local targetZ = npcData.z or (registry.lastZ or (registry.homeCoords and registry.homeCoords.z) or 0)
                            
                            if targetX and targetY then
                                -- Final Z-check before spawn
                                local dz = playerZ - targetZ
                                if math.abs(dz) <= 1 then
                                    print("[DTNPC] Player " .. player:getUsername() .. " is near Soul: " .. (registry.name or uuid))
                                    
                                    local fullBrain = DynamicTrading_Roster.GetSoul(uuid)
                                    if fullBrain then
                                        fullBrain.lastX = targetX
                                        fullBrain.lastY = targetY
                                        fullBrain.lastZ = targetZ
                                        fullBrain.status = status
                                        
                                        local zombie = DTNPCServerCore.RespawnNPC(fullBrain, uuid)
                                        if zombie then
                                            print("[DTNPC] | Spawn SUCCESS for " .. uuid)
                                            registry.spawnRetryTime = nil
                                            
                                            -- Initialize distance frequency tracking
                                            DTNPC_DistanceFrequency.InitializeNPC(uuid)
                                            
                                            spawnedCount = spawnedCount + 1
                                        else
                                            print("[DTNPC] | Spawn FAILED for " .. uuid)
                                            registry.spawnRetryTime = currentHours + 0.1
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- FALLBACK: If spatial hash yielded nothing, scan roster directly for nearby NPCs
    -- This ensures spawning works even if hash is stale or uninitialized
    if hashCandidates == 0 and #players > 0 then
        print("[CheckRosterSpawns] Spatial hash empty, using fallback roster scan...")
        for uuid, registry in pairs(rosterData.Souls) do
            -- Skip if already active (Live)
            if not DTNPCManager.Data[uuid] then
                local status = registry.status or "Resting"
                
                -- Skip if spawn backoff active
                if not (registry.spawnRetryTime and currentHours < registry.spawnRetryTime) then
                    if status == "Resting" or status == "Working" or status == "Trading" then
                        local npcX = registry.lastX or (registry.homeCoords and registry.homeCoords.x)
                        local npcY = registry.lastY or (registry.homeCoords and registry.homeCoords.y)
                        local npcZ = registry.lastZ or (registry.homeCoords and registry.homeCoords.z) or 0
                        
                        if npcX and npcY then
                            -- Check if any player is within range
                            for _, player in ipairs(players) do
                                local playerX = player:getX()
                                local playerY = player:getY()
                                local playerZ = player:getZ()
                                
                                local dx = playerX - npcX
                                local dy = playerY - npcY
                                local dz = playerZ - npcZ
                                local dist = math.sqrt(dx * dx + dy * dy)
                                
                                if math.abs(dz) <= 1 and dist < RESPAWN_RANGE then
                                    print("[DTNPC-Fallback] Player " .. player:getUsername() .. " near Soul: " .. (registry.name or uuid))
                                    
                                    local fullBrain = DynamicTrading_Roster.GetSoul(uuid)
                                    if fullBrain then
                                        fullBrain.lastX = npcX
                                        fullBrain.lastY = npcY
                                        fullBrain.lastZ = npcZ
                                        fullBrain.status = status
                                        
                                        local zombie = DTNPCServerCore.RespawnNPC(fullBrain, uuid)
                                        if zombie then
                                            print("[DTNPC-Fallback] | Spawn SUCCESS for " .. uuid)
                                            registry.spawnRetryTime = nil
                                            DTNPC_DistanceFrequency.InitializeNPC(uuid)
                                            spawnedCount = spawnedCount + 1
                                        else
                                            print("[DTNPC-Fallback] | Spawn FAILED for " .. uuid)
                                            registry.spawnRetryTime = currentHours + 0.1
                                        end
                                    end
                                    break  -- Spawned for this player, move to next NPC
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if spawnedCount > 0 then
        print("[DTNPC_Respawn] CheckRosterSpawns spawned " .. spawnedCount .. " NPCs (hash candidates: " .. hashCandidates .. ")")
    end
end

function DTNPCManager.ProcessAwayTransitions()
    if not DynamicTrading_Roster then return end
    
    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData or not rosterData.Souls then return end
    
    local currentHours = getGameTime():getWorldAgeHours()
    
    for uuid, registry in pairs(rosterData.Souls) do
        -- CHECK BOTH AWAY AND TRADING FOR TRANSITIONS
        if (registry.status == "Away" or registry.status == "Trading") and registry.returnTime then
            if currentHours >= registry.returnTime then
                local nextStatus = registry.returnStatus or "Resting"
                local newReturnTime = 0
                local newReturnStatus = nil

                print("[DTNPC] Away Transition TIMER EXPIRED for " .. (registry.name or uuid) .. ". Target: " .. nextStatus)
                
                -- IF WE ARE TRANSITIONING TO TRADING, WE NEED TO FIND A LOCATION
                if nextStatus == "Trading" then
                    -- 0. Ensure Building Data is Loaded
                    if not DTM or not DTM.Buildings then
                        print("[DTNPC] Building data missing. Attempting lazy load...")
                        if DTM and DTM.LoadBuildings then DTM.LoadBuildings() end
                    end

                    -- 1. Get Home Town
                    local town = "Rosewood" -- Default fallback
                    
                    -- PRIORITY 1: Check Faction Data directly for the Town name
                    if registry.factionID and DynamicTrading_Factions then
                        local faction = DynamicTrading_Factions.GetFaction(registry.factionID)
                        if faction and faction.town then
                            town = faction.town
                            print("[DTNPC] | Faction [" .. registry.factionID .. "] town identified: " .. town)
                        end
                    end
                    
                    -- PRIORITY 2: Fallback to coordinate-based detection ONLY if faction town is missing
                    if (not town or town == "Rosewood") and registry.homeCoords then
                        if DTM and DTM.GetTownName then
                            local detected = DTM.GetTownName(registry.homeCoords.x, registry.homeCoords.y)
                            if detected and detected ~= "Wilderness" then
                                town = detected
                            end
                        end
                    end
                    
                    print("[DTNPC] | Mission town locked to: " .. town)
                    
                    -- 2. Find random building in that town
                    local targetBuilding = nil
                    if DTM and DTM.Buildings then
                        local townBuildings = {}
                        for _, b in ipairs(DTM.Buildings) do
                            if b.town == town then
                                table.insert(townBuildings, b)
                            end
                        end
                        print("[DTNPC] Found " .. #townBuildings .. " potential buildings in " .. town)
                        
                        if #townBuildings > 0 then
                            targetBuilding = townBuildings[ZombRand(#townBuildings) + 1]
                        end
                    else
                        print("[DTNPC] ERROR: DTM.Buildings is still NIL/Empty after load attempt.")
                    end
                    
                    if targetBuilding then
                        print("[DTNPC] NPC " .. (registry.name or uuid) .. " SUCCESS! Trading spot found in " .. town .. " at " .. targetBuilding.cx .. "," .. targetBuilding.cy)
                        
                        -- Update Roster Soul with new temporary coordinates
                        local fullBrain = DynamicTrading_Roster.GetSoul(uuid)
                        if fullBrain then
                            fullBrain.lastX = targetBuilding.cx
                            fullBrain.lastY = targetBuilding.cy
                            fullBrain.lastZ = 0
                            
                            -- Set Return Time for Trading Session
                            local stayHours = SandboxVars.DynamicTrading.NPCTradingStayHours or 4.0
                            newReturnTime = currentHours + stayHours
                            newReturnStatus = "Away" -- Walk back home after trading
                            
                            print("[DTNPC] Session duration: " .. stayHours .. "h. Return Time: " .. newReturnTime)
                            DynamicTrading_Roster.SaveSoul(uuid, fullBrain)
                        end
                    else
                        print("[DTNPC] WARNING: No buildings found for town " .. town .. ". Returning NPC to base.")
                        nextStatus = "Resting" -- Failsafe
                    end
                elseif nextStatus == "Resting" then
                    print("[DTNPC] NPC " .. (registry.name or uuid) .. " transitioning to Home (Resting).")
                    -- Returning Home from Away
                    local fullBrain = DynamicTrading_Roster.GetSoul(uuid)
                    if fullBrain and fullBrain.homeCoords then
                        fullBrain.lastX = fullBrain.homeCoords.x
                        fullBrain.lastY = fullBrain.homeCoords.y
                        fullBrain.lastZ = fullBrain.homeCoords.z or 0
                        
                        -- Reset transition info
                        newReturnTime = 0
                        newReturnStatus = nil
                        
                        DynamicTrading_Roster.SaveSoul(uuid, fullBrain)
                    end
                elseif nextStatus == "Away" then
                    print("[DTNPC] NPC " .. (registry.name or uuid) .. " mission ended. Transitioning to Away (Walking Home).")
                    -- Return walk initiated (Trading -> Away -> Resting)
                    local fullBrain = DynamicTrading_Roster.GetSoul(uuid)
                    if fullBrain then
                        local walkHours = SandboxVars.DynamicTrading.NPCTradingWalkHours or 1.0
                        newReturnTime = currentHours + walkHours
                        newReturnStatus = "Resting"
                        
                        DynamicTrading_Roster.SaveSoul(uuid, fullBrain)
                    end
                end

                -- CRITICAL: Use the new centralized status setter
                DTNPCManager.SetNPCStatus(uuid, nextStatus, newReturnTime, newReturnStatus)
            end
        end
    end
end

function DTNPCManager.ProcessTradeCycles()
    if not DynamicTrading_Roster then return end
    
    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData or not rosterData.Souls then return end
    
    local popLimitPercent = SandboxVars.DynamicTrading.NPCTradePopPercent or 40
    local currentHours = getGameTime():getWorldAgeHours()
    
    -- Group souls by faction to check population limits
    local factionTradingCounts = {}
    local factionTotalCounts = {}
    
    -- First pass: Count trading/away and total population per faction
    for uuid, registry in pairs(rosterData.Souls) do
        local factionID = registry.factionID or "Independent"
        factionTotalCounts[factionID] = (factionTotalCounts[factionID] or 0) + 1
        
        if registry.status == "Away" or registry.status == "Trading" then
            factionTradingCounts[factionID] = (factionTradingCounts[factionID] or 0) + 1
        end
    end
    
    -- Second pass: Trigger missions based on limits
    for uuid, registry in pairs(rosterData.Souls) do
        if registry.status == "Resting" then
            local factionID = registry.factionID or "Independent"
            local currentTrading = factionTradingCounts[factionID] or 0
            local totalMembers = factionTotalCounts[factionID] or 1
            
            -- [UNIFIED] Apply Event Modifiers
            local limitMult = 1.0
            if DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
                local faction = DynamicTrading_Factions.GetFaction(factionID)
                limitMult = DynamicTrading.Events.GetFactionSystemModifier(faction, "traderLimit")
            end
            
            local effectivePopLimit = popLimitPercent * limitMult
            local currentPercent = (currentTrading / totalMembers) * 100
            
            if currentPercent < effectivePopLimit then
                -- Small random chance to trigger (simulating daily chance spread over ticks)
                -- 1 in 2000 chance per check (~1 min real time if check is every 30s)
                if ZombRand(2000) < 10 then 
                    DTNPCManager.StartTradeMission(uuid)
                    -- Update count so we don't over-spawn in the same tick
                    factionTradingCounts[factionID] = currentTrading + 1
                end
            end
        end
    end
end

function DTNPCManager.StartTradeMission(uuid, forceImmediate)
    local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
    if not soul then 
        print("[DTNPC] ERROR: StartTradeMission failed - Soul not found for " .. tostring(uuid))
        return 
    end
    
    local currentHours = getGameTime():getWorldAgeHours()
    local walkHours = SandboxVars.DynamicTrading.NPCTradingWalkHours or 2
    
    if forceImmediate then 
        walkHours = 0.02 -- Force Trade still simulates travel (approx 1.2 mins) but at a priority speed
    end
    
    print("[DTNPC] STARTING TRADE MISSION for: " .. (soul.name or uuid) .. " at " .. currentHours)
    print("[DTNPC] | Travel Time: " .. walkHours .. "h. Status: Away. Target: Trading")
    
    -- Centralized transition
    DTNPCManager.SetNPCStatus(uuid, "Away", currentHours + walkHours, "Trading")
end

local function onClientCommand(module, command, player, args)
    if module ~= "DynamicTrading_V2" then return end
    
    if command == "ForceTradeMission" then
        local uuid = args.uuid
        if uuid then
            print("[DTNPC] Admin/Debug Force Trade Mission for: " .. uuid)
            DTNPCManager.StartTradeMission(uuid, true)
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)

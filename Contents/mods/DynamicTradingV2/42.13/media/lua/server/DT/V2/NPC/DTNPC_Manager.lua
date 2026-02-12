-- ==============================================================================
-- DTNPC_Manager.lua
-- Server-side Logic: Persists NPC data and TRACKS LOCATIONS.
-- FIXED: Use persistent UUID instead of outfit ID to prevent duplicates
-- ==============================================================================

DTNPCManager = DTNPCManager or {}
DTNPCManager.Data = {} 
DTNPCManager.PendingRegistrations = {}
DTNPCManager.OutfitIDToUUID = {} -- Maps current outfit IDs to persistent UUIDs

require "DT/V2/Faction/TradingSys/DynamicTrading_Roster" -- V2 Roster Bridge

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
        
        print("[DTNPC] Removed NPC data from world tracker: " .. (brain.name or uuid) .. " (Status: " .. (status or "Removed") .. ")")
        
        -- Broadcast removal to all clients
        if DTNPCSpawn and DTNPCSpawn.NotifyRemoval then
            DTNPCSpawn.NotifyRemoval(uuid, brain.currentOutfitID, brain.name)
        end
    end
end

function DTNPCManager.SetNPCStatus(uuid, status, returnTime, returnStatus)
    -- 1. Always update the persistent Roster (Bridge)
    if DynamicTrading_Roster then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
    end

    -- 2. If the status implies they are "Away" or "Dead", clean up physical presence
    if status == "Away" or status == "Dead" then
        if DTNPCManager.Data[uuid] then
            print("[DTNPC] Status change to " .. status .. " requires world removal.")
            DTNPCManager.RemoveData(uuid) -- No arguments to avoid recursion loop
        end
        
        -- Clean up physical zombie if it exists
        if DTNPCSpawn and DTNPCSpawn.FindZombieByUUID then
            local zombie = DTNPCSpawn.FindZombieByUUID(uuid)
            if zombie then
                zombie:removeFromWorld()
                zombie:removeFromSquare()
                print("[DTNPC] Forcefully removed physical zombie for Away/Dead state: " .. uuid)
            end
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
            
            -- SPAWN BACKOFF: Skip if we failed recently
            local currentHours = getGameTime():getWorldAgeHours()
            if registry.spawnRetryTime and currentHours < registry.spawnRetryTime then
                -- Skip for now
            elseif status == "Resting" or status == "Working" or status == "Trading" then
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
                            
                        local dist = math.sqrt(dx*dx + dy*dy)
                        -- Relaxed Z-check: Allow +/- 1 floor (e.g. player on ground, NPC on 2nd floor)
                        if math.abs(dz) <= 1 and dist < RESPAWN_RANGE then
                            -- Player is near this Roster soul. Hydrate it!
                            print("[DTNPC] Player " .. player:getUsername() .. " is near Soul: " .. (registry.name or uuid) .. " (Dist: " .. string.format("%.1f", dist) .. "m, Status: " .. (status or "nil") .. ")")
                            local fullBrain = DynamicTrading_Roster.GetSoul(uuid)
                            
                            if fullBrain then
                                -- Ensure coordinates are accurate for spawn
                                fullBrain.lastX = targetX
                                fullBrain.lastY = targetY
                                fullBrain.lastZ = targetZ
                                fullBrain.status = status -- Sync status to brain
                                
                                local zombie = DTNPCSpawn.RespawnNPC(fullBrain, uuid)
                                if zombie then
                                        print("[DTNPC] | Spawn SUCCESS for " .. uuid)
                                        registry.spawnRetryTime = nil -- Reset on success
                                else
                                        print("[DTNPC] | Spawn FAILED for " .. uuid .. " (SafeSq search likely failed or chunk unloaded)")
                                        registry.spawnRetryTime = currentHours + 0.1 -- Retry in ~6 minutes game time
                                end
                            else
                                print("[DTNPC] | ERROR: Brain content missing for " .. uuid)
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
            
            -- [NEW] Apply Event Modifiers
            local limitMult = 1.0
            if DynamicTrading and DynamicTrading.V2 and DynamicTrading.V2.Director then
                limitMult = DynamicTrading.V2.Director.GetSystemModifier(factionID, "traderLimit")
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

function DTNPCManager.StartTradeMission(uuid)
    local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
    if not soul then 
        print("[DTNPC] ERROR: StartTradeMission failed - Soul not found for " .. tostring(uuid))
        return 
    end
    
    local currentHours = getGameTime():getWorldAgeHours()
    local walkHours = SandboxVars.DynamicTrading.NPCTradingWalkHours or 1.0
    
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
            DTNPCManager.StartTradeMission(uuid)
        end
    end
end

Events.OnClientCommand.Add(onClientCommand)

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
        DTNPCManager.ProcessTradeCycles()
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
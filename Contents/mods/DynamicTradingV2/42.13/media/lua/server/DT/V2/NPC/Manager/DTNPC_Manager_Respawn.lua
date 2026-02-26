-- ==============================================================================
-- DTNPC_Manager_Respawn.lua
-- Respawn checks, Roster hydration, Away transitions, and Trade cycles.
-- ==============================================================================

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

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

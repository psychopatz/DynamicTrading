-- ==============================================================================
-- DTNPC_ManagerRespawn_Transitions.lua
-- Handles status transitions for NPCs (Away, Trading, Resting).
-- ==============================================================================

-- GUARD: Ensure DTNPCManager table exists
DTNPCManager = DTNPCManager or {}

-- GUARD: Prevent Remote MP Clients from running this, but allow SP and Host
if isClient() and not isServer() then return end

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

                DynamicTrading.Log("DTV2", "NPC", "Logic", "Away Transition TIMER EXPIRED for " .. (registry.name or uuid) .. ". Target: " .. nextStatus)
                
                -- IF WE ARE TRANSITIONING TO TRADING, WE NEED TO FIND A LOCATION
                if nextStatus == "Trading" then
                    local isWandering = false
                    local debugReason = ""
                    
                    if registry.factionID == "Independent" or registry.factionID == "Factionless" then
                        isWandering = true
                        debugReason = "Independent/Factionless Trader"
                    else
                        local wanderChance = SandboxVars.DynamicTrading.TownTraderWanderChance or 5.0
                        if ZombRand(10000) < (wanderChance * 100) then
                            isWandering = true
                            debugReason = "Town Trader Wandered (" .. wanderChance .. "%)"
                        end
                    end
                    
                    if isWandering then
                        DynamicTrading.Log("DTV2", "NPC", "Logic", "NPC " .. (registry.name or uuid) .. " using player-centric spawn: " .. debugReason)
                        
                        -- Ensure Building Data is Loaded
                        if not DTM or not DTM.Buildings then
                            DynamicTrading.Log("DTV2", "NPC", "Logic", "Building data missing. Attempting lazy load...")
                            if DTM and DTM.LoadBuildings then DTM.LoadBuildings() end
                        end
                        
                        local players = DTNPCManager.GetActivePlayers()
                        if #players > 0 then
                            local player = players[ZombRand(#players) + 1]
                            local playerX = player:getX()
                            local playerY = player:getY()
                            
                            local minRadius = SandboxVars.DynamicTrading.IndependentSpawnRadiusMin or 500
                            local maxRadius = SandboxVars.DynamicTrading.IndependentSpawnRadiusMax or 1000
                            
                            local angle = ZombRandFloat(0, math.pi * 2)
                            local dist = ZombRandFloat(minRadius, maxRadius)
                            
                            local targetX = playerX + math.cos(angle) * dist
                            local targetY = playerY + math.sin(angle) * dist
                            
                            local targetBuilding = nil
                            local validBuildings = {}
                            
                            if DTM and DTM.Buildings then
                                for _, b in ipairs(DTM.Buildings) do
                                    local bx = b.cx
                                    local by = b.cy
                                    local bDist = math.sqrt((playerX - bx)^2 + (playerY - by)^2)
                                    if bDist >= minRadius and bDist <= maxRadius then
                                        table.insert(validBuildings, b)
                                    end
                                end
                            end
                            
                            local npcData = DynamicTrading_Roster.GetSoul(uuid)
                            if npcData then
                                if #validBuildings > 0 then
                                    targetBuilding = validBuildings[ZombRand(#validBuildings) + 1]
                                    DynamicTrading.Log("DTV2", "NPC", "Logic", "Found " .. #validBuildings .. " buildings in radius. Picked building at " .. targetBuilding.cx .. "," .. targetBuilding.cy)
                                    
                                    npcData.lastX = targetBuilding.cx
                                    npcData.lastY = targetBuilding.cy
                                    npcData.lastZ = 0
                                else
                                    DynamicTrading.Log("DTV2", "NPC", "Logic", "No buildings found in radius. Spawning in wilderness at " .. targetX .. "," .. targetY)
                                    
                                    npcData.lastX = targetX
                                    npcData.lastY = targetY
                                    npcData.lastZ = 0
                                end
                                
                                local stayHours = SandboxVars.DynamicTrading.NPCTradingStayHours or 4.0
                                newReturnTime = currentHours + stayHours
                                newReturnStatus = "Away"
                                
                                DynamicTrading.Log("DTV2", "NPC", "Logic", "Session duration: " .. stayHours .. "h. Return Time: " .. newReturnTime)
                                DynamicTrading_Roster.SaveSoul(uuid, npcData)
                            end
                        else
                            DynamicTrading.Log("DTV2", "NPC", "Logic", "WARNING: No active players found for wandering trader. Returning to base.")
                            nextStatus = "Resting" -- Failsafe
                        end
                    else
                        -- 0. Ensure Building Data is Loaded
                        if not DTM or not DTM.Buildings then
                            DynamicTrading.Log("DTV2", "NPC", "Logic", "Building data missing. Attempting lazy load...")
                            if DTM and DTM.LoadBuildings then DTM.LoadBuildings() end
                        end

                        -- 1. Get Home Town
                        local town = "Rosewood" -- Default fallback
                        
                        -- PRIORITY 1: Check Faction Data directly for the Town name
                        if registry.factionID and DynamicTrading_Factions then
                            local faction = DynamicTrading_Factions.GetFaction(registry.factionID)
                            if faction and faction.town then
                                town = faction.town
                                DynamicTrading.Log("DTV2", "NPC", "Logic", "| Faction [" .. registry.factionID .. "] town identified: " .. town)
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
                        
                        DynamicTrading.Log("DTV2", "NPC", "Logic", "| Mission town locked to: " .. town)
                        
                        -- 2. Find random building in that town
                        local targetBuilding = nil
                        if DTM and DTM.Buildings then
                            local townBuildings = {}
                            for _, b in ipairs(DTM.Buildings) do
                                if b.town == town then
                                    table.insert(townBuildings, b)
                                end
                            end
                            DynamicTrading.Log("DTV2", "NPC", "Logic", "Found " .. #townBuildings .. " potential buildings in " .. town)
                            
                            if #townBuildings > 0 then
                                targetBuilding = townBuildings[ZombRand(#townBuildings) + 1]
                            end
                        else
                            DynamicTrading.Log("DTV2", "NPC", "Logic", "ERROR: DTM.Buildings is still NIL/Empty after load attempt.")
                        end
                        
                        if targetBuilding then
                            DynamicTrading.Log("DTV2", "NPC", "Logic", "NPC " .. (registry.name or uuid) .. " SUCCESS! Trading spot found in " .. town .. " at " .. targetBuilding.cx .. "," .. targetBuilding.cy)
                            
                            -- Update Roster Soul with new temporary coordinates
                            local npcData = DynamicTrading_Roster.GetSoul(uuid)
                            if npcData then
                                npcData.lastX = targetBuilding.cx
                                npcData.lastY = targetBuilding.cy
                                npcData.lastZ = 0
                                
                                -- Set Return Time for Trading Session
                                local stayHours = SandboxVars.DynamicTrading.NPCTradingStayHours or 4.0
                                newReturnTime = currentHours + stayHours
                                newReturnStatus = "Away" -- Walk back home after trading
                                
                                DynamicTrading.Log("DTV2", "NPC", "Logic", "Session duration: " .. stayHours .. "h. Return Time: " .. newReturnTime)
                                DynamicTrading_Roster.SaveSoul(uuid, npcData)
                            end
                        else
                            DynamicTrading.Log("DTV2", "NPC", "Logic", "WARNING: No buildings found for town " .. town .. ". Returning NPC to base.")
                            nextStatus = "Resting" -- Failsafe
                        end
                    end
                elseif nextStatus == "Resting" then
                    DynamicTrading.Log("DTV2", "NPC", "Logic", "NPC " .. (registry.name or uuid) .. " transitioning to Home (Resting).")
                    -- Returning Home from Away
                    local npcData = DynamicTrading_Roster.GetSoul(uuid)
                    if npcData and npcData.homeCoords then
                        npcData.lastX = npcData.homeCoords.x
                        npcData.lastY = npcData.homeCoords.y
                        npcData.lastZ = npcData.homeCoords.z or 0
                        
                        -- Reset transition info
                        newReturnTime = 0
                        newReturnStatus = nil
                        
                        DynamicTrading_Roster.SaveSoul(uuid, npcData)
                    end
                elseif nextStatus == "Away" then
                    DynamicTrading.Log("DTV2", "NPC", "Logic", "NPC " .. (registry.name or uuid) .. " mission ended. Transitioning to Away (Walking Home).")
                    -- Return walk initiated (Trading -> Away -> Resting)
                    local npcData = DynamicTrading_Roster.GetSoul(uuid)
                    if npcData then
                        local walkHours = SandboxVars.DynamicTrading.NPCTradingWalkHours or 1.0
                        newReturnTime = currentHours + walkHours
                        newReturnStatus = "Resting"
                        
                        DynamicTrading_Roster.SaveSoul(uuid, npcData)
                    end
                end

                -- CRITICAL: Use the new centralized status setter
                DTNPCManager.SetNPCStatus(uuid, nextStatus, newReturnTime, newReturnStatus)
            end
        end
    end
end

DynamicTrading.Log("DTV2", "Init", "NPC", "Loaded successfully")

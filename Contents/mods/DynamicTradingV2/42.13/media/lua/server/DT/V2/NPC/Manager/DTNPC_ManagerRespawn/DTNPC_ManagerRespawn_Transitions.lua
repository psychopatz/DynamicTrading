-- ==============================================================================
-- DTNPC_ManagerRespawn_Transitions.lua
-- Handles status transitions for NPCs (Away, Trading, Resting).
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

local LIVE_DEPARTURE_RADIUS = 120

local function isVisibleToActivePlayer(zombie, radius)
    if not zombie or not DTNPCManager.GetActivePlayers then return false end

    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()
    local maxDist = radius or LIVE_DEPARTURE_RADIUS

    for _, player in ipairs(DTNPCManager.GetActivePlayers()) do
        if math.abs(player:getZ() - zz) <= 1 then
            local dx = player:getX() - zx
            local dy = player:getY() - zy
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= maxDist then
                return true
            end
        end
    end

    return false
end

function DTNPCManager.PlanTradingDestination(uuid, registry)
    if not DynamicTrading_Roster then return nil end

    local npcData = DynamicTrading_Roster.GetSoul(uuid)
    if not npcData then return nil end

    local cachedTarget = npcData.travelTarget
    if cachedTarget and cachedTarget.status == "Trading" and cachedTarget.x and cachedTarget.y then
        return cachedTarget.x, cachedTarget.y, cachedTarget.z or 0
    end

    local targetX = nil
    local targetY = nil
    local targetZ = 0

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

    if not DTM or not DTM.Buildings then
        DynamicTrading.Log("DTV2", "NPC", "Logic", "Building data missing. Attempting lazy load...")
        if DTM and DTM.LoadBuildings then DTM.LoadBuildings() end
    end

    if isWandering then
        DynamicTrading.Log("DTV2", "NPC", "Logic", "Planning player-centric trade destination: " .. debugReason)
        local players = DTNPCManager.GetActivePlayers()
        if #players > 0 then
            local player = players[ZombRand(#players) + 1]
            local playerX = player:getX()
            local playerY = player:getY()
            local minRadius = SandboxVars.DynamicTrading.IndependentSpawnRadiusMin or 500
            local maxRadius = SandboxVars.DynamicTrading.IndependentSpawnRadiusMax or 1000
            local angle = ZombRandFloat(0, math.pi * 2)
            local dist = ZombRandFloat(minRadius, maxRadius)

            targetX = playerX + math.cos(angle) * dist
            targetY = playerY + math.sin(angle) * dist

            if DTM and DTM.Buildings then
                local validBuildings = {}
                for _, building in ipairs(DTM.Buildings) do
                    local bx = building.cx
                    local by = building.cy
                    local bDist = math.sqrt((playerX - bx)^2 + (playerY - by)^2)
                    if bDist >= minRadius and bDist <= maxRadius then
                        table.insert(validBuildings, building)
                    end
                end

                if #validBuildings > 0 then
                    local targetBuilding = validBuildings[ZombRand(#validBuildings) + 1]
                    targetX = targetBuilding.cx
                    targetY = targetBuilding.cy
                end
            end
        end
    else
        local town = "Rosewood"
        if registry.factionID and DynamicTrading_Factions then
            local faction = DynamicTrading_Factions.GetFaction(registry.factionID)
            if faction and faction.town then
                town = faction.town
            end
        end

        if (not town or town == "Rosewood") and registry.homeCoords and DTM and DTM.GetTownName then
            local detected = DTM.GetTownName(registry.homeCoords.x, registry.homeCoords.y)
            if detected and detected ~= "Wilderness" then
                town = detected
            end
        end

        if DTM and DTM.Buildings then
            local townBuildings = {}
            for _, building in ipairs(DTM.Buildings) do
                if building.town == town then
                    table.insert(townBuildings, building)
                end
            end

            if #townBuildings > 0 then
                local targetBuilding = townBuildings[ZombRand(#townBuildings) + 1]
                targetX = targetBuilding.cx
                targetY = targetBuilding.cy
            end
        end
    end

    if targetX and targetY then
        npcData.travelTarget = {
            x = targetX,
            y = targetY,
            z = targetZ,
            status = "Trading",
        }
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
        return targetX, targetY, targetZ
    end

    return nil
end

function DTNPCManager.TryStartLiveDeparture(uuid, requestedReturnStatus, travelHours, targetX, targetY, targetZ)
    if not DTNPCServerCore or not DTNPCServerCore.FindZombieByUUID then return false end

    local zombie = DTNPCServerCore.FindZombieByUUID(uuid)
    if not zombie or not isVisibleToActivePlayer(zombie, LIVE_DEPARTURE_RADIUS) then
        return false
    end

    local npcData = (DTNPCManager.Data and DTNPCManager.Data[uuid]) or DynamicTrading_Roster.GetSoul(uuid)
    if not npcData then return false end

    npcData.state = "Departure"
    npcData.requestedReturnStatus = requestedReturnStatus or "Resting"
    npcData.departureTravelHours = travelHours or 0
    npcData.departureTargetX = targetX
    npcData.departureTargetY = targetY
    npcData.departureTargetZ = targetZ or 0
    npcData.departureBlockedTicks = 0
    npcData.departureStuckLastX = nil
    npcData.departureStuckLastY = nil
    npcData.isMovingState = false
    npcData.removalRequested = nil
    npcData.anchorX = nil
    npcData.anchorY = nil
    npcData.anchorZ = nil

    DTNPCManager.Data[uuid] = npcData
    DTNPC.AttachData(zombie, npcData)
    DynamicTrading_Roster.SaveSoul(uuid, npcData)
    if DTNPCManager.Save then
        DTNPCManager.Save()
    end

    if DTNPCServerCore.SyncToAllClients then
        DTNPCServerCore.SyncToAllClients(zombie, npcData)
    end
    if DTNPCServerCore.BroadcastPosition then
        DTNPCServerCore.BroadcastPosition(zombie, npcData)
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Departure",
        "Started live departure for " .. (npcData.name or uuid) .. " toward " .. tostring(requestedReturnStatus)
    )
    return true
end

function DTNPCManager.ProcessAwayTransitions()
    if not DynamicTrading_Roster then return end

    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData or not rosterData.Souls then return end

    local currentHours = getGameTime():getWorldAgeHours()

    for uuid, registry in pairs(rosterData.Souls) do
        local liveSoul = DynamicTrading_Roster.GetSoul(uuid)
        local isDeparting = liveSoul and liveSoul.state == "Departure"

        if not isDeparting and (registry.status == "Away" or registry.status == "Trading") and registry.returnTime then
            if currentHours >= registry.returnTime then
                local nextStatus = registry.returnStatus or "Resting"
                local newReturnTime = 0
                local newReturnStatus = nil
                local shouldApplyStatus = true

                DynamicTrading.Log("DTV2", "NPC", "Logic", "Away Transition TIMER EXPIRED for " .. (registry.name or uuid) .. ". Target: " .. nextStatus)

                if nextStatus == "Trading" then
                    local targetX, targetY, targetZ = DTNPCManager.PlanTradingDestination(uuid, registry)
                    local npcData = DynamicTrading_Roster.GetSoul(uuid)
                    if targetX and targetY and npcData then
                        npcData.lastX = targetX
                        npcData.lastY = targetY
                        npcData.lastZ = targetZ or 0
                        npcData.travelTarget = nil

                        local stayHours = SandboxVars.DynamicTrading.NPCTradingStayHours or 4.0
                        newReturnTime = currentHours + stayHours
                        newReturnStatus = "Away"

                        DynamicTrading.Log("DTV2", "NPC", "Logic", "Session duration: " .. stayHours .. "h. Return Time: " .. newReturnTime)
                        DynamicTrading_Roster.SaveSoul(uuid, npcData)
                    else
                        DynamicTrading.Log("DTV2", "NPC", "Logic", "WARNING: Unable to plan trading destination. Returning NPC to base.")
                        nextStatus = "Resting"
                    end
                end

                if nextStatus == "Resting" then
                    DynamicTrading.Log("DTV2", "NPC", "Logic", "NPC " .. (registry.name or uuid) .. " transitioning to Home (Resting).")
                    local npcData = DynamicTrading_Roster.GetSoul(uuid)
                    if npcData and npcData.homeCoords then
                        npcData.lastX = npcData.homeCoords.x
                        npcData.lastY = npcData.homeCoords.y
                        npcData.lastZ = npcData.homeCoords.z or 0
                        npcData.travelTarget = nil
                        newReturnTime = 0
                        newReturnStatus = nil
                        DynamicTrading_Roster.SaveSoul(uuid, npcData)
                    end
                elseif nextStatus == "Away" then
                    DynamicTrading.Log("DTV2", "NPC", "Logic", "NPC " .. (registry.name or uuid) .. " mission ended. Transitioning to Away (Walking Home).")
                    local npcData = DynamicTrading_Roster.GetSoul(uuid)
                    if npcData then
                        local walkHours = SandboxVars.DynamicTrading.NPCTradingWalkHours or 1.0
                        local home = npcData.homeCoords
                        if home and DTNPCManager.TryStartLiveDeparture(uuid, "Resting", walkHours, home.x, home.y, home.z or 0) then
                            shouldApplyStatus = false
                        else
                            newReturnTime = currentHours + walkHours
                            newReturnStatus = "Resting"
                            DynamicTrading_Roster.SaveSoul(uuid, npcData)
                        end
                    end
                end

                if shouldApplyStatus then
                    DTNPCManager.SetNPCStatus(uuid, nextStatus, newReturnTime, newReturnStatus)
                end
            end
        end
    end
end

DynamicTrading.Log("DTV2", "Init", "NPC", "Loaded successfully")

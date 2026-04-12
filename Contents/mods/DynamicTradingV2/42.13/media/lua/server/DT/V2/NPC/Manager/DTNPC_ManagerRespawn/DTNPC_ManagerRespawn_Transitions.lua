-- ==============================================================================
-- DTNPC_ManagerRespawn_Transitions.lua
-- Handles status transitions for NPCs (Away, Trading, Resting).
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

local LIVE_DEPARTURE_RADIUS = 120
local DEFAULT_DEPARTURE_VISIBLE_HOURS = 0.25
local STALE_TRADING_RECOVERY_GRACE_HOURS = 0.02
local NEARBY_DESPAWN_HOLD_RADIUS = 80
local NEARBY_DESPAWN_HOLD_HOURS = 0.25

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

local function isRegistryNearActivePlayer(registry, radius)
    if not registry or not DTNPCManager.GetActivePlayers then return false end

    local rx = registry.lastX or (registry.homeCoords and registry.homeCoords.x)
    local ry = registry.lastY or (registry.homeCoords and registry.homeCoords.y)
    local rz = registry.lastZ or (registry.homeCoords and registry.homeCoords.z) or 0
    if not rx or not ry then return false end

    local maxDist = radius or NEARBY_DESPAWN_HOLD_RADIUS
    for _, player in ipairs(DTNPCManager.GetActivePlayers()) do
        if math.abs(player:getZ() - rz) <= 1 then
            local dx = player:getX() - rx
            local dy = player:getY() - ry
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= maxDist then
                return true
            end
        end
    end

    return false
end

local function shouldDelayNearbyDespawn(uuid, registry)
    local zombie = DTNPCServerCore and DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(uuid) or nil
    if zombie and isVisibleToActivePlayer(zombie, NEARBY_DESPAWN_HOLD_RADIUS) then
        return true
    end

    return isRegistryNearActivePlayer(registry, NEARBY_DESPAWN_HOLD_RADIUS)
end

local function clearDepartureRuntime(npcData, keepStatusData)
    if not npcData then return end

    npcData.removalRequested = nil
    npcData.isMovingState = nil
    npcData.departureTargetX = nil
    npcData.departureTargetY = nil
    npcData.departureTargetZ = nil
    npcData.departureTravelHours = nil
    npcData.departureBlockedTicks = nil
    npcData.departureStuckLastX = nil
    npcData.departureStuckLastY = nil
    npcData.departureLastDirX = nil
    npcData.departureLastDirY = nil
    npcData.departureStartedAt = nil
    npcData.departureForceDespawnAt = nil
    npcData.departureTimeoutVisibleLogged = nil

    if not keepStatusData then
        npcData.requestedReturnStatus = nil
    end
end

function DTNPCManager.GetDepartureVisibleHours(travelHours)
    local configured = SandboxVars
        and SandboxVars.DynamicTrading
        and SandboxVars.DynamicTrading.NPCDepartureVisibleHours

    if configured and configured > 0 then
        return configured
    end

    local requested = tonumber(travelHours) or DEFAULT_DEPARTURE_VISIBLE_HOURS
    if requested <= 0 then
        requested = DEFAULT_DEPARTURE_VISIBLE_HOURS
    end

    return math.max(0.01, math.min(requested, DEFAULT_DEPARTURE_VISIBLE_HOURS))
end

function DTNPCManager.CompleteLiveDeparture(uuid, npcData, zombie, reason)
    if not uuid then return false end

    npcData = npcData
        or (DTNPCManager.Data and DTNPCManager.Data[uuid])
        or (DynamicTrading_Roster and DynamicTrading_Roster.GetSoul(uuid))
    if not npcData then return false end

    local currentHours = getGameTime():getWorldAgeHours()
    local nextStatus = npcData.returnStatus or npcData.requestedReturnStatus or "Resting"
    local returnTime = npcData.returnTime

    if returnTime == nil or returnTime <= 0 then
        local travelHours = npcData.departureTravelHours or 0
        returnTime = currentHours + travelHours
    end

    npcData.status = "Away"
    npcData.returnTime = returnTime
    npcData.returnStatus = nextStatus
    npcData.state = "Idle"

    clearDepartureRuntime(npcData)

    if DynamicTrading_Roster then
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
    end

    if DTNPCManager.RespawnDebug and DTNPCManager.RespawnDebug.Log then
        DTNPCManager.RespawnDebug.Log(
            "departure_complete_" .. tostring(uuid),
            "Process=departure_complete uuid=" .. tostring(uuid) ..
                " name=" .. tostring(npcData.name or uuid) ..
                " reason=" .. tostring(reason or "unknown") ..
                " status=Away returnTime=" .. tostring(returnTime) ..
                " returnStatus=" .. tostring(nextStatus),
            true
        )
    end

    if DTNPCManager.RemoveData then
        DTNPCManager.RemoveData(uuid, "Away", returnTime, nextStatus)
    end

    zombie = zombie
        or (DTNPCServerCore
            and DTNPCServerCore.FindZombieByUUID
            and DTNPCServerCore.FindZombieByUUID(uuid))

    if zombie then
        zombie:removeFromWorld()
        zombie:removeFromSquare()
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Departure",
        "Completed live departure for " .. (npcData.name or uuid) ..
            " (" .. tostring(reason or "unknown") .. ")"
    )

    return true
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

    local currentHours = getGameTime():getWorldAgeHours()
    local awayReturnTime = currentHours + (travelHours or 0)
    local nextStatus = requestedReturnStatus or "Resting"
    local departureForceDespawnAt = currentHours + DTNPCManager.GetDepartureVisibleHours(travelHours)

    npcData.status = "Away"
    npcData.returnTime = awayReturnTime
    npcData.returnStatus = nextStatus
    npcData.state = "Departure"
    npcData.requestedReturnStatus = nextStatus
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
    npcData.departureStartedAt = currentHours
    npcData.departureForceDespawnAt = departureForceDespawnAt
    npcData.departureTimeoutVisibleLogged = nil

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

    if DTNPCManager.RespawnDebug and DTNPCManager.RespawnDebug.Log then
        DTNPCManager.RespawnDebug.Log(
            "departure_start_" .. tostring(uuid),
            "Process=departure_start uuid=" .. tostring(uuid) ..
                " name=" .. tostring(npcData.name or uuid) ..
                " nextStatus=" .. tostring(nextStatus) ..
                " awayReturnTime=" .. tostring(awayReturnTime) ..
                " forceDespawnAt=" .. tostring(departureForceDespawnAt) ..
                " target=" .. tostring(targetX) .. "," .. tostring(targetY) .. "," .. tostring(targetZ or 0),
            true
        )
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Departure",
        "Started live departure for " .. (npcData.name or uuid) ..
            " toward " .. tostring(nextStatus) ..
            " (logical status now Away)"
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
        local handledDepartureRecovery = false

        if isDeparting and liveSoul then
            local departureForceDespawnAt = liveSoul.departureForceDespawnAt
            local shouldForceDeparture = departureForceDespawnAt and currentHours >= departureForceDespawnAt
            local shouldRecoverLegacyTrading = registry.status == "Trading"
                and registry.returnTime
                and currentHours >= (registry.returnTime + STALE_TRADING_RECOVERY_GRACE_HOURS)

            if shouldForceDeparture or shouldRecoverLegacyTrading then
                local zombie = DTNPCServerCore and DTNPCServerCore.FindZombieByUUID
                    and DTNPCServerCore.FindZombieByUUID(uuid) or nil
                local reason = shouldForceDeparture and "timeout_backstop" or "legacy_trading_recovery"

                if DTNPCManager.RespawnDebug and DTNPCManager.RespawnDebug.Log then
                    DTNPCManager.RespawnDebug.Log(
                        "departure_force_" .. tostring(uuid),
                        "Process=departure_force uuid=" .. tostring(uuid) ..
                            " name=" .. tostring(liveSoul.name or registry.name or uuid) ..
                            " reason=" .. tostring(reason) ..
                            " currentHours=" .. tostring(currentHours) ..
                            " forceDespawnAt=" .. tostring(departureForceDespawnAt) ..
                            " registryStatus=" .. tostring(registry.status) ..
                            " registryReturnTime=" .. tostring(registry.returnTime),
                        true
                    )
                end

                DTNPCManager.CompleteLiveDeparture(uuid, liveSoul, zombie, reason)
                handledDepartureRecovery = true
            end
        end

        if not handledDepartureRecovery
            and not isDeparting
            and (registry.status == "Away" or registry.status == "Trading")
            and registry.returnTime then
            if currentHours >= registry.returnTime then
                local nextStatus = registry.returnStatus or "Resting"
                local newReturnTime = 0
                local newReturnStatus = nil
                local shouldApplyStatus = true

                if registry.status == "Trading" and nextStatus ~= "Trading" then
                    local npcData = DynamicTrading_Roster.GetSoul(uuid)
                    local home = npcData and npcData.homeCoords or nil
                    local walkHours = SandboxVars.DynamicTrading.NPCTradingWalkHours or 1.0
                    if home and DTNPCManager.TryStartLiveDeparture(uuid, "Resting", walkHours, home.x, home.y, home.z or 0) then
                        shouldApplyStatus = false
                    elseif shouldDelayNearbyDespawn(uuid, registry) then
                        local heldUntil = currentHours + NEARBY_DESPAWN_HOLD_HOURS
                        DynamicTrading.Log(
                            "DTV2",
                            "NPC",
                            "Logic",
                            "Delaying despawn for nearby trader " .. (registry.name or uuid) ..
                                " until " .. tostring(heldUntil)
                        )
                        DTNPCManager.SetNPCStatus(uuid, "Trading", heldUntil, nextStatus)
                        shouldApplyStatus = false
                    end
                end

                if shouldApplyStatus then
                    DynamicTrading.Log("DTV2", "NPC", "Logic", "Away Transition TIMER EXPIRED for " .. (registry.name or uuid) .. ". Target: " .. nextStatus)
                end

                if shouldApplyStatus and nextStatus == "Trading" then
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

                if shouldApplyStatus and nextStatus == "Resting" then
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
                elseif shouldApplyStatus and nextStatus == "Away" then
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

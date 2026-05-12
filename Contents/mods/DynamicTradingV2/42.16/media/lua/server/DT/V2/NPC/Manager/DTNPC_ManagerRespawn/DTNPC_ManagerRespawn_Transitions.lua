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

DTNPCManager.COLONY_RECRUITMENT_RETURN_STATUS = DTNPCManager.COLONY_RECRUITMENT_RETURN_STATUS or "ColonyRecruitment"

function DTNPCManager.IsColonyRecruitmentReturnStatus(returnStatus)
    return tostring(returnStatus or "") == tostring(DTNPCManager.COLONY_RECRUITMENT_RETURN_STATUS or "ColonyRecruitment")
end

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

local function getContactRequesterPlayer(npcData)
    if not npcData then
        return nil
    end

    local requesterID = npcData.contactVisitRequestedByID
    if requesterID ~= nil and getPlayerByOnlineID then
        local byID = getPlayerByOnlineID(requesterID)
        if byID then
            return byID
        end
    end

    local requesterName = tostring(npcData.contactVisitRequestedBy or "")
    if requesterName == "" then
        return nil
    end

    local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil
    if onlinePlayers then
        for index = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(index)
            if player and player.getUsername and tostring(player:getUsername() or "") == requesterName then
                return player
            end
        end
    end

    return nil
end

local function notifyV1ContactArrival(uuid, npcData)
    if not npcData then
        return
    end

    local requester = getContactRequesterPlayer(npcData)
    if not requester then
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Warn",
            "V1 contact arrival could not resolve requester for " .. tostring(npcData.name or uuid)
                .. " requesterName=" .. tostring(npcData.contactVisitRequestedBy)
                .. " requesterID=" .. tostring(npcData.contactVisitRequestedByID)
        )
        return
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Logic",
        "Notifying V1 contact arrival for " .. tostring(npcData.name or uuid)
            .. " requester=" .. tostring(requester.getUsername and requester:getUsername() or "unknown")
            .. " returnTime=" .. tostring(npcData.returnTime)
            .. " returnStatus=" .. tostring(npcData.returnStatus)
    )

    if DynamicTrading and DynamicTrading.ServerHelpers and DynamicTrading.ServerHelpers.SendResponse then
        DynamicTrading.ServerHelpers.SendResponse(requester, "DynamicTrading", "ScanResult", {
            status = "SUCCESS",
            targetUser = requester.getUsername and requester:getUsername() or nil,
            id = uuid,
            name = npcData.name or "Unknown Trader",
            source = "ContactVisitV1",
            traderStatus = npcData.status,
            traderState = npcData.state,
            returnTime = npcData.returnTime,
            returnStatus = npcData.returnStatus,
            contactVisitActive = npcData.contactVisitActive,
            contactVisitMode = npcData.contactVisitMode,
            contactVisitBackend = npcData.contactVisitBackend,
        })
    end
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
    npcData.departureMode = nil
    npcData.departureTimeoutVisibleLogged = nil
    npcData.departureRecruitModeLogged = nil
    npcData.departureRecruitObserverLostLogged = nil
    npcData.departureRecruitFallbackLogged = nil
    npcData.departureRecruitNoDirectionLogged = nil

    if not keepStatusData then
        npcData.requestedReturnStatus = nil
    end
end

local function setRecruitmentDepartureDirection(zombie, npcData)
    if not zombie or not npcData or not DTNPCManager.GetActivePlayers then
        return false
    end

    local nearestPlayer = nil
    local nearestDist = nil
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()

    for _, player in ipairs(DTNPCManager.GetActivePlayers()) do
        if math.abs((player:getZ() or 0) - zz) <= 1 then
            local dx = zx - player:getX()
            local dy = zy - player:getY()
            local dist = math.sqrt(dx * dx + dy * dy)
            if not nearestDist or dist < nearestDist then
                nearestPlayer = player
                nearestDist = dist
            end
        end
    end

    local dirX = nil
    local dirY = nil

    if nearestPlayer and nearestDist and nearestDist > 0.001 then
        dirX = (zx - nearestPlayer:getX()) / nearestDist
        dirY = (zy - nearestPlayer:getY()) / nearestDist
        npcData.master = nearestPlayer.getUsername and nearestPlayer:getUsername() or npcData.master
        npcData.masterID = nearestPlayer.getOnlineID and nearestPlayer:getOnlineID() or npcData.masterID
    elseif npcData.departureTargetX and npcData.departureTargetY then
        local dx = npcData.departureTargetX - zx
        local dy = npcData.departureTargetY - zy
        local len = math.sqrt(dx * dx + dy * dy)
        if len > 0.001 then
            dirX = dx / len
            dirY = dy / len
        end
    end

    if not dirX or not dirY then
        return false
    end

    npcData.departureLastDirX = dirX
    npcData.departureLastDirY = dirY

    if DTNPCManager.RespawnDebug and DTNPCManager.RespawnDebug.Log then
        DTNPCManager.RespawnDebug.Log(
            "departure_recruit_seed_" .. tostring(npcData.uuid),
            "Process=departure_recruit_seed uuid=" .. tostring(npcData.uuid) ..
                " name=" .. tostring(npcData.name or npcData.uuid) ..
                " dir=" .. string.format("%.3f", dirX) .. "," .. string.format("%.3f", dirY) ..
                " nearestPlayerDist=" .. tostring(nearestDist) ..
                " master=" .. tostring(npcData.master) ..
                " masterID=" .. tostring(npcData.masterID) ..
                " target=" .. tostring(npcData.departureTargetX) .. "," .. tostring(npcData.departureTargetY) ..
                "," .. tostring(npcData.departureTargetZ or 0),
            true
        )
    end

    return true
end

local function finalizeRecruitmentDeparture(uuid, npcData)
    if not npcData or npcData.colonyRecruitmentRemoveSource ~= true then
        return false
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Departure",
        "Finalizing colony recruitment departure for " .. tostring(npcData.name or uuid)
            .. " uuid=" .. tostring(uuid)
            .. " pending=" .. tostring(npcData.colonyRecruitmentPending == true)
    )

    if npcData.colonyRecruitmentPending == true then
        local completeRecruitment = DC_Colony
            and DC_Colony.Network
            and DC_Colony.Network.Internal
            and DC_Colony.Network.Internal.completePendingV2Recruitment
            or nil
        if completeRecruitment then
            local ok, completed = pcall(completeRecruitment, uuid, npcData, "departure_complete")
            if not ok then
                DynamicTrading.Log(
                    "DTV2",
                    "NPC",
                    "Departure",
                    "Colony recruitment completion failed for " .. tostring(uuid) .. ": " .. tostring(completed)
                )
            elseif completed ~= true then
                DynamicTrading.Log(
                    "DTV2",
                    "NPC",
                    "Departure",
                    "Colony recruitment completion returned false for " .. tostring(uuid)
                )
            else
                DynamicTrading.Log(
                    "DTV2",
                    "NPC",
                    "Departure",
                    "Colony recruitment completion succeeded for " .. tostring(uuid)
                )
            end
        else
            DynamicTrading.Log(
                "DTV2",
                "NPC",
                "Departure",
                "Colony recruitment completion hook missing for " .. tostring(uuid)
            )
        end
    end

    local factionID = npcData.colonyRecruitmentSourceFactionID or npcData.factionID
    local removed = false

    if DynamicTrading_Stock and DynamicTrading_Stock.ClearStock then
        DynamicTrading_Stock.ClearStock(uuid)
    end

    if DynamicTrading_Roster and DynamicTrading_Roster.RemoveSpecificSoul and DynamicTrading_Roster.RemoveSpecificSoul(uuid) then
        removed = true
    end

    if DynamicTrading_Roster and DynamicTrading_Roster.RemoveTrader and DynamicTrading_Roster.RemoveTrader(uuid) then
        removed = true
    end

    if removed and factionID and DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        local faction = DynamicTrading_Factions.GetFaction(factionID)
        if faction and not faction.playerOwned then
            faction.memberCount = math.max(0, (tonumber(faction.memberCount) or 0) - 1)
        end
    end

    if removed then
        ModData.transmit("DynamicTrading_Roster")
        ModData.transmit("DynamicTrading_Stock")
        if factionID then
            ModData.transmit("DynamicTrading_Factions")
        end
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Departure",
        "Colony recruitment source cleanup uuid=" .. tostring(uuid)
            .. " removed=" .. tostring(removed)
            .. " factionID=" .. tostring(factionID)
    )

    return removed
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
    local currentBodyInstanceID = npcData.currentBodyInstanceID
    local removalRevision = DTNPCManager.BumpPresenceRevision and DTNPCManager.BumpPresenceRevision(npcData) or npcData.presenceRevision

    if returnTime == nil or returnTime <= 0 then
        local travelHours = npcData.departureTravelHours or 0
        returnTime = currentHours + travelHours
    end

    npcData.status = "Away"
    npcData.returnTime = returnTime
    npcData.returnStatus = nextStatus
    npcData.state = "Idle"

    local isRecruitmentDeparture = npcData.colonyRecruitmentRemoveSource == true
        or DTNPCManager.IsColonyRecruitmentReturnStatus(nextStatus)
    clearDepartureRuntime(npcData)
    if DTNPCManager.ClearPhysicalBodyIdentity then
        DTNPCManager.ClearPhysicalBodyIdentity(npcData, currentBodyInstanceID)
    end

    if DynamicTrading_Roster and not isRecruitmentDeparture then
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
        if isRecruitmentDeparture then
            DTNPCManager.RemoveData(uuid, nil, nil, nil, {
                reason = "colony-recruitment",
                departureReason = reason,
                colonyRecruitment = true,
            })
        else
            DTNPCManager.RemoveData(uuid, "Away", returnTime, nextStatus)
        end
    end

    if isRecruitmentDeparture then
        finalizeRecruitmentDeparture(uuid, npcData)
    end

    if isRecruitmentDeparture
        and currentBodyInstanceID
        and DTNPCServerCore
        and DTNPCServerCore.NotifyInstanceRemoval then
        DTNPCServerCore.NotifyInstanceRemoval(uuid, currentBodyInstanceID, removalRevision)
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Departure",
            "Notified recruit body instance removal for " .. tostring(npcData.name or uuid)
                .. " bodyInstanceID=" .. tostring(currentBodyInstanceID)
        )
    end

    if (not isRecruitmentDeparture)
        and currentBodyInstanceID
        and DTNPCServerCore
        and DTNPCServerCore.NotifyInstanceRemoval then
        DTNPCServerCore.NotifyInstanceRemoval(uuid, currentBodyInstanceID, removalRevision)
    end

    zombie = zombie
        or (DTNPCServerCore
            and currentBodyInstanceID
            and DTNPCServerCore.FindZombieByBodyInstanceID
            and DTNPCServerCore.FindZombieByBodyInstanceID(currentBodyInstanceID))
        or (DTNPCServerCore
            and DTNPCServerCore.FindZombieByUUID
            and DTNPCServerCore.FindZombieByUUID(uuid))

    if zombie then
        zombie:removeFromWorld()
        zombie:removeFromSquare()
        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Departure",
            "Removed live body after departure for " .. tostring(npcData.name or uuid)
                .. " uuid=" .. tostring(uuid)
        )
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
        local town = nil
        if registry.factionID and DynamicTrading_Factions then
            local faction = DynamicTrading_Factions.GetFaction(registry.factionID)
            if faction and faction.town then
                town = faction.town
            end
        end

        if (not town or town == "" or town == "Wilderness") and registry.homeCoords and registry.homeCoords.town then
            town = registry.homeCoords.town
        end

        if (not town or town == "" or town == "Wilderness") and registry.homeCoords and DTM and DTM.GetTownName then
            local detected = DTM.GetTownName(registry.homeCoords.x, registry.homeCoords.y)
            if detected and detected ~= "Wilderness" then
                town = detected
            end
        end

        if DTM and DTM.Buildings then
            local townBuildings = {}
            local nearestBuilding = nil
            local nearestDistance = nil
            for _, building in ipairs(DTM.Buildings) do
                if town and (building.town == town or building.county == town) then
                    table.insert(townBuildings, building)
                end
                if registry.homeCoords and registry.homeCoords.x and registry.homeCoords.y and building.cx and building.cy then
                    local dx = registry.homeCoords.x - building.cx
                    local dy = registry.homeCoords.y - building.cy
                    local distance = (dx * dx) + (dy * dy)
                    if not nearestDistance or distance < nearestDistance then
                        nearestDistance = distance
                        nearestBuilding = building
                    end
                end
            end

            if #townBuildings > 0 then
                local targetBuilding = townBuildings[ZombRand(#townBuildings) + 1]
                targetX = targetBuilding.cx
                targetY = targetBuilding.cy
            elseif nearestBuilding then
                targetX = nearestBuilding.cx
                targetY = nearestBuilding.cy
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

    return DTNPCManager.StartLiveDepartureFromBody(
        uuid,
        zombie,
        npcData,
        requestedReturnStatus,
        travelHours,
        targetX,
        targetY,
        targetZ,
        nil
    )
end

function DTNPCManager.StartLiveDepartureFromBody(uuid, zombie, npcData, requestedReturnStatus, travelHours, targetX, targetY, targetZ, departureMode)
    if not uuid or not zombie or not npcData then
        return false
    end

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
    npcData.departureMode = departureMode
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
    if DTNPCManager.IsColonyRecruitmentReturnStatus(nextStatus) then
        setRecruitmentDepartureDirection(zombie, npcData)
    end
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
                local pendingArrival = liveSoul and liveSoul.pendingArrivalActivation or nil

                if type(pendingArrival) == "table" then
                    local retryAt = tonumber(pendingArrival.retryAt) or 0
                    if retryAt > currentHours then
                        shouldApplyStatus = false
                    end
                end

                if registry.status == "Trading" and nextStatus ~= "Trading" then
                    local npcData = DynamicTrading_Roster.GetSoul(uuid)
                    local home = npcData and npcData.homeCoords or nil
                    local walkHours = SandboxVars.DynamicTrading.NPCTradingWalkHours or 1.0
                    local isBanditRoamTrading = npcData and npcData.banditRoamActive == true or false
                    if isBanditRoamTrading and DTNPCManager.GetBanditHouseRoamTravelHours then
                        walkHours = DTNPCManager.GetBanditHouseRoamTravelHours()
                    end
                    if isBanditRoamTrading and DTNPCManager.ClearBanditHouseRoamState then
                        DTNPCManager.ClearBanditHouseRoamState(npcData)
                        DynamicTrading_Roster.SaveSoul(uuid, npcData)
                    end

                    if home and DTNPCManager.TryStartLiveDeparture(uuid, "Resting", walkHours, home.x, home.y, home.z or 0) then
                        shouldApplyStatus = false
                    elseif not isBanditRoamTrading and shouldDelayNearbyDespawn(uuid, registry) then
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
                        if DTNPCManager.ResolveScheduledTradeCycleMode and DTNPCManager.SetTradeCycleEncounterMode then
                            DTNPCManager.SetTradeCycleEncounterMode(
                                npcData,
                                DTNPCManager.ResolveScheduledTradeCycleMode(npcData, nil)
                            )
                        end
                        npcData.tradeCycleTargetPlayerUsername = nil
                        npcData.tradeCycleTargetPlayerOnlineID = nil

                        local stayHours = SandboxVars.DynamicTrading.NPCTradingStayHours or 4.0
                        newReturnTime = currentHours + stayHours
                        newReturnStatus = "Away"

                        DynamicTrading.Log("DTV2", "NPC", "Logic", "Session duration: " .. stayHours .. "h. Return Time: " .. newReturnTime)
                        DynamicTrading_Roster.SaveSoul(uuid, npcData)

                        if npcData.contactVisitActive == true and DTNPCServerCore and DTNPCServerCore.ActivateArrivalByUUID then
                            local visitBackend = string.upper(tostring(npcData.contactVisitBackend or ""))
                            local isV1Contact = visitBackend == "DYNAMICTRADINGV1" or visitBackend == "V1"
                            local activationMode = isV1Contact and "contact_trading" or "contact_follow"
                            local requestedState = isV1Contact and "Trading" or "Follow"

                            DynamicTrading.Log(
                                "DTV2",
                                "NPC",
                                "Logic",
                                "Resolving contact arrival uuid=" .. tostring(uuid)
                                    .. " backend=" .. tostring(visitBackend ~= "" and visitBackend or "DynamicTradingV2")
                                    .. " activationMode=" .. tostring(activationMode)
                                    .. " requester=" .. tostring(npcData.contactVisitRequestedBy)
                            )

                            local activated, _, activatedData, failureReason = DTNPCServerCore.ActivateArrivalByUUID(uuid, {
                                controller = {
                                    master = npcData.contactVisitRequestedBy,
                                    masterID = npcData.contactVisitRequestedByID,
                                },
                                targetUsername = npcData.contactVisitRequestedBy,
                                targetOnlineID = npcData.contactVisitRequestedByID,
                                targetX = npcData.contactVisitTargetX,
                                targetY = npcData.contactVisitTargetY,
                                targetZ = npcData.contactVisitTargetZ,
                                spawnPolicy = "offscreen_follow",
                                activationMode = activationMode,
                                state = requestedState,
                                status = "Trading",
                                returnTime = newReturnTime,
                                returnStatus = "Away",
                                requestedReturnStatus = nil,
                                invalidTargetBehavior = "return_home",
                            })

                            if activated then
                                shouldApplyStatus = false
                                if isV1Contact then
                                    notifyV1ContactArrival(uuid, activatedData or npcData)
                                end
                            elseif failureReason == "target_missing" then
                                shouldApplyStatus = false
                            else
                                shouldApplyStatus = false
                                DynamicTrading.Log(
                                    "DTV2",
                                    "NPC",
                                    "Arrival",
                                    "Queued contact arrival retry for " .. tostring(npcData.name or uuid)
                                        .. " reason=" .. tostring(failureReason or "unknown")
                                )
                            end
                        end
                    else
                        DynamicTrading.Log("DTV2", "NPC", "Logic", "WARNING: Unable to plan trading destination. Returning NPC to base.")
                        nextStatus = "Resting"
                    end
                elseif shouldApplyStatus and DTNPCManager.IsBanditHouseRoamReturnStatus
                    and DTNPCManager.IsBanditHouseRoamReturnStatus(nextStatus) then
                    local npcData = DynamicTrading_Roster.GetSoul(uuid)
                    if npcData and DTNPCManager.EnterBanditHouseRoamSite
                        and DTNPCManager.EnterBanditHouseRoamSite(uuid, npcData, currentHours) then
                        nextStatus = "Trading"
                        newReturnTime = npcData.returnTime or (currentHours + (DTNPCManager.GetBanditHouseRoamStayHours and DTNPCManager.GetBanditHouseRoamStayHours() or 6.0))
                        newReturnStatus = npcData.returnStatus or "Away"
                    else
                        DynamicTrading.Log("DTV2", "NPC", "Logic", "WARNING: Unable to enter bandit house-roam site. Returning NPC to base.")
                        if npcData and DTNPCManager.ClearBanditHouseRoamState then
                            DTNPCManager.ClearBanditHouseRoamState(npcData)
                            DynamicTrading_Roster.SaveSoul(uuid, npcData)
                        end
                        nextStatus = "Resting"
                    end
                end

                if shouldApplyStatus and DTNPCManager.IsColonyRecruitmentReturnStatus(nextStatus) then
                    local liveSoul = DynamicTrading_Roster.GetSoul(uuid) or registry
                    local zombie = DTNPCServerCore and DTNPCServerCore.FindZombieByUUID
                        and DTNPCServerCore.FindZombieByUUID(uuid) or nil
                    DTNPCManager.CompleteLiveDeparture(uuid, liveSoul, zombie, "colony_recruitment_recovery")
                    shouldApplyStatus = false
                elseif shouldApplyStatus and nextStatus == "Resting" then
                    DynamicTrading.Log("DTV2", "NPC", "Logic", "NPC " .. (registry.name or uuid) .. " transitioning to Home (Resting).")
                    local npcData = DynamicTrading_Roster.GetSoul(uuid)
                    if npcData and npcData.homeCoords then
                        npcData.lastX = npcData.homeCoords.x
                        npcData.lastY = npcData.homeCoords.y
                        npcData.lastZ = npcData.homeCoords.z or 0
                        npcData.travelTarget = nil
                        if DTNPCManager.ClearTradeCycleEncounterState then
                            DTNPCManager.ClearTradeCycleEncounterState(npcData)
                        end
                        if DTNPCManager.ClearBanditHouseRoamState then
                            DTNPCManager.ClearBanditHouseRoamState(npcData)
                        end
                        newReturnTime = 0
                        newReturnStatus = nil
                        DynamicTrading_Roster.SaveSoul(uuid, npcData)
                    end
                elseif shouldApplyStatus and nextStatus == "Away" then
                    DynamicTrading.Log("DTV2", "NPC", "Logic", "NPC " .. (registry.name or uuid) .. " mission ended. Transitioning to Away (Walking Home).")
                    local npcData = DynamicTrading_Roster.GetSoul(uuid)
                    if npcData then
                        local walkHours = SandboxVars.DynamicTrading.NPCTradingWalkHours or 1.0
                        if npcData.banditRoamActive == true and DTNPCManager.GetBanditHouseRoamTravelHours then
                            walkHours = DTNPCManager.GetBanditHouseRoamTravelHours()
                        end
                        local home = npcData.homeCoords
                        if home and DTNPCManager.TryStartLiveDeparture(uuid, "Resting", walkHours, home.x, home.y, home.z or 0) then
                            shouldApplyStatus = false
                        else
                            if DTNPCManager.ClearTradeCycleEncounterState then
                                DTNPCManager.ClearTradeCycleEncounterState(npcData)
                            end
                            if DTNPCManager.ClearBanditHouseRoamState then
                                DTNPCManager.ClearBanditHouseRoamState(npcData)
                            end
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

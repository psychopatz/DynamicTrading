-- ==============================================================================
-- DTNPC_ServerCore_Arrival.lua
-- Shared abstract-to-live arrival activation for companion/contact/bandit flows.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}

if isClient() and not isServer() then return end

local function getCurrentHours()
    local gt = getGameTime and getGameTime() or nil
    return gt and gt:getWorldAgeHours() or 0
end

local function copyScalarOptions(source)
    local copy = {}
    local allowed = {
        "activationMode",
        "spawnPolicy",
        "targetUsername",
        "targetOnlineID",
        "targetX",
        "targetY",
        "targetZ",
        "minRadius",
        "maxRadius",
        "searchRadius",
        "status",
        "state",
        "returnTime",
        "returnStatus",
        "requestedReturnStatus",
        "combatOrder",
        "guardCombatOrder",
        "guardAttackMode",
        "invalidTargetBehavior",
    }
    local index = 1
    while index <= #allowed do
        local key = allowed[index]
        copy[key] = source[key]
        index = index + 1
    end
    copy.retryCount = math.max(0, tonumber(source.retryCount) or 0)
    return copy
end

local function getActivePlayers()
    if DTNPCManager and DTNPCManager.GetActivePlayers then
        return DTNPCManager.GetActivePlayers()
    end
    return {}
end

local function findPlayerByIdentity(username, onlineID)
    local players = getActivePlayers()
    local wantedName = username and tostring(username) or nil
    local wantedID = onlineID ~= nil and tonumber(onlineID) or nil
    local index = 1
    while index <= #players do
        local player = players[index]
        if player then
            local playerID = player.getOnlineID and player:getOnlineID() or nil
            local playerName = player.getUsername and player:getUsername() or nil
            if wantedID ~= nil and playerID ~= nil and tonumber(playerID) == wantedID then
                return player
            end
            if wantedName and wantedName ~= "" and playerName and tostring(playerName) == wantedName then
                return player
            end
        end
        index = index + 1
    end
    return nil
end

local function getWalkHours()
    return tonumber(SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingWalkHours or 1.0) or 1.0
end

local function saveSoul(uuid, npcData)
    if uuid and npcData and DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul then
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
    end
end

local function updateSoulStatus(uuid, status, returnTime, returnStatus)
    if uuid and DynamicTrading_Roster and DynamicTrading_Roster.UpdateSoulStatus then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
    end
end

local function clearCombatAndTaskState(npcData)
    npcData.tasks = {}
    npcData.combatTargetID = nil
    npcData.combatOrder = nil
    npcData.guardCombatOrder = nil
    npcData.guardAttackMode = nil
    npcData.guardReturningToPost = nil
    npcData.anchorX = nil
    npcData.anchorY = nil
    npcData.anchorZ = nil
    npcData.stationaryPostX = nil
    npcData.stationaryPostY = nil
    npcData.stationaryPostZ = nil
    npcData.stationaryPostState = nil
end

function DTNPCServerCore.ClearPendingArrival(npcData)
    if type(npcData) ~= "table" then
        return npcData
    end
    npcData.pendingArrivalActivation = nil
    return npcData
end

local function queuePendingArrival(uuid, npcData, options, reason)
    if not uuid or type(npcData) ~= "table" then
        return
    end

    local retryCount = math.max(0, tonumber(options and options.retryCount) or 0) + 1
    local backoffHours = math.min(0.10, 0.01 * retryCount)
    local spec = copyScalarOptions(options or {})
    spec.retryCount = retryCount
    spec.retryReason = tostring(reason or "retry")
    spec.retryAt = getCurrentHours() + backoffHours
    npcData.pendingArrivalActivation = spec
    saveSoul(uuid, npcData)
end

local function resolveArrivalTarget(options, npcData)
    options = type(options) == "table" and options or {}

    local player = nil
    if options.targetPlayer and options.targetPlayer.getUsername then
        player = options.targetPlayer
    end

    local targetUsername = tostring(options.targetUsername or "")
    local targetOnlineID = options.targetOnlineID ~= nil and tonumber(options.targetOnlineID) or nil

    if not player and options.controller and DTNPCServerCore.ResolveControllerIdentity then
        local controllerName, controllerID = DTNPCServerCore.ResolveControllerIdentity(options.controller)
        if targetUsername == "" then
            targetUsername = controllerName or targetUsername
        end
        if targetOnlineID == nil then
            targetOnlineID = controllerID
        end
        if options.controller.getUsername then
            player = options.controller
        end
    end

    if not player and targetUsername ~= "" then
        player = findPlayerByIdentity(targetUsername, targetOnlineID)
    elseif not player and targetOnlineID ~= nil then
        player = findPlayerByIdentity(nil, targetOnlineID)
    end

    if not player and npcData then
        local mode = tostring(options.activationMode or "")
        if mode == "contact_follow" or mode == "contact_trading" then
            player = findPlayerByIdentity(npcData.contactVisitRequestedBy, npcData.contactVisitRequestedByID)
            if player then
                targetUsername = player.getUsername and player:getUsername() or targetUsername
                targetOnlineID = player.getOnlineID and player:getOnlineID() or targetOnlineID
            end
        elseif mode == "companion_follow" then
            player = findPlayerByIdentity(npcData.master or npcData.dcCommanderUsername, npcData.masterID or npcData.dcCommanderOnlineID)
            if player then
                targetUsername = player.getUsername and player:getUsername() or targetUsername
                targetOnlineID = player.getOnlineID and player:getOnlineID() or targetOnlineID
            end
        end
    end

    local targetX = tonumber(options.targetX)
    local targetY = tonumber(options.targetY)
    local targetZ = tonumber(options.targetZ)

    if player then
        if targetUsername == "" then
            targetUsername = player.getUsername and player:getUsername() or ""
        end
        if targetOnlineID == nil then
            targetOnlineID = player.getOnlineID and player:getOnlineID() or nil
        end
        if targetX == nil then
            targetX = player:getX()
        end
        if targetY == nil then
            targetY = player:getY()
        end
        if targetZ == nil then
            targetZ = player:getZ()
        end
    end

    if targetX == nil and npcData then
        targetX = tonumber(npcData.contactVisitTargetX or npcData.departureTargetX or nil)
    end
    if targetY == nil and npcData then
        targetY = tonumber(npcData.contactVisitTargetY or npcData.departureTargetY or nil)
    end
    if targetZ == nil and npcData then
        targetZ = tonumber(npcData.contactVisitTargetZ or npcData.departureTargetZ or npcData.lastZ or 0)
    end

    if targetX == nil or targetY == nil then
        return nil
    end

    return {
        player = player,
        username = targetUsername ~= "" and targetUsername or nil,
        onlineID = targetOnlineID,
        x = targetX,
        y = targetY,
        z = tonumber(targetZ) or 0,
    }
end

local function chooseArrivalSquare(target, npcData, options)
    if not target then
        return nil, "target_missing"
    end

    options = type(options) == "table" and options or {}
    local policy = tostring(options.spawnPolicy or "nearby_follow")

    if policy == "offscreen_follow" and target.player and DTNPCServerCore.FindOffscreenArrivalSquare then
        local square = DTNPCServerCore.FindOffscreenArrivalSquare(target.player, npcData)
        if square then
            return square
        end
    elseif policy == "nearby_follow" and target.player and DTNPCServerCore.FindNearbyArrivalSquare then
        local square = DTNPCServerCore.FindNearbyArrivalSquare(
            target.player,
            tonumber(options.minRadius) or 2,
            tonumber(options.maxRadius) or 5
        )
        if square then
            return square
        end
    elseif (policy == "ambush" or policy == "site_anchor") and DTNPCServerCore.FindArrivalSquareNearCoords then
        local square = DTNPCServerCore.FindArrivalSquareNearCoords(
            target.x,
            target.y,
            target.z,
            tonumber(options.searchRadius) or 2
        )
        if square then
            return square
        end
    end

    if DTNPCServerCore.FindArrivalSquareNearCoords then
        local fallback = DTNPCServerCore.FindArrivalSquareNearCoords(
            target.x,
            target.y,
            target.z,
            tonumber(options.searchRadius) or 4
        )
        if fallback then
            return fallback
        end
    end

    if target.player and DTNPCServerCore.FindNearbyArrivalSquare then
        return DTNPCServerCore.FindNearbyArrivalSquare(target.player, 1, 6), "no_square"
    end

    return nil, "no_square"
end

local function clearContactVisitState(npcData)
    npcData.contactVisitActive = false
    npcData.contactVisitMode = nil
    npcData.contactVisitBackend = nil
    npcData.contactVisitRequestedBy = nil
    npcData.contactVisitRequestedByID = nil
    npcData.contactVisitTargetX = nil
    npcData.contactVisitTargetY = nil
    npcData.contactVisitTargetZ = nil
    npcData.contactVisitStartedAt = nil
    npcData.contactVisitReturnStatus = nil
end

local function sendContactHome(uuid, npcData)
    if not uuid or type(npcData) ~= "table" then
        return false
    end

    local currentHours = getCurrentHours()
    clearContactVisitState(npcData)
    npcData.master = nil
    npcData.masterID = nil
    npcData.status = "Away"
    npcData.state = "Idle"
    npcData.returnTime = currentHours + getWalkHours()
    npcData.returnStatus = "Resting"
    npcData.requestedReturnStatus = "Resting"
    npcData.travelTarget = nil
    clearCombatAndTaskState(npcData)
    DTNPCServerCore.ClearPendingArrival(npcData)
    updateSoulStatus(uuid, "Away", npcData.returnTime, "Resting")
    saveSoul(uuid, npcData)
    return true
end

local function applyActivationState(uuid, npcData, square, target, options)
    local mode = tostring(options.activationMode or "")
    local state = options.state
    local status = options.status

    npcData.lastX = square:getX()
    npcData.lastY = square:getY()
    npcData.lastZ = square:getZ()
    npcData.travelTarget = nil
    npcData.departureForceDespawnAt = nil
    npcData.departureStartedAt = nil
    npcData.departureTravelHours = nil
    npcData.departureTargetX = nil
    npcData.departureTargetY = nil
    npcData.departureTargetZ = nil
    npcData.departureBlockedTicks = nil
    npcData.departureStuckLastX = nil
    npcData.departureStuckLastY = nil
    npcData.departureTimeoutVisibleLogged = nil
    npcData.removalRequested = nil
    DTNPCServerCore.ClearPendingArrival(npcData)

    if options.clearTasks ~= false then
        clearCombatAndTaskState(npcData)
    end

    if mode == "contact_follow" then
        npcData.status = status or "Trading"
        npcData.state = state or "Follow"
        npcData.master = target and target.username or npcData.contactVisitRequestedBy or npcData.master
        npcData.masterID = target and target.onlineID or npcData.contactVisitRequestedByID or npcData.masterID
        npcData.contactVisitActive = true
        npcData.contactVisitMode = "Follow"
    elseif mode == "contact_trading" then
        npcData.status = status or "Trading"
        npcData.state = state or "Trading"
        npcData.master = nil
        npcData.masterID = nil
        npcData.contactVisitActive = true
        npcData.contactVisitMode = "Trading"
    elseif mode == "companion_follow" then
        npcData.status = status or "Working"
        npcData.state = state or "Follow"
        npcData.master = target and target.username or npcData.master
        npcData.masterID = target and target.onlineID or npcData.masterID
    elseif mode == "bandit_hostile" or mode == "bandit_demand" then
        npcData.status = status or "Working"
        npcData.state = state or "Follow"
        npcData.master = target and target.username or npcData.master
        npcData.masterID = target and target.onlineID or npcData.masterID
    elseif mode == "site_trading" then
        npcData.status = status or "Trading"
        npcData.state = state or "Trading"
        npcData.master = nil
        npcData.masterID = nil
    else
        if status ~= nil then
            npcData.status = status
        end
        if state ~= nil then
            npcData.state = state
        end
        if options.master ~= nil then
            npcData.master = options.master
        end
        if options.masterID ~= nil then
            npcData.masterID = options.masterID
        end
    end

    if options.returnTime ~= nil then
        npcData.returnTime = options.returnTime
    end
    if options.returnStatus ~= nil or options.returnStatus == false then
        npcData.returnStatus = options.returnStatus or nil
    end
    if options.requestedReturnStatus ~= nil or options.requestedReturnStatus == false then
        npcData.requestedReturnStatus = options.requestedReturnStatus or nil
    end
    if options.combatOrder ~= nil then
        npcData.combatOrder = options.combatOrder
    end
    if options.guardCombatOrder ~= nil then
        npcData.guardCombatOrder = options.guardCombatOrder
        npcData.guardAttackMode = options.guardCombatOrder
    elseif options.guardAttackMode ~= nil then
        npcData.guardAttackMode = options.guardAttackMode
        npcData.guardCombatOrder = options.guardAttackMode
    end

    saveSoul(uuid, npcData)
    updateSoulStatus(uuid, npcData.status, npcData.returnTime, npcData.returnStatus)
end

local function finalizeWorldIndex(uuid, zombie, npcData, reusedLiveBody)
    if not uuid or not zombie or not npcData then
        return
    end

    if reusedLiveBody == true then
        if DTNPC and DTNPC.AttachData then
            DTNPC.AttachData(zombie, npcData)
        end
        if DTNPC and DTNPC.ApplyVisuals then
            DTNPC.ApplyVisuals(zombie, npcData)
        end
        if DTNPCManager and DTNPCManager.Register then
            DTNPCManager.Register(zombie, npcData)
        end
        if DTNPCServerCore.SyncToAllClients then
            DTNPCServerCore.SyncToAllClients(zombie, npcData)
        end
    end

    if DTNPC_SpatialHash and DTNPC_SpatialHash.InsertNPC then
        DTNPC_SpatialHash.InsertNPC(uuid, npcData.lastX, npcData.lastY, npcData.lastZ or 0, nil)
    end
    if DTNPC_DistanceFrequency and DTNPC_DistanceFrequency.InitializeNPC then
        DTNPC_DistanceFrequency.InitializeNPC(uuid)
    end
    if DTNPCServerCore.BroadcastPosition then
        DTNPCServerCore.BroadcastPosition(zombie, npcData)
    end
end

local function materializeBodyAtSquare(uuid, npcData, square, options)
    local zombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(uuid) or nil

    if zombie and DTNPCServerCore.PruneDuplicateZombies then
        zombie = DTNPCServerCore.PruneDuplicateZombies(uuid, npcData, zombie, "arrival-live")
    end

    if zombie then
        zombie:setX(square:getX())
        zombie:setY(square:getY())
        zombie:setZ(square:getZ())
        zombie:setLastX(square:getX())
        zombie:setLastY(square:getY())
        if DTNPC and DTNPC.AttachData then
            DTNPC.AttachData(zombie, npcData)
        end
        if DTNPC and DTNPC.ApplyVisuals then
            DTNPC.ApplyVisuals(zombie, npcData)
        end
        if not zombie:isUseless() then
            zombie:setUseless(true)
        end
        return zombie, npcData, true
    end

    if DTNPCServerCore.RespawnNPC then
        local spawnedZombie, spawnedData = DTNPCServerCore.RespawnNPC(npcData, uuid)
        return spawnedZombie, spawnedData, false
    end

    return nil, npcData, false
end

function DTNPCServerCore.ActivateArrivalByUUID(uuid, options)
    if not uuid then
        return false, nil, nil, "unknown_uuid"
    end

    options = type(options) == "table" and options or {}
    local zombie = nil
    local npcData = nil
    if DTNPCServerCore.GetNPCDataByUUID then
        zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(uuid)
    end
    if not npcData then
        return false, nil, nil, "unknown_uuid"
    end

    local target = resolveArrivalTarget(options, npcData)
    if not target then
        if tostring(options.invalidTargetBehavior or "") == "return_home" then
            sendContactHome(uuid, npcData)
        else
            DTNPCServerCore.ClearPendingArrival(npcData)
            saveSoul(uuid, npcData)
        end
        return false, nil, npcData, "target_missing"
    end

    local square, squareReason = chooseArrivalSquare(target, npcData, options)
    options.targetUsername = options.targetUsername or target.username
    options.targetOnlineID = options.targetOnlineID or target.onlineID
    options.targetX = options.targetX or target.x
    options.targetY = options.targetY or target.y
    options.targetZ = options.targetZ or target.z
    if not square then
        queuePendingArrival(uuid, npcData, options, squareReason or "no_square")
        return false, nil, npcData, squareReason or "no_square"
    end

    applyActivationState(uuid, npcData, square, target, options)
    local reusedLiveBody = false
    zombie, npcData, reusedLiveBody = materializeBodyAtSquare(uuid, npcData, square, options)
    if not zombie or not npcData then
        queuePendingArrival(uuid, npcData or (DynamicTrading_Roster and DynamicTrading_Roster.GetSoul and DynamicTrading_Roster.GetSoul(uuid)) or nil, options, "respawn_failed")
        return false, nil, npcData, "respawn_failed"
    end

    finalizeWorldIndex(uuid, zombie, npcData, reusedLiveBody)
    return true, zombie, npcData, nil
end

function DTNPCServerCore.ProcessPendingArrivals()
    if not DynamicTrading_Roster or not DynamicTrading_Roster.GetSoulRegistry then
        return
    end

    local roster = ModData and ModData.get and ModData.get("DynamicTrading_Roster") or nil
    local souls = roster and roster.Souls or nil
    if type(souls) ~= "table" then
        return
    end

    local currentHours = getCurrentHours()
    for uuid, registrySoul in pairs(souls) do
        local liveSoul = DynamicTrading_Roster.GetSoul(uuid) or registrySoul
        local pending = liveSoul and liveSoul.pendingArrivalActivation or nil
        if type(pending) == "table" then
            local retryAt = tonumber(pending.retryAt) or 0
            if currentHours >= retryAt then
                local options = copyScalarOptions(pending)
                options.retryCount = pending.retryCount
                local ok, _, npcData, reason = DTNPCServerCore.ActivateArrivalByUUID(uuid, options)
                if not ok and npcData and reason ~= "target_missing" and reason ~= "unknown_uuid" then
                    local updatedPending = npcData.pendingArrivalActivation
                    if updatedPending and DynamicTrading and DynamicTrading.Log then
                        DynamicTrading.Log(
                            "DTV2",
                            "NPC",
                            "Arrival",
                            "Pending arrival retry failed for " .. tostring(uuid)
                                .. " mode=" .. tostring(options.activationMode)
                                .. " reason=" .. tostring(reason)
                                .. " retryCount=" .. tostring(updatedPending.retryCount)
                        )
                    end
                end
            end
        end
    end
end

-- ==============================================================================
-- DTNPC_ServerCoreArrival_State.lua
-- State transition helpers for DTNPC server arrival modules.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreArrival = DTNPCServerCoreArrival or {}
DTNPCServerCoreArrival.Internal = DTNPCServerCoreArrival.Internal or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreArrival.Internal

function DTNPCServerCore.ClearPendingArrival(npcData)
    if type(npcData) ~= "table" then
        return npcData
    end
    npcData.pendingArrivalActivation = nil
    return npcData
end

function Internal.ClearContactVisitState(npcData)
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

function Internal.SendContactHome(uuid, npcData)
    if not uuid or type(npcData) ~= "table" then
        return false
    end

    local currentHours = Internal.GetCurrentHours()
    Internal.ClearContactVisitState(npcData)
    npcData.master = nil
    npcData.masterID = nil
    npcData.status = "Away"
    npcData.state = "Idle"
    npcData.returnTime = currentHours + Internal.GetWalkHours()
    npcData.returnStatus = "Resting"
    npcData.requestedReturnStatus = "Resting"
    npcData.travelTarget = nil
    Internal.ClearCombatAndTaskState(npcData)
    DTNPCServerCore.ClearPendingArrival(npcData)
    Internal.UpdateSoulStatus(uuid, "Away", npcData.returnTime, "Resting")
    Internal.SaveSoul(uuid, npcData)
    return true
end

function Internal.ApplyActivationState(uuid, npcData, square, target, options)
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
    npcData.departureMode = nil
    npcData.departureBlockedTicks = nil
    npcData.departureStuckLastX = nil
    npcData.departureStuckLastY = nil
    npcData.departureTimeoutVisibleLogged = nil
    npcData.removalRequested = nil
    DTNPCServerCore.ClearPendingArrival(npcData)

    if options.clearTasks ~= false then
        Internal.ClearCombatAndTaskState(npcData)
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

    if npcData.linkedWorkerID ~= nil
        and npcData.dcCompanionActive ~= true
        and (npcData.state == nil or npcData.state == "" or npcData.state == "Idle")
        and mode ~= "companion_follow" then
        npcData.state = tostring(npcData.dcBehaviorState or "PlayerZone")
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

    Internal.SaveSoul(uuid, npcData)
    Internal.UpdateSoulStatus(uuid, npcData.status, npcData.returnTime, npcData.returnStatus)
end

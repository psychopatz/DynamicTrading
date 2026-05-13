-- ==============================================================================
-- DTNPC_ServerCoreArrival_Pending.lua
-- Pending activation and public entry points for DTNPC server arrival modules.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreArrival = DTNPCServerCoreArrival or {}
DTNPCServerCoreArrival.Internal = DTNPCServerCoreArrival.Internal or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreArrival.Internal

function Internal.QueuePendingArrival(uuid, npcData, options, reason)
    if not uuid or type(npcData) ~= "table" then
        return
    end

    local retryCount = math.max(0, tonumber(options and options.retryCount) or 0) + 1
    local backoffHours = math.min(0.10, 0.01 * retryCount)
    local spec = Internal.CopyScalarOptions(options or {})
    spec.retryCount = retryCount
    spec.retryReason = tostring(reason or "retry")
    spec.retryAt = Internal.GetCurrentHours() + backoffHours
    npcData.pendingArrivalActivation = spec
    Internal.SaveSoul(uuid, npcData)
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

    if npcData.incapState == "Active" or tostring(npcData.state or "") == "Incapacitated" then
        DTNPCServerCore.ClearPendingArrival(npcData)
        Internal.SaveSoul(uuid, npcData)

        if zombie and not zombie:isDead() then
            return true, zombie, npcData, "incapacitated_live_body"
        end

        DynamicTrading.Log(
            "DTV2",
            "NPC",
            "Arrival",
            "Skipped arrival activation for incapacitated NPC: "
                .. tostring(npcData.name or uuid)
                .. " uuid=" .. tostring(uuid)
                .. " bodyInstanceID=" .. tostring(npcData.currentBodyInstanceID)
        )
        return false, nil, npcData, "incapacitated"
    end

    local target = Internal.ResolveArrivalTarget(options, npcData)
    if not target then
        if tostring(options.invalidTargetBehavior or "") == "return_home" then
            Internal.SendContactHome(uuid, npcData)
        else
            DTNPCServerCore.ClearPendingArrival(npcData)
            Internal.SaveSoul(uuid, npcData)
        end
        return false, nil, npcData, "target_missing"
    end

    local square, squareReason = Internal.ChooseArrivalSquare(target, npcData, options)
    options.targetUsername = options.targetUsername or target.username
    options.targetOnlineID = options.targetOnlineID or target.onlineID
    options.targetX = options.targetX or target.x
    options.targetY = options.targetY or target.y
    options.targetZ = options.targetZ or target.z
    if not square then
        Internal.QueuePendingArrival(uuid, npcData, options, squareReason or "no_square")
        return false, nil, npcData, squareReason or "no_square"
    end

    Internal.ApplyActivationState(uuid, npcData, square, target, options)
    local reusedLiveBody = false
    zombie, npcData, reusedLiveBody = Internal.MaterializeBodyAtSquare(uuid, npcData, square, options)
    if not zombie or not npcData then
        Internal.QueuePendingArrival(
            uuid,
            npcData or (DynamicTrading_Roster and DynamicTrading_Roster.GetSoul and DynamicTrading_Roster.GetSoul(uuid)) or nil,
            options,
            "respawn_failed"
        )
        return false, nil, npcData, "respawn_failed"
    end

    Internal.FinalizeWorldIndex(uuid, zombie, npcData, reusedLiveBody)
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

    local currentHours = Internal.GetCurrentHours()
    for uuid, registrySoul in pairs(souls) do
        local liveSoul = DynamicTrading_Roster.GetSoul(uuid) or registrySoul
        local pending = liveSoul and liveSoul.pendingArrivalActivation or nil
        if type(pending) == "table" then
            local retryAt = tonumber(pending.retryAt) or 0
            if currentHours >= retryAt then
                local options = Internal.CopyScalarOptions(pending)
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

-- ==============================================================================
-- DTNPC_ServerCoreControl_SpawnHelpers.lua
-- Spawn and medical helpers for DTNPC server control.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreControl = DTNPCServerCoreControl or {}
DTNPCServerCoreControl.Internal = DTNPCServerCoreControl.Internal or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreControl.Internal

function DTNPCServerCore.SpawnOffscreenCompanionByUUID(uuid, controller)
    local normalizedUUID = Internal.NormalizeUUID(uuid)
    if not normalizedUUID or not controller or not DTNPCServerCore.RespawnNPC then
        return false, nil, nil
    end

    if DTNPCServerCore.ActivateArrivalByUUID then
        return DTNPCServerCore.ActivateArrivalByUUID(normalizedUUID, {
            controller = controller,
            targetPlayer = controller,
            spawnPolicy = "offscreen_follow",
            activationMode = "companion_follow",
            state = "Follow",
            status = "Working",
            returnTime = 0,
            returnStatus = nil,
        })
    end

    local zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(normalizedUUID)
    if zombie and npcData then
        return true, zombie, npcData
    end

    if not npcData then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "SpawnOffscreenCompanionByUUID for unknown UUID: " .. normalizedUUID)
        return false, nil, nil
    end

    local arrivalSquare = DTNPCServerCore.FindOffscreenArrivalSquare and DTNPCServerCore.FindOffscreenArrivalSquare(controller, npcData) or nil
    if not arrivalSquare then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Unable to find offscreen arrival square for companion: " .. normalizedUUID)
        return false, nil, npcData
    end

    npcData.lastX = arrivalSquare:getX()
    npcData.lastY = arrivalSquare:getY()
    npcData.lastZ = arrivalSquare:getZ()
    npcData.status = "Working"
    npcData.returnTime = 0
    npcData.returnStatus = nil
    npcData.travelTarget = nil
    npcData.requestedReturnStatus = nil

    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul then
        DynamicTrading_Roster.SaveSoul(normalizedUUID, npcData)
    end

    local spawnedZombie, spawnedData = DTNPCServerCore.RespawnNPC(npcData, normalizedUUID)
    if not spawnedZombie then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Failed to respawn offscreen companion: " .. normalizedUUID)
        return false, nil, spawnedData or npcData
    end

    return true, spawnedZombie, spawnedData or npcData
end

function DTNPCServerCore.StartPatchUpByUUID(uuid)
    local normalizedUUID = Internal.NormalizeUUID(uuid)
    if not normalizedUUID then
        return false, nil
    end

    local zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(normalizedUUID)
    if not zombie or not npcData or not DTNPCHealth or not DTNPCHealth.ForceEnterSelfBandage then
        return false, npcData
    end

    if DTNPCHealth.HasUsableBandageSupply and not DTNPCHealth.HasUsableBandageSupply(npcData) then
        if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
            DTNPCProtect.PushCompanionNotice(zombie, npcData, "I don't have any bandages or rags packed.", "warning")
        end
        return false, npcData
    end

    local entered = DTNPCHealth.ForceEnterSelfBandage(zombie, npcData, npcData.state or "Idle")
    if not entered and DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        DTNPCProtect.PushCompanionNotice(zombie, npcData, "I can't patch up right now.", "warning")
    end
    return entered == true, npcData
end

function DTNPCServerCore.SpawnNearbyCompanionByUUID(uuid, controller, minRadius, maxRadius)
    local normalizedUUID = Internal.NormalizeUUID(uuid)
    if not normalizedUUID or not controller or not DTNPCServerCore.RespawnNPC then
        return false, nil, nil
    end

    if DTNPCServerCore.ActivateArrivalByUUID then
        return DTNPCServerCore.ActivateArrivalByUUID(normalizedUUID, {
            controller = controller,
            targetPlayer = controller,
            spawnPolicy = "nearby_follow",
            activationMode = "companion_follow",
            state = "Follow",
            status = "Working",
            returnTime = 0,
            returnStatus = nil,
            minRadius = minRadius,
            maxRadius = maxRadius,
        })
    end

    local zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(normalizedUUID)
    if zombie and npcData then
        return true, zombie, npcData
    end

    if not npcData then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "SpawnNearbyCompanionByUUID for unknown UUID: " .. normalizedUUID)
        return false, nil, nil
    end

    local arrivalSquare = DTNPCServerCore.FindNearbyArrivalSquare and DTNPCServerCore.FindNearbyArrivalSquare(controller, minRadius, maxRadius) or nil
    if not arrivalSquare then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Unable to find nearby arrival square for companion: " .. normalizedUUID)
        return false, nil, npcData
    end

    npcData.lastX = arrivalSquare:getX()
    npcData.lastY = arrivalSquare:getY()
    npcData.lastZ = arrivalSquare:getZ()
    npcData.status = "Working"
    npcData.returnTime = 0
    npcData.returnStatus = nil
    npcData.travelTarget = nil
    npcData.requestedReturnStatus = nil

    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul then
        DynamicTrading_Roster.SaveSoul(normalizedUUID, npcData)
    end

    local spawnedZombie, spawnedData = DTNPCServerCore.RespawnNPC(npcData, normalizedUUID)
    if not spawnedZombie then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "Failed to respawn nearby companion: " .. normalizedUUID)
        return false, nil, spawnedData or npcData
    end

    return true, spawnedZombie, spawnedData or npcData
end

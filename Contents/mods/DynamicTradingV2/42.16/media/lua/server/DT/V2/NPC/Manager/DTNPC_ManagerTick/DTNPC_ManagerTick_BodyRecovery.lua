-- ==============================================================================
-- DTNPC_ManagerTick_BodyRecovery.lua
-- Shared helpers for saved-position checks and stale body cleanup.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

DTNPCManager.TickInternal = DTNPCManager.TickInternal or {}

local tickInternal = DTNPCManager.TickInternal

function tickInternal.GetSavedCoords(npcData)
    if not npcData then
        return nil, nil, nil
    end

    return npcData.lastX or (npcData.homeCoords and npcData.homeCoords.x),
        npcData.lastY or (npcData.homeCoords and npcData.homeCoords.y),
        npcData.lastZ or (npcData.homeCoords and npcData.homeCoords.z) or 0
end

function tickInternal.IsZombieNearSavedCoords(zombie, npcData)
    if not zombie or not npcData then
        return false
    end

    local sx, sy, sz = tickInternal.GetSavedCoords(npcData)
    if not sx or not sy then
        return false
    end

    local dx = zombie:getX() - sx
    local dy = zombie:getY() - sy
    local dz = zombie:getZ() - sz
    return math.abs(dz) <= 1 and math.sqrt(dx * dx + dy * dy) <= 3.0
end

function tickInternal.FindZombieByBodyInstanceHint(bodyInstanceID)
    if not bodyInstanceID then
        return nil
    end

    if DTNPCServerCore and DTNPCServerCore.FindZombieByBodyInstanceID then
        return DTNPCServerCore.FindZombieByBodyInstanceID(bodyInstanceID)
    end

    local cell = getCell()
    local zombieList = cell and cell:getZombieList() or nil
    if not zombieList then
        return nil
    end

    local wanted = tostring(bodyInstanceID)
    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and not zombie:isDead() and tostring(zombie:getPersistentOutfitID()) == wanted then
            return zombie
        end
    end

    return nil
end

function tickInternal.RemoveStaleWorldBody(uuid, zombie, npcData, reason)
    if not zombie or zombie:isDead() then
        return false
    end

    local bodyInstanceID = zombie:getPersistentOutfitID()
    local removalRevision = DTNPCManager and DTNPCManager.BumpPresenceRevision and DTNPCManager.BumpPresenceRevision(npcData) or nil

    if DTNPCManager and DTNPCManager.ClearPhysicalBodyIdentity then
        DTNPCManager.ClearPhysicalBodyIdentity(npcData, bodyInstanceID)
    end
    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul and uuid and npcData then
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
    end
    if DTNPCManager and DTNPCManager.Save and DTNPCManager.Data and DTNPCManager.Data[uuid] then
        DTNPCManager.Save()
    end

    zombie:removeFromWorld()
    zombie:removeFromSquare()

    if bodyInstanceID and DTNPCServerCore and DTNPCServerCore.NotifyInstanceRemoval then
        DTNPCServerCore.NotifyInstanceRemoval(uuid, bodyInstanceID, removalRevision)
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Repair",
        "Removed stale world body for " .. tostring(npcData and (npcData.name or uuid) or uuid)
            .. " reason=" .. tostring(reason or "stale-world-body")
            .. " bodyInstanceID=" .. tostring(bodyInstanceID)
    )

    return true
end

-- ==============================================================================
-- DTNPC_ServerCoreCommands_SyncRepair.lua
-- World-body recovery helpers for DTNPC sync requests.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreCommands = DTNPCServerCoreCommands or {}
DTNPCServerCoreCommands.Internal = DTNPCServerCoreCommands.Internal or {}
DTNPCServerCoreCommands.Handlers = DTNPCServerCoreCommands.Handlers or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreCommands.Internal

function Internal.GetSoulCoords(soul)
    if not soul then
        return nil, nil, nil
    end

    return soul.lastX or (soul.homeCoords and soul.homeCoords.x),
        soul.lastY or (soul.homeCoords and soul.homeCoords.y),
        soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0
end

function Internal.IsZombieNearSoul(zombie, soul)
    if not zombie or not soul then
        return false
    end

    local sx, sy, sz = Internal.GetSoulCoords(soul)
    if not sx or not sy then
        return false
    end

    local dx = zombie:getX() - sx
    local dy = zombie:getY() - sy
    local dz = zombie:getZ() - sz
    return math.abs(dz) <= 1 and math.sqrt(dx * dx + dy * dy) <= 3
end

function Internal.TryReclaimZombieFromStartupHint(uuid, npcData, soul)
    if not uuid or not npcData or not DTNPCServerCore or not DTNPCManager then
        return nil
    end

    if DTNPCManager.IsPhysicalWorldStatus and not DTNPCManager.IsPhysicalWorldStatus(npcData.status, npcData) then
        return nil
    end

    local hintBodyInstanceID = npcData.startupBodyInstanceHint
    if not hintBodyInstanceID or not DTNPCServerCore.FindZombieByBodyInstanceID then
        return nil
    end

    local zombie = DTNPCServerCore.FindZombieByBodyInstanceID(hintBodyInstanceID)
    if not zombie and DTNPCServerCore.FindReusableWorldBody then
        zombie = DTNPCServerCore.FindReusableWorldBody(uuid, npcData, {
            allowPositionalMatch = true,
            positionRadius = 1.25,
        })
    end
    if not zombie or zombie:isDead() or not Internal.IsZombieNearSoul(zombie, soul or npcData) then
        return nil
    end

    local existingUUID = DTNPCManager.GetUUIDFromZombie and DTNPCManager.GetUUIDFromZombie(zombie) or nil
    if existingUUID and existingUUID ~= uuid then
        return nil
    end

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Adopt",
        "Reattached nearby startup body for " .. tostring(npcData.name or uuid)
            .. " using BodyInstanceID hint " .. tostring(hintBodyInstanceID)
    )

    if DTNPCManager.ReclaimZombie then
        return DTNPCManager.ReclaimZombie(zombie, npcData, "startup-hint")
    end

    DTNPCManager.Register(zombie, npcData)
    return zombie
end

function Internal.ShouldRecycleNearbyZombieForSync(zombie, uuid, npcData)
    if not zombie or zombie:isDead() or not uuid or not npcData then
        return false
    end

    local modData = zombie:getModData()
    if not modData then
        return true
    end

    local modUUID = modData.DTNPC_UUID
    if modUUID and tostring(modUUID) ~= tostring(uuid) then
        return false
    end

    local embeddedData = modData.DTNPC_Data or modData.DTNPCBrain
    local embeddedUUID = embeddedData and embeddedData.uuid or nil
    if embeddedUUID and tostring(embeddedUUID) ~= tostring(uuid) then
        return false
    end

    if modData.IsDTNPC ~= true then
        return true
    end

    if not embeddedData then
        return true
    end

    local visualID = tonumber(modData.DTNPCVisualID) or 0
    if visualID == 0 then
        return true
    end

    local expectedVisualID = tonumber(npcData.visualID) or 0
    if expectedVisualID ~= 0 and visualID ~= expectedVisualID then
        return true
    end

    return false
end

function Internal.RecycleNearbyZombieForSync(uuid, npcData, zombie, reason)
    if not zombie or zombie:isDead() or not uuid or not npcData or not DTNPCServerCore or not DTNPCServerCore.RespawnNPC then
        return zombie
    end

    local bodyInstanceID = zombie:getPersistentOutfitID()

    DynamicTrading.Log(
        "DTV2",
        "NPC",
        "Repair",
        "Recycling malformed nearby body for " .. tostring(npcData.name or uuid)
            .. " reason=" .. tostring(reason or "nearby-sync")
            .. " bodyInstanceID=" .. tostring(bodyInstanceID)
    )

    local removalRevision = DTNPCManager and DTNPCManager.BumpPresenceRevision and DTNPCManager.BumpPresenceRevision(npcData) or nil

    zombie:removeFromWorld()
    zombie:removeFromSquare()

    if bodyInstanceID and DTNPCServerCore.NotifyInstanceRemoval then
        DTNPCServerCore.NotifyInstanceRemoval(uuid, bodyInstanceID, removalRevision)
    end

    if DTNPCManager and DTNPCManager.ClearPhysicalBodyIdentity then
        DTNPCManager.ClearPhysicalBodyIdentity(npcData, bodyInstanceID)
    else
        if tostring(npcData.currentBodyInstanceID or "") == tostring(bodyInstanceID or "") then
            npcData.currentBodyInstanceID = nil
        end
        if tostring(npcData.startupBodyInstanceHint or "") == tostring(bodyInstanceID or "") then
            npcData.startupBodyInstanceHint = nil
        end
    end

    return DTNPCServerCore.RespawnNPC(npcData, uuid)
end

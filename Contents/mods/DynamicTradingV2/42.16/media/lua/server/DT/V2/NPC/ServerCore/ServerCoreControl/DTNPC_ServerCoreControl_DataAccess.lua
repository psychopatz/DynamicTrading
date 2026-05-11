-- ==============================================================================
-- DTNPC_ServerCoreControl_DataAccess.lua
-- Data access and persistence helpers for DTNPC server control.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreControl = DTNPCServerCoreControl or {}
DTNPCServerCoreControl.Internal = DTNPCServerCoreControl.Internal or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreControl.Internal

function Internal.NormalizeUUID(uuid)
    local text = uuid and tostring(uuid) or ""
    return text ~= "" and text or nil
end

function Internal.CopyLoadout(loadout)
    if DTNPCProtect and DTNPCProtect.CopyLoadout then
        return DTNPCProtect.CopyLoadout(loadout)
    end

    loadout = type(loadout) == "table" and loadout or {}
    return {
        rangedWeapon = loadout.rangedWeapon or nil,
        rangedAmmoType = loadout.rangedAmmoType or nil,
        ammoCount = math.max(0, tonumber(loadout.ammoCount) or 0),
        meleeWeapon = loadout.meleeWeapon or nil,
        bag = loadout.bag or nil,
        rangedCondition = loadout.rangedCondition ~= nil and math.max(0, math.floor(tonumber(loadout.rangedCondition) or 0)) or nil,
        meleeCondition = loadout.meleeCondition ~= nil and math.max(0, math.floor(tonumber(loadout.meleeCondition) or 0)) or nil,
    }
end

function Internal.LoadoutEquals(left, right)
    left = Internal.CopyLoadout(left)
    right = Internal.CopyLoadout(right)

    return left.rangedWeapon == right.rangedWeapon
        and left.rangedAmmoType == right.rangedAmmoType
        and left.ammoCount == right.ammoCount
        and left.meleeWeapon == right.meleeWeapon
        and left.bag == right.bag
        and left.rangedCondition == right.rangedCondition
        and left.meleeCondition == right.meleeCondition
end

function Internal.RemoveLiveNPCToStatus(uuid, zombie, npcData, status, returnTime, returnStatus)
    if not uuid or not npcData then
        return false
    end

    local bodyInstanceID = zombie and zombie.getPersistentOutfitID and zombie:getPersistentOutfitID() or npcData.currentBodyInstanceID
    local removalRevision = DTNPCManager and DTNPCManager.BumpPresenceRevision and DTNPCManager.BumpPresenceRevision(npcData) or npcData.presenceRevision

    npcData.status = status or npcData.status
    npcData.returnTime = returnTime
    npcData.returnStatus = returnStatus
    npcData.state = "Idle"
    npcData.master = nil
    npcData.masterID = nil
    npcData.combatOrder = nil
    npcData.tasks = {}
    npcData.requestedReturnStatus = nil
    npcData.travelTarget = nil
    if DTNPCManager and DTNPCManager.ClearPhysicalBodyIdentity then
        DTNPCManager.ClearPhysicalBodyIdentity(npcData, bodyInstanceID)
    end

    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul then
        DynamicTrading_Roster.SaveSoul(uuid, npcData)
    end

    if bodyInstanceID and DTNPCServerCore and DTNPCServerCore.NotifyInstanceRemoval then
        DTNPCServerCore.NotifyInstanceRemoval(uuid, bodyInstanceID, removalRevision)
    end

    if DTNPCManager and DTNPCManager.RemoveData then
        DTNPCManager.RemoveData(uuid, status, returnTime, returnStatus)
    end

    if not zombie and bodyInstanceID and DTNPCServerCore and DTNPCServerCore.FindZombieByBodyInstanceID then
        zombie = DTNPCServerCore.FindZombieByBodyInstanceID(bodyInstanceID)
    end

    if zombie then
        zombie:removeFromWorld()
        zombie:removeFromSquare()
    end

    return true
end

function DTNPCServerCore.GetNPCDataByUUID(uuid)
    local normalizedUUID = Internal.NormalizeUUID(uuid)
    if not normalizedUUID then
        return nil, nil
    end

    local zombie = DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(normalizedUUID) or nil
    local npcData = DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[normalizedUUID] or nil

    if not npcData and zombie and DTNPC and DTNPC.GetData then
        npcData = DTNPC.GetData(zombie)
    end
    if not npcData and DynamicTrading_Roster and DynamicTrading_Roster.GetSoul then
        npcData = DynamicTrading_Roster.GetSoul(normalizedUUID)
    end

    if npcData and DTNPCProtect and DTNPCProtect.EnsureDataDefaults then
        DTNPCProtect.EnsureDataDefaults(npcData)
    end

    return zombie, npcData
end

-- ==============================================================================
-- DTNPC_ServerCoreControl_Updates.lua
-- Update and persistence helpers for DTNPC server control.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreControl = DTNPCServerCoreControl or {}
DTNPCServerCoreControl.Internal = DTNPCServerCoreControl.Internal or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreControl.Internal

function Internal.SyncSpatialHash(uuid, npcData)
    if not uuid or type(npcData) ~= "table" then
        return
    end
    if not DTNPC_SpatialHash or not DTNPC_SpatialHash.InsertNPC then
        return
    end
    if tostring(npcData.status or "") == "Dead" then
        return
    end

    local x = tonumber(npcData.lastX or npcData.x or (npcData.homeCoords and npcData.homeCoords.x))
    local y = tonumber(npcData.lastY or npcData.y or (npcData.homeCoords and npcData.homeCoords.y))
    local z = tonumber(npcData.lastZ or npcData.z or (npcData.homeCoords and npcData.homeCoords.z) or 0)
    if x == nil or y == nil then
        return
    end

    DTNPC_SpatialHash.InsertNPC(tostring(uuid), x, y, z, nil)
end

function Internal.PersistNPCUpdate(uuid, zombie, npcData, shouldBroadcast)
    if not uuid or not npcData then
        return false
    end

    if DTNPCManager and DTNPCManager.Data then
        DTNPCManager.Data[tostring(uuid)] = npcData
    end

    if zombie and DTNPC and DTNPC.AttachData then
        DTNPC.AttachData(zombie, npcData)
    end

    if zombie and DTNPCManager and DTNPCManager.Register then
        DTNPCManager.Register(zombie, npcData)
    end

    if DTNPCManager and DTNPCManager.Save then
        DTNPCManager.Save()
    end
    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul then
        DynamicTrading_Roster.SaveSoul(tostring(uuid), npcData)
    end
    Internal.SyncSpatialHash(uuid, npcData)

    if zombie and DTNPCServerCore.SyncToAllClients then
        DTNPCServerCore.SyncToAllClients(zombie, npcData)
        if shouldBroadcast ~= false and DTNPCServerCore.BroadcastPosition then
            DTNPCServerCore.BroadcastPosition(zombie, npcData)
        end
    end

    return true
end

function DTNPCServerCore.UpdateNPCByUUID(uuid, updates, shouldBroadcast)
    if not uuid or type(updates) ~= "table" then
        return false, nil
    end

    local normalizedUUID = Internal.NormalizeUUID(uuid)
    if not normalizedUUID then
        return false, nil
    end

    local zombie, npcData = DTNPCServerCore.GetNPCDataByUUID(normalizedUUID)
    if not npcData then
        DynamicTrading.Log("DTV2", "NPC", "Warn", "UpdateNPCByUUID for unknown UUID: " .. normalizedUUID)
        return false, nil
    end

    local changed = false
    for key, value in pairs(updates) do
        if key ~= "broadcastPosition" then
            if key == "loadout" then
                local normalizedLoadout = Internal.CopyLoadout(value)
                if not Internal.LoadoutEquals(npcData.loadout, normalizedLoadout) then
                    npcData.loadout = normalizedLoadout
                    changed = true
                end
            elseif npcData[key] ~= value then
                npcData[key] = value
                changed = true
            end
        end
    end

    if not changed then
        Internal.SyncSpatialHash(normalizedUUID, npcData)
        return false, npcData
    end

    Internal.PersistNPCUpdate(normalizedUUID, zombie, npcData, shouldBroadcast)
    return true, npcData
end

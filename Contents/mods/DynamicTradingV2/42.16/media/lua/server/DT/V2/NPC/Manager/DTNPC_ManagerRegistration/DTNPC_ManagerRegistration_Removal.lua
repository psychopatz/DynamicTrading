-- ==============================================================================
-- DTNPC_ManagerRegistration_Removal.lua
-- Runtime removal and persistence cleanup.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

function DTNPCManager.RemoveData(uuid, status, returnTime, returnStatus, removalContext)
    if DTNPCManager.Data[uuid] then
        local npcData = DTNPCManager.Data[uuid]
        DTNPCManager.EnsurePresenceRevision(npcData)
        local notifiedRemovalReason = status
        if notifiedRemovalReason == nil then
            if type(removalContext) == "table" then
                notifiedRemovalReason = removalContext.reason or removalContext.removalReason
            elseif type(removalContext) == "string" then
                notifiedRemovalReason = removalContext
            end
        end

        if DTNPC_ZombieAggro and DTNPC_ZombieAggro.OnNPCRemoved then
            DTNPC_ZombieAggro.OnNPCRemoved(uuid)
        end

        local currentBodyInstanceID = npcData.currentBodyInstanceID
        if currentBodyInstanceID then
            DTNPCManager.BodyInstanceIDToUUID[currentBodyInstanceID] = nil
        end

        if status == "Away" or status == "Dead" then
            if DTNPCServerCore and DTNPCServerCore.ClearPendingArrival then
                DTNPCServerCore.ClearPendingArrival(npcData)
            end
            DTNPCManager.ClearPhysicalBodyIdentity(npcData, currentBodyInstanceID)
        end

        if DTNPC_SpatialHash and DTNPC_SpatialHash.RemoveNPC then
            DTNPC_SpatialHash.RemoveNPC(uuid)
        end

        if DTNPC_DistanceFrequency and DTNPC_DistanceFrequency.RemoveNPC then
            DTNPC_DistanceFrequency.RemoveNPC(uuid)
        end

        if DynamicTrading_Roster and status ~= nil then
            DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
        end

        DTNPCManager.Data[uuid] = nil
        DTNPCManager.PendingRegistrations[uuid] = nil
        if DTNPCManager.RespawnRuntime and DTNPCManager.RespawnRuntime.MissingBodies then
            DTNPCManager.RespawnRuntime.MissingBodies[uuid] = nil
        end
        DTNPCManager.Save()

        DynamicTrading.Log("DTV2", "NPC", "Remove", "Removed NPC data from world tracker: " .. (npcData.name or uuid) .. " (Status: " .. (status or "Removed") .. ")")

        if DTNPCServerCore and DTNPCServerCore.NotifyRemoval then
            local notifyContext = removalContext
            if type(notifyContext) ~= "table" then
                notifyContext = { reason = notifyContext }
            end
            notifyContext = notifyContext or {}
            notifyContext.presenceRevision = DTNPCManager.GetPresenceRevision(npcData)
            DTNPCServerCore.NotifyRemoval(uuid, currentBodyInstanceID, npcData.name, notifiedRemovalReason, notifyContext)
        end
    end
end

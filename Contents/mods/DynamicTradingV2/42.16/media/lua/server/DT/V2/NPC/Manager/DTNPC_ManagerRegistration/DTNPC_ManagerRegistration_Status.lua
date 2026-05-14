-- ==============================================================================
-- DTNPC_ManagerRegistration_Status.lua
-- Status transitions that require roster sync and possible world cleanup.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

function DTNPCManager.SetNPCStatus(uuid, status, returnTime, returnStatus)
    if DynamicTrading_Roster then
        DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
    end

    if status == "Away" or status == "Dead" then
        local npcData = (DTNPCManager.Data and DTNPCManager.Data[uuid])
            or (DynamicTrading_Roster and DynamicTrading_Roster.GetSoul and DynamicTrading_Roster.GetSoul(uuid))
            or nil
        local removalRevision = nil
        local staleBodyInstanceID = nil
        if npcData then
            staleBodyInstanceID = npcData.currentBodyInstanceID
            removalRevision = DTNPCManager.BumpPresenceRevision(npcData)
            if DTNPCServerCore and DTNPCServerCore.ClearPendingArrival then
                DTNPCServerCore.ClearPendingArrival(npcData)
            end
            DTNPCManager.ClearPhysicalBodyIdentity(npcData, staleBodyInstanceID)
            if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul then
                DynamicTrading_Roster.SaveSoul(uuid, npcData)
            end
            if DTNPCManager.Save and DTNPCManager.Data and DTNPCManager.Data[uuid] then
                DTNPCManager.Save()
            end
        end

        if staleBodyInstanceID and DTNPCServerCore and DTNPCServerCore.NotifyInstanceRemoval then
            DTNPCServerCore.NotifyInstanceRemoval(uuid, staleBodyInstanceID, removalRevision)
        end

        if DTNPCManager.Data[uuid] then
            DynamicTrading.Log("DTV2", "NPC", "Status", "Status change to " .. status .. " requires world removal.")
            DTNPCManager.RemoveData(uuid, status, returnTime, returnStatus)
        end

        if DTNPCServerCore then
            local zombie = nil
            if staleBodyInstanceID and DTNPCServerCore.FindZombieByBodyInstanceID then
                zombie = DTNPCServerCore.FindZombieByBodyInstanceID(staleBodyInstanceID)
            end
            if not zombie and DTNPCServerCore.FindZombieByUUID then
                zombie = DTNPCServerCore.FindZombieByUUID(uuid)
            end
            if zombie then
                zombie:removeFromWorld()
                zombie:removeFromSquare()
                DynamicTrading.Log("DTV2", "NPC", "Remove", "Forcefully removed physical zombie for Away/Dead state: " .. uuid)
            end
        end
    end
end

-- ==============================================================================
-- DTNPC_ManagerTick_StartupHints.lua
-- Reclaims startup body hints before the steady-state tick loop settles.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

DTNPCManager.TickInternal = DTNPCManager.TickInternal or {}

local tickInternal = DTNPCManager.TickInternal

function tickInternal.ProcessStartupBodyHints()
    if not DTNPCManager or not DTNPCManager.Data or not DTNPCManager.ReclaimZombie then
        return
    end

    for uuid, npcData in pairs(DTNPCManager.Data) do
        local hintBodyInstanceID = npcData and npcData.startupBodyInstanceHint or nil
        if hintBodyInstanceID and not npcData.currentBodyInstanceID and npcData.status ~= "Dead" then
            local zombie = tickInternal.FindZombieByBodyInstanceHint(hintBodyInstanceID)
            if zombie and not zombie:isDead() then
                if not (DTNPCManager.IsPhysicalWorldStatus and DTNPCManager.IsPhysicalWorldStatus(npcData.status, npcData)) then
                    tickInternal.RemoveStaleWorldBody(uuid, zombie, npcData, "startup-hint-away")
                elseif tickInternal.IsZombieNearSavedCoords(zombie, npcData) then
                    local existingUUID = DTNPCManager.GetUUIDFromZombie and DTNPCManager.GetUUIDFromZombie(zombie) or nil
                    if not existingUUID or existingUUID == uuid then
                        local modData = zombie:getModData()
                        if modData and not modData.DTNPC_UUID then
                            modData.DTNPC_UUID = uuid
                        end
                        if DTNPC and DTNPC.ApplyMarkedBodySafety then
                            DTNPC.ApplyMarkedBodySafety(zombie, npcData, {
                                suppressEngineState = true,
                                clearTarget = true,
                            })
                        end
                        DTNPCManager.ReclaimZombie(zombie, npcData, "startup-tick")
                    end
                end
            end
        end
    end
end

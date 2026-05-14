-- ==============================================================================
-- DTNPC_ManagerTick_Safety.lua
-- Applies safety flags to marked server zombies during engine updates.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

DTNPCManager.TickInternal = DTNPCManager.TickInternal or {}

local tickInternal = DTNPCManager.TickInternal

function tickInternal.ApplySafetyToMarkedServerZombie(zombie)
    if not zombie or zombie:isDead() then
        return
    end

    local modData = zombie:getModData()
    if not modData then
        return
    end

    local npcData = modData.DTNPC_Data or modData.DTNPCBrain
    local uuid = modData.DTNPC_UUID or (npcData and npcData.uuid) or nil

    if not (modData.IsDTNPC or uuid or npcData) then
        return
    end

    local savedData = (uuid and DTNPCManager.Data and DTNPCManager.Data[uuid]) or npcData
    if not savedData and uuid and DynamicTrading_Roster and DynamicTrading_Roster.GetSoul then
        savedData = DynamicTrading_Roster.GetSoul(uuid)
    end

    if DTNPC and DTNPC.ApplyMarkedBodySafety then
        DTNPC.ApplyMarkedBodySafety(zombie, savedData)
    elseif DTNPC and DTNPC.ApplySafetyFlags then
        DTNPC.ApplySafetyFlags(zombie, savedData, { clearPlayerTarget = true })
    elseif DTNPC and DTNPC.ApplyCharacterFlags then
        DTNPC.ApplyCharacterFlags(zombie, savedData)
    end
end

-- ==============================================================================
-- DTNPC_ManagerRegistration_Lifecycle.lua
-- Bridges manager APIs to lifecycle death/injury handlers.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

function DTNPCManager.ConvertDeathToIncapacitated(zombie, uuid, npcData, removalContext)
    return DTNPCLifecycle
        and DTNPCLifecycle.ConvertDeathToIncapacitated
        and DTNPCLifecycle.ConvertDeathToIncapacitated(zombie, uuid, npcData, removalContext)
        or false
end

function DTNPCManager.FinalizeIncapacitatedDeath(zombie, npcData, attacker)
    return DTNPCLifecycle
        and DTNPCLifecycle.FinalizeIncapacitatedDeath
        and DTNPCLifecycle.FinalizeIncapacitatedDeath(zombie, npcData, attacker)
        or false
end

function DTNPCManager.Unregister(zombie)
    if DTNPCLifecycle and DTNPCLifecycle.HandleZombieDead then
        DTNPCLifecycle.HandleZombieDead(zombie)
    end
end

if DTNPCLifecycle and DTNPCLifecycle.RegisterZombieDeadHandler then
    DTNPCLifecycle.RegisterZombieDeadHandler(DTNPCManager.Unregister)
elseif Events and Events.OnZombieDead then
    Events.OnZombieDead.Add(DTNPCManager.Unregister)
end

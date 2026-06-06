-- ==============================================================================
-- DTNPC_HealthShared_Persistence.lua
-- Sync and persistence helpers for DT NPC health.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

local internal = DTNPCHealth.Internal

local function syncHealth(zombie, npcData, fullSync)
    if not npcData or not npcData.uuid then
        return
    end
    if not DTNPCServerCore then
        return
    end

    local resolvedZombie = zombie
    local resolvedData = npcData
    if internal.resolveAuthoritativeNPCContext then
        resolvedZombie, resolvedData = internal.resolveAuthoritativeNPCContext(zombie, npcData)
    end
    if not resolvedData or not resolvedData.uuid then
        return
    end
    if not resolvedZombie and DTNPCServerCore.FindZombieByUUID then
        resolvedZombie = DTNPCServerCore.FindZombieByUUID(tostring(resolvedData.uuid))
    end
    if not resolvedZombie or not resolvedData then
        return
    end

    if fullSync == true and DTNPCServerCore.SyncToAllClients then
        DTNPCServerCore.SyncToAllClients(resolvedZombie, resolvedData)
    end
    if DTNPCServerCore.BroadcastState then
        DTNPCServerCore.BroadcastState(resolvedZombie, resolvedData, false)
    elseif DTNPCServerCore.BroadcastPosition then
        DTNPCServerCore.BroadcastPosition(resolvedZombie, resolvedData, true)
    end
end

internal.syncHealth = syncHealth

function DTNPCHealth.RequestSync(zombie, npcData, fullSync)
    syncHealth(zombie, npcData, fullSync)
end

local function persistHealthSnapshot(npcData, forceManagerSave)
    if not npcData or internal.isRemoteClient() then
        return
    end

    local combatHealth = DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if DynamicTrading_Roster and DynamicTrading_Roster.SaveSoul and npcData.uuid then
        DynamicTrading_Roster.SaveSoul(npcData.uuid, npcData)
    end
    internal.syncLinkedWorkerHealth(npcData)

    if not DTNPCManager or not DTNPCManager.Save then
        return
    end

    local now = internal.nowMillis()
    local lastPersistedAt = tonumber(combatHealth and combatHealth.lastPersistedAt) or 0
    if forceManagerSave == true or (now - lastPersistedAt) >= DTNPCHealth.HEALTH_PERSIST_INTERVAL_MS then
        if combatHealth then
            combatHealth.lastPersistedAt = now
        end
        DTNPCManager.Save()
    end
end

internal.persistHealthSnapshot = persistHealthSnapshot

local function syncAndPersistHealth(zombie, npcData, fullSync, forceManagerSave)
    syncHealth(zombie, npcData, fullSync)
    persistHealthSnapshot(npcData, forceManagerSave)
end

internal.syncAndPersistHealth = syncAndPersistHealth

-- ==============================================================================
-- DTNPC_Spawn.lua
-- Legacy compatibility shim. ServerCore is the canonical implementation.
-- ==============================================================================

require "DT/V2/NPC/ServerCore/DTNPC_ServerCore"

DTNPCSpawn = DTNPCSpawn or {}

if isClient() and not isServer() then return end

DTNPCSpawn.BROADCAST_RANGES = DTNPCServerCore.BROADCAST_RANGES

function DTNPCSpawn.SyncToAllClients(...)
    return DTNPCServerCore.SyncToAllClients(...)
end

function DTNPCSpawn.SyncToPlayer(...)
    return DTNPCServerCore.SyncToPlayer(...)
end

function DTNPCSpawn.BroadcastPosition(...)
    return DTNPCServerCore.BroadcastPosition(...)
end

function DTNPCSpawn.NotifyRemoval(...)
    return DTNPCServerCore.NotifyRemoval(...)
end

function DTNPCSpawn.SpawnNPC(...)
    return DTNPCServerCore.SpawnNPC(...)
end

function DTNPCSpawn.RespawnNPC(...)
    return DTNPCServerCore.RespawnNPC(...)
end

function DTNPCSpawn.FindZombieByUUID(...)
    return DTNPCServerCore.FindZombieByUUID(...)
end

function DTNPCSpawn.FindZombieByBodyInstanceID(...)
    return DTNPCServerCore.FindZombieByBodyInstanceID(...)
end

function DTNPCSpawn.SummonAll(...)
    return DTNPCServerCore.SummonAll(...)
end

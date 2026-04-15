-- ==============================================================================
-- DTNPC_Lifecycle_Events.lua
-- Guarded event hook helpers for lifecycle-owned zombie death handling.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}

function DTNPCLifecycle.RegisterZombieDeadHandler(handler)
    if not Events or not Events.OnZombieDead or not handler then
        return false
    end

    if DTNPCLifecycle.ZombieDeadHandler then
        Events.OnZombieDead.Remove(DTNPCLifecycle.ZombieDeadHandler)
    end

    DTNPCLifecycle.ZombieDeadHandler = handler
    Events.OnZombieDead.Add(handler)
    return true
end

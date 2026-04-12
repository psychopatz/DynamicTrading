-- ==============================================================================
-- DTNPC_ZombieAggro_Damage.lua
-- Damage application for leased zombies attacking DT NPCs.
-- ==============================================================================

DTNPC_ZombieAggro = DTNPC_ZombieAggro or {}
DTNPC_ZombieAggro._internal = DTNPC_ZombieAggro._internal or {}

local Internal = DTNPC_ZombieAggro._internal
local runtime = Internal.runtime

function DTNPC_ZombieAggro.TryApplyLeaseDamage(zombie, lease, targetEntry)
    if not zombie or not lease or not targetEntry then
        return false
    end

    local rt = runtime()
    local tick = DTNPC_ZombieAggro.GetCurrentTick()
    if (lease.nextDamageTick or 0) > tick then
        return false
    end

    local targetZombie = targetEntry.zombie
    local npcData = targetEntry.npcData
    if not targetZombie or targetZombie:isDead() or not npcData then
        return false
    end

    local dx = targetZombie:getX() - zombie:getX()
    local dy = targetZombie:getY() - zombie:getY()
    local distSq = (dx * dx) + (dy * dy)
    local hitRadius = DTNPC_ZombieAggro.CONFIG.HIT_RADIUS
    if distSq > (hitRadius * hitRadius) then
        return false
    end

    if zombie.faceLocation then
        zombie:faceLocation(targetZombie:getX(), targetZombie:getY())
    end

    if targetZombie.setAttackedBy then
        targetZombie:setAttackedBy(zombie)
    end

    lease.nextDamageTick = tick + DTNPC_ZombieAggro.CONFIG.HIT_COOLDOWN_TICKS
    rt.ZombieLeases[Internal.getZombieRuntimeID(zombie)] = lease

    local resolvedDamage = DTNPC_ZombieAggro.CONFIG.HIT_DAMAGE
    if DTNPCCombat and DTNPCCombat.ResolveZombieHit then
        local outcome = DTNPCCombat.ResolveZombieHit(targetZombie, npcData, zombie, resolvedDamage, {
            threatCount = npcData.zombieThreatCount,
        })
        if outcome and outcome.evaded == true then
            lease.nextDamageTick = tick + math.max(1, tonumber(outcome.cooldownTicks) or 1)
            rt.ZombieLeases[Internal.getZombieRuntimeID(zombie)] = lease
            return true
        end
        if outcome and outcome.damage then
            resolvedDamage = math.max(DTNPCHealth and DTNPCHealth.MIN_DAMAGE or 0.01, tonumber(outcome.damage) or resolvedDamage)
        end
    end

    if DTNPCHealth and DTNPCHealth.ApplyDamage then
        DTNPCHealth.ApplyDamage(targetZombie, npcData, resolvedDamage, zombie, {
            source = "zombie_lease",
            queueFallbackIgnore = false,
        })
        return true
    end

    return false
end

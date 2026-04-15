-- ==============================================================================
-- DTNPC_ZombieAggro_Debug.lua
-- Focused debug helpers for the zombie aggro module.
-- ==============================================================================

DTNPC_ZombieAggro = DTNPC_ZombieAggro or {}
DTNPC_ZombieAggro._internal = DTNPC_ZombieAggro._internal or {}

local Internal = DTNPC_ZombieAggro._internal
local runtime = Internal.runtime

function DTNPC_ZombieAggro.GetDebugStats()
    local rt = runtime()
    local threatCount = 0
    local leaseCount = 0
    local attackableCount = 0

    for _ in pairs(rt.NPCThreats or {}) do
        threatCount = threatCount + 1
    end

    for _ in pairs(rt.ZombieLeases or {}) do
        leaseCount = leaseCount + 1
    end

    for _ in pairs(rt.AttackableNPCs or {}) do
        attackableCount = attackableCount + 1
    end

    return {
        tick = rt.Tick or 0,
        threats = threatCount,
        leases = leaseCount,
        attackableNPCs = attackableCount,
    }
end

-- ==============================================================================
-- DTNPC_ZombieAggro_State.lua
-- Runtime state and lifecycle helpers for zombie aggro.
-- ==============================================================================

DTNPC_ZombieAggro = DTNPC_ZombieAggro or {}
DTNPC_ZombieAggro._internal = DTNPC_ZombieAggro._internal or {}

local Internal = DTNPC_ZombieAggro._internal

DTNPC_ZombieAggro.Runtime = DTNPC_ZombieAggro.Runtime or {
    Tick = 0,
    AttackableNPCGrid = {},
    AttackableNPCs = {},
    ZombieLeases = {},
    NPCThreats = {},
    NPCLeaseCounts = {},
}

local function runtime()
    DTNPC_ZombieAggro.Runtime = DTNPC_ZombieAggro.Runtime or {
        Tick = 0,
        AttackableNPCGrid = {},
        AttackableNPCs = {},
        ZombieLeases = {},
        NPCThreats = {},
        NPCLeaseCounts = {},
    }
    return DTNPC_ZombieAggro.Runtime
end

function DTNPC_ZombieAggro.ResetRuntime()
    local rt = runtime()
    rt.AttackableNPCGrid = {}
    rt.AttackableNPCs = {}
    rt.ZombieLeases = {}
    rt.NPCThreats = {}
    rt.NPCLeaseCounts = {}
end

function DTNPC_ZombieAggro.GetCurrentTick()
    return runtime().Tick or 0
end

function DTNPC_ZombieAggro.AdvanceTick()
    local rt = runtime()
    rt.Tick = (rt.Tick or 0) + 1
    return rt.Tick
end

function DTNPC_ZombieAggro.GetThreat(uuid)
    if not uuid then
        return nil
    end

    return runtime().NPCThreats[uuid]
end

function DTNPC_ZombieAggro.HasThreat(uuid)
    local threat = DTNPC_ZombieAggro.GetThreat(uuid)
    return threat ~= nil and (threat.attackerCount or 0) > 0
end

function DTNPC_ZombieAggro.ClearThreat(uuid)
    if not uuid then
        return
    end

    local rt = runtime()
    local npcData = DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] or nil
    rt.NPCThreats[uuid] = nil
    rt.NPCLeaseCounts[uuid] = nil

    for zombieID, lease in pairs(rt.ZombieLeases) do
        if lease and lease.npcUUID == uuid then
            rt.ZombieLeases[zombieID] = nil
        end
    end

    if npcData then
        npcData.zombieThreatCount = 0
        npcData.primaryZombieThreatID = nil
        npcData.lastZombieThreatAt = nil
    end
end

function DTNPC_ZombieAggro.OnNPCRemoved(uuid)
    DTNPC_ZombieAggro.ClearThreat(uuid)
end

function DTNPC_ZombieAggro.OnZombieInvalidated(zombieRuntimeID)
    if not zombieRuntimeID then
        return
    end

    runtime().ZombieLeases[zombieRuntimeID] = nil
end

Internal.runtime = runtime

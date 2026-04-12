-- ==============================================================================
-- DTNPC_ZombieAggro_Leases.lua
-- Lease assignment, refresh, and manager-tick orchestration.
-- ==============================================================================

DTNPC_ZombieAggro = DTNPC_ZombieAggro or {}
DTNPC_ZombieAggro._internal = DTNPC_ZombieAggro._internal or {}

local Internal = DTNPC_ZombieAggro._internal
local runtime = Internal.runtime

local function clearThreatSnapshot(uuid, tick)
    local rt = runtime()
    rt.NPCThreats[uuid] = nil
    rt.NPCLeaseCounts[uuid] = nil

    local npcData = DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] or nil
    if Internal.syncThreatMirror then
        Internal.syncThreatMirror(npcData, nil, tick)
    end
end

local function clearAllThreatSnapshots()
    local rt = runtime()
    local tick = DTNPC_ZombieAggro.GetCurrentTick()
    local previousThreats = rt.NPCThreats

    rt.NPCThreats = {}
    rt.NPCLeaseCounts = {}

    for uuid, _ in pairs(previousThreats) do
        clearThreatSnapshot(uuid, tick)
    end
end

local function getThreatEntry(uuid)
    local rt = runtime()
    local threat = rt.NPCThreats[uuid]
    if not threat then
        threat = {
            primaryZombieID = nil,
            primaryZombie = nil,
            primaryDistance = 9999,
            attackerCount = 0,
            lastRefreshTick = 0,
        }
        rt.NPCThreats[uuid] = threat
    end
    return threat
end

local function recordThreat(entry, zombie, distance)
    local uuid = entry and entry.uuid or nil
    if not uuid then
        return
    end

    local rt = runtime()
    local threat = getThreatEntry(uuid)
    local zombieID = Internal.getZombieRuntimeID(zombie)
    local tick = DTNPC_ZombieAggro.GetCurrentTick()

    rt.NPCLeaseCounts[uuid] = (rt.NPCLeaseCounts[uuid] or 0) + 1
    threat.attackerCount = rt.NPCLeaseCounts[uuid]
    threat.lastRefreshTick = tick

    if threat.primaryZombie == nil or (distance or 9999) < (threat.primaryDistance or 9999) then
        threat.primaryZombieID = zombieID
        threat.primaryZombie = zombie
        threat.primaryDistance = distance or 9999
    end
end

local function isLeaseStillValid(zombie, lease)
    if not zombie or not lease or not lease.npcUUID then
        return false, nil
    end

    local rt = runtime()
    local targetEntry = rt.AttackableNPCs[lease.npcUUID]
    if not targetEntry or not targetEntry.zombie or targetEntry.zombie:isDead() then
        return false, nil
    end

    if math.abs((targetEntry.z or 0) - (zombie:getZ() or 0)) > DTNPC_ZombieAggro.CONFIG.FLOOR_TOLERANCE then
        return false, nil
    end

    local dx = targetEntry.x - zombie:getX()
    local dy = targetEntry.y - zombie:getY()
    local keepRadius = DTNPC_ZombieAggro.CONFIG.KEEP_RADIUS
    local distSq = (dx * dx) + (dy * dy)
    if distSq > (keepRadius * keepRadius) then
        return false, nil
    end

    if (rt.NPCLeaseCounts[lease.npcUUID] or 0) >= (targetEntry.leaseLimit or 0) then
        return false, nil
    end

    return true, targetEntry
end

local function refreshLeases()
    local rt = runtime()
    local cell = getCell and getCell() or nil
    local zombieList = cell and cell:getZombieList() or nil
    if not zombieList then
        clearAllThreatSnapshots()
        rt.ZombieLeases = {}
        return
    end

    clearAllThreatSnapshots()

    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and not zombie:isDead() then
            local modData = zombie:getModData()
            if not (modData and modData.IsDTNPC) then
                local zombieID = Internal.getZombieRuntimeID(zombie)
                local lease = rt.ZombieLeases[zombieID]
                local targetEntry = nil
                local distance = 9999
                local validLease = false

                if lease then
                    validLease, targetEntry = isLeaseStillValid(zombie, lease)
                    if not validLease then
                        rt.ZombieLeases[zombieID] = nil
                        lease = nil
                    end
                end

                if not lease then
                    targetEntry, distance = DTNPC_ZombieAggro.FindNearestAttackableNPC(zombie)
                    if targetEntry then
                        lease = {
                            npcUUID = targetEntry.uuid,
                            expiresTick = DTNPC_ZombieAggro.GetCurrentTick() + DTNPC_ZombieAggro.CONFIG.SCAN_INTERVAL_TICKS,
                            nextDamageTick = DTNPC_ZombieAggro.GetCurrentTick(),
                        }
                        rt.ZombieLeases[zombieID] = lease
                    end
                elseif targetEntry then
                    local dx = targetEntry.x - zombie:getX()
                    local dy = targetEntry.y - zombie:getY()
                    distance = math.sqrt((dx * dx) + (dy * dy))
                    lease.expiresTick = DTNPC_ZombieAggro.GetCurrentTick() + DTNPC_ZombieAggro.CONFIG.SCAN_INTERVAL_TICKS
                    rt.ZombieLeases[zombieID] = lease
                end

                if lease and targetEntry then
                    recordThreat(targetEntry, zombie, distance)
                    DTNPC_ZombieAggro.TryApplyLeaseDamage(zombie, lease, targetEntry)
                end
            end
        end
    end

    local tick = DTNPC_ZombieAggro.GetCurrentTick()
    for uuid, threat in pairs(rt.NPCThreats) do
        local npcData = DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[uuid] or nil
        if Internal.syncThreatMirror then
            Internal.syncThreatMirror(npcData, threat, tick)
        end
    end

    for uuid, npcData in pairs((DTNPCManager and DTNPCManager.Data) or {}) do
        if not rt.NPCThreats[uuid] and Internal.syncThreatMirror then
            Internal.syncThreatMirror(npcData, nil, tick)
        end
    end
end

function DTNPC_ZombieAggro.OnManagerTick()
    local tick = DTNPC_ZombieAggro.AdvanceTick()
    if (tick % DTNPC_ZombieAggro.CONFIG.SCAN_INTERVAL_TICKS) ~= 0 then
        return
    end

    DTNPC_ZombieAggro.RebuildAttackableNPCGrid()
    refreshLeases()
    if DTNPC_ZombieAggro.ApplyCombatStimuli then
        DTNPC_ZombieAggro.ApplyCombatStimuli()
    end
end

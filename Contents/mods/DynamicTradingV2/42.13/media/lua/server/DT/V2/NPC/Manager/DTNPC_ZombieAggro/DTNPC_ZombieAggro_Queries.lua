-- ==============================================================================
-- DTNPC_ZombieAggro_Queries.lua
-- Grid building and nearest-NPC lookup for zombie aggro.
-- ==============================================================================

DTNPC_ZombieAggro = DTNPC_ZombieAggro or {}
DTNPC_ZombieAggro._internal = DTNPC_ZombieAggro._internal or {}

local Internal = DTNPC_ZombieAggro._internal
local runtime = Internal.runtime

local function getCellKeyForPosition(x, y)
    local size = DTNPC_ZombieAggro.CONFIG.CELL_SIZE
    local cellX = math.floor((tonumber(x) or 0) / size)
    local cellY = math.floor((tonumber(y) or 0) / size)
    return tostring(cellX) .. ":" .. tostring(cellY), cellX, cellY
end

local function getNeighborKeys(x, y, radius)
    local keys = {}
    local _, centerX, centerY = getCellKeyForPosition(x, y)
    local cellRadius = math.max(1, math.ceil((tonumber(radius) or 0) / DTNPC_ZombieAggro.CONFIG.CELL_SIZE))

    for dx = -cellRadius, cellRadius do
        for dy = -cellRadius, cellRadius do
            keys[#keys + 1] = tostring(centerX + dx) .. ":" .. tostring(centerY + dy)
        end
    end

    return keys
end

local function syncThreatMirror(npcData, threat, tick)
    if not npcData then
        return
    end

    if threat and (threat.attackerCount or 0) > 0 then
        npcData.zombieThreatCount = threat.attackerCount
        npcData.primaryZombieThreatID = threat.primaryZombieID
        npcData.lastZombieThreatAt = tick
        return
    end

    npcData.zombieThreatCount = 0
    npcData.primaryZombieThreatID = nil
    npcData.lastZombieThreatAt = nil
end

function DTNPC_ZombieAggro.RebuildAttackableNPCGrid()
    local rt = runtime()
    local nextGrid = {}
    local nextNPCs = {}
    local tick = DTNPC_ZombieAggro.GetCurrentTick()

    for uuid, npcData in pairs((DTNPCManager and DTNPCManager.Data) or {}) do
        if Internal.isAttackableNPCState(npcData) then
            local zombie = DTNPCServerCore and DTNPCServerCore.FindZombieByUUID and DTNPCServerCore.FindZombieByUUID(uuid) or nil
            if zombie and not zombie:isDead() then
                local x = zombie:getX()
                local y = zombie:getY()
                local z = zombie:getZ()
                local cellKey = getCellKeyForPosition(x, y)
                local entry = {
                    uuid = uuid,
                    zombie = zombie,
                    npcData = npcData,
                    x = x,
                    y = y,
                    z = z,
                    leaseLimit = Internal.getLeaseLimitForNPC(npcData),
                }

                nextGrid[cellKey] = nextGrid[cellKey] or {}
                nextGrid[cellKey][uuid] = entry
                nextNPCs[uuid] = entry
            else
                syncThreatMirror(npcData, nil, tick)
            end
        else
            syncThreatMirror(npcData, nil, tick)
        end
    end

    rt.AttackableNPCGrid = nextGrid
    rt.AttackableNPCs = nextNPCs
end

function DTNPC_ZombieAggro.FindNearestAttackableNPC(zombie)
    if not zombie then
        return nil
    end

    local rt = runtime()
    local zx = zombie:getX()
    local zy = zombie:getY()
    local zz = zombie:getZ()
    local radius = DTNPC_ZombieAggro.CONFIG.ACQUIRE_RADIUS
    local bestEntry = nil
    local bestDistSq = nil
    local radiusSq = radius * radius

    local keys = getNeighborKeys(zx, zy, radius)
    for i = 1, #keys do
        local bucket = rt.AttackableNPCGrid[keys[i]]
        if bucket then
            for uuid, entry in pairs(bucket) do
                local npcData = entry.npcData
                if npcData
                    and entry.zombie
                    and not entry.zombie:isDead()
                    and math.abs((entry.z or 0) - (zz or 0)) <= DTNPC_ZombieAggro.CONFIG.FLOOR_TOLERANCE
                    and (rt.NPCLeaseCounts[uuid] or 0) < (entry.leaseLimit or 0) then
                    local dx = entry.x - zx
                    local dy = entry.y - zy
                    local distSq = (dx * dx) + (dy * dy)
                    if distSq <= radiusSq and (bestDistSq == nil or distSq < bestDistSq) then
                        bestEntry = entry
                        bestDistSq = distSq
                    end
                end
            end
        end
    end

    return bestEntry, bestDistSq and math.sqrt(bestDistSq) or 9999
end

function DTNPC_ZombieAggro.GetThreatTarget(uuid)
    local threat = DTNPC_ZombieAggro.GetThreat(uuid)
    if not threat then
        return nil, 9999
    end

    local zombie = threat.primaryZombie
    if not zombie or zombie:isDead() then
        return nil, 9999
    end

    return zombie, threat.primaryDistance or 9999
end

Internal.getCellKeyForPosition = getCellKeyForPosition
Internal.getNeighborKeys = getNeighborKeys
Internal.syncThreatMirror = syncThreatMirror

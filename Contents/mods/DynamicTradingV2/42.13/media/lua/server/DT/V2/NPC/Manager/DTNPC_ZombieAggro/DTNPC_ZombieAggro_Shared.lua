-- ==============================================================================
-- DTNPC_ZombieAggro_Shared.lua
-- Shared config and helper utilities for zombie aggro.
-- ==============================================================================

DTNPC_ZombieAggro = DTNPC_ZombieAggro or {}
DTNPC_ZombieAggro._internal = DTNPC_ZombieAggro._internal or {}

local Internal = DTNPC_ZombieAggro._internal

DTNPC_ZombieAggro.CONFIG = DTNPC_ZombieAggro.CONFIG or {
    CELL_SIZE = 8,
    SCAN_INTERVAL_TICKS = 10,
    FLOOR_TOLERANCE = 1,
    ACQUIRE_RADIUS = 10,
    KEEP_RADIUS = 12,
    HIT_RADIUS = 1.3,
    HIT_DAMAGE = 6,
    HIT_COOLDOWN_TICKS = 20,
    STATIONARY_LEASE_LIMIT = 4,
    MOBILE_LEASE_LIMIT = 2,
}

local function safeFloor(value)
    return math.floor((tonumber(value) or 0) + 0.5)
end

local function getZombieRuntimeID(zombie)
    if not zombie then
        return nil
    end

    local outfitID = zombie.getPersistentOutfitID and zombie:getPersistentOutfitID() or nil
    if outfitID and outfitID ~= 0 then
        return "outfit:" .. tostring(outfitID)
    end

    local objectID = zombie.getID and zombie:getID() or nil
    if objectID and objectID ~= 0 then
        return "id:" .. tostring(objectID)
    end

    return tostring(zombie)
end

local function isStationaryState(state)
    return state == "Stay"
        or state == "Guard"
        or state == "Idle"
        or state == "Trading"
        or state == "Bandage"
        or state == "TradingDefenseRanged"
        or state == "TradingDefenseMelee"
end

local function isAttackableNPCState(npcData)
    if not npcData then
        return false
    end

    if npcData.status == "Dead" or npcData.status == "Away" then
        return false
    end

    if npcData.incapState == "Active" or npcData.state == "Incapacitated" then
        return false
    end

    if npcData.state == "Departure" then
        return false
    end

    return npcData.uuid ~= nil
end

local function getLeaseLimitForNPC(npcData)
    if isStationaryState(npcData and npcData.state) then
        return DTNPC_ZombieAggro.CONFIG.STATIONARY_LEASE_LIMIT
    end

    return DTNPC_ZombieAggro.CONFIG.MOBILE_LEASE_LIMIT
end

Internal.safeFloor = safeFloor
Internal.getZombieRuntimeID = getZombieRuntimeID
Internal.isStationaryState = isStationaryState
Internal.isAttackableNPCState = isAttackableNPCState
Internal.getLeaseLimitForNPC = getLeaseLimitForNPC

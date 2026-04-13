-- ==============================================================================
-- DTNPC_MobilityPressure.lua
-- Damage pressure and forced retreat helpers for NPC mobility.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Constants = Mobility.Constants or {}
local Internal = Mobility.Internal or {}

Mobility.Constants = Constants
Mobility.Internal = Internal

function Mobility.UpdateDamagePressure(zombie, npcData)
    if not zombie or type(npcData) ~= "table" then
        return nil
    end

    local currentTime = Internal.getTimeMs()
    local combatHealth = DTNPCHealth and DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    if not combatHealth then
        return nil
    end

    if (tonumber(npcData.damagePressureUntil) or 0) > 0 and currentTime > (tonumber(npcData.damagePressureUntil) or 0) then
        npcData.damagePressureCount = 0
        npcData.damagePressureUntil = 0
    end
    if (tonumber(npcData.damageRetreatUntil) or 0) > 0 and currentTime > (tonumber(npcData.damageRetreatUntil) or 0) then
        npcData.damageRetreatUntil = 0
    end

    local lastDamageAt = tonumber(combatHealth.lastDamageAt) or 0
    local freshZombieHit = combatHealth.lastAttackerType == "zombie"
        and lastDamageAt > 0
        and (currentTime - lastDamageAt) <= Constants.DAMAGE_PRESSURE_WINDOW_MS
        and (tonumber(npcData._dtDamagePressureLastAt) or 0) ~= lastDamageAt

    local pressure = Internal.getNearbyZombiePressure(zombie:getX(), zombie:getY(), zombie:getZ(), 2.6)
    local healthRatio = Internal.getHealthRatio(npcData)

    if freshZombieHit then
        local previousUntil = tonumber(npcData.damagePressureUntil) or 0
        local previousCount = tonumber(npcData.damagePressureCount) or 0
        if previousUntil > 0 and previousUntil >= lastDamageAt then
            npcData.damagePressureCount = previousCount + 1
        else
            npcData.damagePressureCount = 1
        end
        npcData.damagePressureUntil = lastDamageAt + Constants.DAMAGE_PRESSURE_WINDOW_MS
        npcData._dtDamagePressureLastAt = lastDamageAt

        local shouldRetreat = (tonumber(npcData.damagePressureCount) or 0) >= 2
            or ((tonumber(npcData.damagePressureCount) or 0) >= 1
                and (tonumber(pressure.closest) or 9999) <= Constants.DAMAGE_RETREAT_ADJACENT_DIST
                and healthRatio <= Constants.DAMAGE_RETREAT_LOW_HEALTH_RATIO)

        if shouldRetreat then
            local retreatFromX = pressure and pressure.count and pressure.count > 0 and pressure.centerX or nil
            local retreatFromY = pressure and pressure.count and pressure.count > 0 and pressure.centerY or nil
            if retreatFromX == nil or retreatFromY == nil then
                retreatFromX, retreatFromY = Internal.getAttackerPosition(
                    combatHealth.lastAttackerID,
                    zombie:getX(),
                    zombie:getY(),
                    zombie:getZ()
                )
            end

            npcData.damageRetreatUntil = currentTime + Constants.DAMAGE_RETREAT_LOCK_MS
            npcData.damageRetreatFromX = retreatFromX or zombie:getX()
            npcData.damageRetreatFromY = retreatFromY or zombie:getY()
        end
    end

    return {
        count = tonumber(npcData.damagePressureCount) or 0,
        untilTime = tonumber(npcData.damagePressureUntil) or 0,
        retreatUntil = tonumber(npcData.damageRetreatUntil) or 0,
        retreatFromX = tonumber(npcData.damageRetreatFromX),
        retreatFromY = tonumber(npcData.damageRetreatFromY),
        healthRatio = healthRatio,
        nearbyPressure = pressure,
        freshZombieHit = freshZombieHit,
    }
end

function Mobility.GetForcedRetreat(zombie, npcData, options)
    if not zombie or type(npcData) ~= "table" then
        return nil
    end

    options = type(options) == "table" and options or {}
    local pressureState = Mobility.UpdateDamagePressure(zombie, npcData)
    local currentTime = Internal.getTimeMs()
    local retreatUntil = tonumber(npcData.damageRetreatUntil) or 0
    if retreatUntil <= 0 or currentTime > retreatUntil then
        return nil
    end

    local pressure = pressureState and pressureState.nearbyPressure or Internal.getNearbyZombiePressure(zombie:getX(), zombie:getY(), zombie:getZ(), 2.6)
    local fromX = pressure and pressure.count and pressure.count > 0 and pressure.centerX or tonumber(npcData.damageRetreatFromX)
    local fromY = pressure and pressure.count and pressure.count > 0 and pressure.centerY or tonumber(npcData.damageRetreatFromY)
    if fromX == nil or fromY == nil then
        return nil
    end

    local dirX = zombie:getX() - fromX
    local dirY = zombie:getY() - fromY
    local len = math.sqrt((dirX * dirX) + (dirY * dirY))
    if len <= 0.001 then
        local lastDirX = tonumber(npcData._dtLastMoveDirX) or 0
        local lastDirY = tonumber(npcData._dtLastMoveDirY) or 0
        if math.abs(lastDirX) > 0.001 or math.abs(lastDirY) > 0.001 then
            dirX = lastDirX
            dirY = lastDirY
            len = math.sqrt((dirX * dirX) + (dirY * dirY))
        end
    end
    if len <= 0.001 then
        dirX = ZombRandFloat(-1.0, 1.0)
        dirY = ZombRandFloat(-1.0, 1.0)
        len = math.sqrt((dirX * dirX) + (dirY * dirY))
    end
    if len <= 0.001 then
        return nil
    end

    dirX = dirX / len
    dirY = dirY / len

    return {
        dirX = dirX,
        dirY = dirY,
        fromX = fromX,
        fromY = fromY,
        desiredDistance = math.max(1.2, tonumber(options.damageRetreatDistance) or Constants.DAMAGE_RETREAT_DISTANCE),
        lockMs = math.max(150, tonumber(options.damageRetreatLockMs) or Constants.DAMAGE_RETREAT_LOCK_MS),
        untilTime = retreatUntil,
    }
end

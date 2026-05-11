-- ==============================================================================
-- DTNPC_ProtectCombat_Danger.lua
-- Melee crowd danger evaluation for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local nowMillis = Internal.nowMillis
local getZombieRuntimeID = Internal.getZombieRuntimeID
local getNearbyZombiePressure = Internal.GetNearbyZombiePressureAt
local getNearbyHostilePressure = Internal.GetNearbyHostilePressureAt

local function combinePressure(primaryPressure, secondaryPressure, originX, originY)
    local primary = type(primaryPressure) == "table" and primaryPressure or {}
    local secondary = type(secondaryPressure) == "table" and secondaryPressure or {}
    local primaryCount = tonumber(primary.count) or 0
    local secondaryCount = tonumber(secondary.count) or 0
    local total = primaryCount + secondaryCount
    if total <= 0 then
        return {
            count = 0,
            closest = math.min(tonumber(primary.closest) or 9999, tonumber(secondary.closest) or 9999),
            centerX = originX,
            centerY = originY,
        }
    end

    local centerX = ((tonumber(primary.centerX) or originX) * primaryCount
        + (tonumber(secondary.centerX) or originX) * secondaryCount) / total
    local centerY = ((tonumber(primary.centerY) or originY) * primaryCount
        + (tonumber(secondary.centerY) or originY) * secondaryCount) / total

    return {
        count = total,
        closest = math.min(tonumber(primary.closest) or 9999, tonumber(secondary.closest) or 9999),
        centerX = centerX,
        centerY = centerY,
    }
end

function DTNPCProtect.GetMeleeDangerState(zombie, npcData, target, options)
    if not zombie or not npcData then
        return nil
    end

    options = type(options) == "table" and options or {}

    local combatHealth = DTNPCHealth and DTNPCHealth.EnsureDefaults and DTNPCHealth.EnsureDefaults(npcData) or nil
    local currentTime = nowMillis()
    local recentZombieDamage = false
    local recentHostileDamage = false
    local recentDamageAmount = 0

    if combatHealth then
        local lastDamageAt = tonumber(combatHealth.lastDamageAt) or 0
        if lastDamageAt > 0
            and (currentTime - lastDamageAt) <= (tonumber(DTNPCProtect.CONFIG.MeleeRecentZombieDamageWindowMs) or 4500) then
            recentDamageAmount = math.max(0, tonumber(combatHealth.lastDamageAmount) or 0)
            if combatHealth.lastAttackerType == "zombie" then
                recentZombieDamage = true
            elseif combatHealth.lastAttackerType == "player"
                or combatHealth.lastAttackerType == "dtnpc"
                or combatHealth.lastAttackerType == "bandits" then
                recentHostileDamage = true
            end
        end
    end

    local excludedIDs = {}
    local targetID = target and getZombieRuntimeID(target) or nil
    if targetID then
        excludedIDs[targetID] = true
    end

    local selfZombiePressure = DTNPCProtect.GetNearbyZombiePressure(
        zombie,
        tonumber(options.pressureRadius) or DTNPCProtect.CONFIG.MeleeCrowdDangerRadius,
        nil
    )
    local selfHostilePressure = getNearbyHostilePressure and getNearbyHostilePressure(
        zombie:getX(),
        zombie:getY(),
        zombie:getZ(),
        tonumber(options.pressureRadius) or DTNPCProtect.CONFIG.MeleeCrowdDangerRadius,
        npcData,
        excludedIDs
    ) or {
        count = 0,
        closest = 9999,
        centerX = zombie:getX(),
        centerY = zombie:getY(),
    }
    local selfPressure = combinePressure(selfZombiePressure, selfHostilePressure, zombie:getX(), zombie:getY())

    local targetPressure = target and getNearbyZombiePressure(
        target:getX(),
        target:getY(),
        target:getZ() or zombie:getZ(),
        tonumber(options.targetPressureRadius) or DTNPCProtect.CONFIG.MeleeCrowdRadius,
        excludedIDs
    ) or {
        count = 0,
        closest = 9999,
        centerX = target and target:getX() or zombie:getX(),
        centerY = target and target:getY() or zombie:getY(),
    }

    local healthRatio = DTNPCHealth and DTNPCHealth.GetHealthRatio and DTNPCHealth.GetHealthRatio(npcData) or 1
    local crowdThreshold = tonumber(DTNPCProtect.CONFIG.MeleeCrowdDangerThreshold) or 3
    local severeThreshold = tonumber(DTNPCProtect.CONFIG.MeleeCrowdSevereThreshold) or 4
    local lowHealthRatio = tonumber(DTNPCProtect.CONFIG.MeleeLowHealthRetreatRatio) or 0.58

    local lowHealth = healthRatio <= lowHealthRatio
    local targetCrowdDanger = targetPressure.count >= crowdThreshold
        and (selfPressure.count >= math.max(2, crowdThreshold - 1) or lowHealth or recentZombieDamage or recentHostileDamage)
    local surrounded = selfPressure.count >= crowdThreshold
    local severeCrowd = selfPressure.count >= severeThreshold or targetCrowdDanger
    local pressured = (recentZombieDamage or recentHostileDamage)
        and (selfPressure.count >= math.max(2, crowdThreshold - 1) or targetPressure.count >= 2)

    if healthRatio > 0.72 and not recentZombieDamage and not recentHostileDamage and not severeCrowd then
        surrounded = false
    end

    if not (surrounded or severeCrowd or (lowHealth and selfPressure.count >= 2) or pressured) then
        return {
            shouldDisengage = false,
            selfPressure = selfPressure,
            selfZombiePressure = selfZombiePressure,
            selfHostilePressure = selfHostilePressure,
            targetPressure = targetPressure,
            recentZombieDamage = recentZombieDamage,
            recentHostileDamage = recentHostileDamage,
            recentDamageAmount = recentDamageAmount,
            healthRatio = healthRatio,
        }
    end

    local retreatDistance = math.max(
        tonumber(options.retreatDistance) or tonumber(options.engageReach) or 1.8,
        (tonumber(options.engageReach) or 1.45) + 0.8 + (math.max(selfPressure.count, targetPressure.count) * 0.22)
    )

    local fleeFromX = selfPressure.centerX
    local fleeFromY = selfPressure.centerY
    if targetPressure.count > selfPressure.count and targetPressure.count >= 2 then
        fleeFromX = targetPressure.centerX
        fleeFromY = targetPressure.centerY
    elseif target and selfPressure.count <= 1 then
        fleeFromX = target:getX()
        fleeFromY = target:getY()
    end

    return {
        shouldDisengage = true,
        reason = severeCrowd and "crowd"
            or surrounded and "surrounded"
            or pressured and "pressured"
            or "low_health",
        retreatDistance = retreatDistance,
        fleeFromX = fleeFromX,
        fleeFromY = fleeFromY,
        selfPressure = selfPressure,
        selfZombiePressure = selfZombiePressure,
        selfHostilePressure = selfHostilePressure,
        targetPressure = targetPressure,
        recentZombieDamage = recentZombieDamage,
        recentHostileDamage = recentHostileDamage,
        recentDamageAmount = recentDamageAmount,
        healthRatio = healthRatio,
    }
end

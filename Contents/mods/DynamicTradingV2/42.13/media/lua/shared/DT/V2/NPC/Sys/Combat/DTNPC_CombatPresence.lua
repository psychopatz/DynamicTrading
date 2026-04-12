-- ==============================================================================
-- DTNPC_CombatPresence.lua
-- Tracks temporary combat "heat" so zombie aggro can react to NPC attacks.
-- ==============================================================================

DTNPCCombat = DTNPCCombat or {}

DTNPCCombat.CONFIG = DTNPCCombat.CONFIG or {}

DTNPCCombat.CONFIG.MeleePresenceRadius = DTNPCCombat.CONFIG.MeleePresenceRadius or 12
DTNPCCombat.CONFIG.RangedPresenceRadius = DTNPCCombat.CONFIG.RangedPresenceRadius or 20
DTNPCCombat.CONFIG.GenericPresenceRadius = DTNPCCombat.CONFIG.GenericPresenceRadius or 10
DTNPCCombat.CONFIG.MeleePresenceDurationMs = DTNPCCombat.CONFIG.MeleePresenceDurationMs or 3200
DTNPCCombat.CONFIG.RangedPresenceDurationMs = DTNPCCombat.CONFIG.RangedPresenceDurationMs or 5200
DTNPCCombat.CONFIG.GenericPresenceDurationMs = DTNPCCombat.CONFIG.GenericPresenceDurationMs or 2500
DTNPCCombat.CONFIG.MeleePresenceLeaseBonus = DTNPCCombat.CONFIG.MeleePresenceLeaseBonus or 1
DTNPCCombat.CONFIG.RangedPresenceLeaseBonus = DTNPCCombat.CONFIG.RangedPresenceLeaseBonus or 2
DTNPCCombat.CONFIG.GenericPresenceLeaseBonus = DTNPCCombat.CONFIG.GenericPresenceLeaseBonus or 0
DTNPCCombat.CONFIG.MeleePresencePriority = DTNPCCombat.CONFIG.MeleePresencePriority or 1.18
DTNPCCombat.CONFIG.RangedPresencePriority = DTNPCCombat.CONFIG.RangedPresencePriority or 1.42
DTNPCCombat.CONFIG.GenericPresencePriority = DTNPCCombat.CONFIG.GenericPresencePriority or 1.08

local function nowMillis()
    if getTimeInMillis then
        local value = tonumber(getTimeInMillis())
        if value and value > 0 then
            return math.floor(value)
        end
    end

    local gt = getGameTime and getGameTime() or nil
    if gt and gt.getWorldAgeHours then
        return math.floor((tonumber(gt:getWorldAgeHours()) or 0) * 3600000)
    end

    return 0
end

local function isAuthoritativeSide()
    if isClient and isClient() and not (isServer and isServer()) then
        return false
    end

    return true
end

local function clearPresence(npcData)
    if not npcData then
        return
    end

    npcData.combatPresenceAttackType = nil
    npcData.combatPresenceStartedAt = nil
    npcData.combatPresenceUntil = nil
    npcData.combatPresenceBaseRadius = nil
    npcData.combatPresenceLeaseBonus = nil
    npcData.combatPresencePriority = nil
end

local function getPresenceDefaults(attackType)
    if attackType == "ranged" then
        return
            DTNPCCombat.CONFIG.RangedPresenceRadius,
            DTNPCCombat.CONFIG.RangedPresenceDurationMs,
            DTNPCCombat.CONFIG.RangedPresenceLeaseBonus,
            DTNPCCombat.CONFIG.RangedPresencePriority
    end

    if attackType == "melee" then
        return
            DTNPCCombat.CONFIG.MeleePresenceRadius,
            DTNPCCombat.CONFIG.MeleePresenceDurationMs,
            DTNPCCombat.CONFIG.MeleePresenceLeaseBonus,
            DTNPCCombat.CONFIG.MeleePresencePriority
    end

    return
        DTNPCCombat.CONFIG.GenericPresenceRadius,
        DTNPCCombat.CONFIG.GenericPresenceDurationMs,
        DTNPCCombat.CONFIG.GenericPresenceLeaseBonus,
        DTNPCCombat.CONFIG.GenericPresencePriority
end

function DTNPCCombat.NotifyAttack(zombie, npcData, attackType, target, options)
    if not npcData or not isAuthoritativeSide() then
        return false
    end

    options = type(options) == "table" and options or {}

    local radius, durationMs, leaseBonus, priority = getPresenceDefaults(attackType)
    radius = math.max(0, tonumber(options.radius) or radius or 0)
    durationMs = math.max(250, tonumber(options.durationMs) or durationMs or 1000)
    leaseBonus = math.max(0, tonumber(options.leaseBonus) or leaseBonus or 0)
    priority = math.max(1.0, tonumber(options.priority) or priority or 1.0)

    local threatCount = math.max(0, tonumber(npcData.zombieThreatCount) or 0)
    if threatCount > 0 then
        radius = radius + math.min(3, threatCount * 0.35)
        priority = priority + math.min(0.22, threatCount * 0.04)
    end

    local currentTime = nowMillis()
    local previousUntil = tonumber(npcData.combatPresenceUntil) or 0
    if previousUntil > currentTime then
        radius = math.max(radius, tonumber(npcData.combatPresenceBaseRadius) or 0)
        leaseBonus = math.max(leaseBonus, tonumber(npcData.combatPresenceLeaseBonus) or 0)
        priority = math.max(priority, tonumber(npcData.combatPresencePriority) or 1.0)
    end

    npcData.combatPresenceAttackType = tostring(attackType or "generic")
    npcData.combatPresenceStartedAt = currentTime
    npcData.combatPresenceUntil = currentTime + durationMs
    npcData.combatPresenceBaseRadius = radius
    npcData.combatPresenceLeaseBonus = leaseBonus
    npcData.combatPresencePriority = priority

    return true
end

function DTNPCCombat.GetPresence(npcData, currentTime)
    if not npcData then
        return nil
    end

    currentTime = tonumber(currentTime) or nowMillis()

    local untilTime = tonumber(npcData.combatPresenceUntil) or 0
    if untilTime <= currentTime then
        clearPresence(npcData)
        return nil
    end

    local startedAt = tonumber(npcData.combatPresenceStartedAt) or currentTime
    local duration = math.max(1, untilTime - startedAt)
    local remainingRatio = math.max(0.2, math.min(1.0, (untilTime - currentTime) / duration))

    return {
        attackType = npcData.combatPresenceAttackType or "generic",
        radius = math.max(0, (tonumber(npcData.combatPresenceBaseRadius) or 0) * remainingRatio),
        leaseBonus = math.max(0, tonumber(npcData.combatPresenceLeaseBonus) or 0),
        priority = math.max(1.0, 1.0 + ((math.max(1.0, tonumber(npcData.combatPresencePriority) or 1.0) - 1.0) * remainingRatio)),
        untilTime = untilTime,
    }
end

function DTNPCCombat.GetZombieAttractRadius(npcData, baseRadius, currentTime)
    local presence = DTNPCCombat.GetPresence(npcData, currentTime)
    if not presence then
        return math.max(0, tonumber(baseRadius) or 0)
    end

    return math.max(math.max(0, tonumber(baseRadius) or 0), tonumber(presence.radius) or 0)
end

function DTNPCCombat.GetZombieLeaseBonus(npcData, currentTime)
    local presence = DTNPCCombat.GetPresence(npcData, currentTime)
    if not presence then
        return 0
    end

    return math.max(0, tonumber(presence.leaseBonus) or 0)
end

function DTNPCCombat.GetZombieAttractPriority(npcData, currentTime)
    local presence = DTNPCCombat.GetPresence(npcData, currentTime)
    if not presence then
        return 1.0
    end

    return math.max(1.0, tonumber(presence.priority) or 1.0)
end

function DTNPCCombat.GetMaxZombieAttractRadius()
    return math.max(
        tonumber(DTNPCCombat.CONFIG.MeleePresenceRadius) or 0,
        tonumber(DTNPCCombat.CONFIG.RangedPresenceRadius) or 0,
        tonumber(DTNPCCombat.CONFIG.GenericPresenceRadius) or 0
    )
end

-- ==============================================================================
-- DTNPC_CombatEvasion.lua
-- Skill-scaled zombie hit evasion and mitigation for NPCs.
-- ==============================================================================

DTNPCCombat = DTNPCCombat or {}

DTNPCCombat.CONFIG = DTNPCCombat.CONFIG or {}

DTNPCCombat.CONFIG.ZombieEvadeBaseChance = DTNPCCombat.CONFIG.ZombieEvadeBaseChance or 0.04
DTNPCCombat.CONFIG.ZombieEvadeMeleeWeight = DTNPCCombat.CONFIG.ZombieEvadeMeleeWeight or 0.20
DTNPCCombat.CONFIG.ZombieEvadeRangedWeight = DTNPCCombat.CONFIG.ZombieEvadeRangedWeight or 0.10
DTNPCCombat.CONFIG.ZombieEvadeMovingBonus = DTNPCCombat.CONFIG.ZombieEvadeMovingBonus or 0.05
DTNPCCombat.CONFIG.ZombieEvadeStationaryPenalty = DTNPCCombat.CONFIG.ZombieEvadeStationaryPenalty or 0.03
DTNPCCombat.CONFIG.ZombieEvadeThreatPenalty = DTNPCCombat.CONFIG.ZombieEvadeThreatPenalty or 0.05
DTNPCCombat.CONFIG.ZombieEvadeLowHealthPenalty = DTNPCCombat.CONFIG.ZombieEvadeLowHealthPenalty or 0.04
DTNPCCombat.CONFIG.ZombieEvadeMinChance = DTNPCCombat.CONFIG.ZombieEvadeMinChance or 0.02
DTNPCCombat.CONFIG.ZombieEvadeMaxChance = DTNPCCombat.CONFIG.ZombieEvadeMaxChance or 0.34
DTNPCCombat.CONFIG.ZombieDamageMitigationMax = DTNPCCombat.CONFIG.ZombieDamageMitigationMax or 0.18
DTNPCCombat.CONFIG.ZombieEvadeRetryTicks = DTNPCCombat.CONFIG.ZombieEvadeRetryTicks or 8

local function clamp(value, minValue, maxValue)
    local numeric = tonumber(value) or minValue
    if numeric < minValue then
        return minValue
    end
    if numeric > maxValue then
        return maxValue
    end
    return numeric
end

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

local function getSkillLevel(npcData, skillID)
    if DTNPCProtect and DTNPCProtect.GetSkillLevel then
        return DTNPCProtect.GetSkillLevel(npcData, skillID)
    end

    return 0
end

local function isMobileCombatState(state)
    return state == "GoTo"
        or state == "Flee"
        or state == "Follow"
        or state == "Attack"
        or state == "AttackRange"
        or state == "ProtectMelee"
        or state == "ProtectRanged"
        or state == "ProtectAuto"
        or state == "TradingDefenseMelee"
        or state == "TradingDefenseRanged"
        or state == "Departure"
end

function DTNPCCombat.GetZombieDefenseProfile(zombie, npcData, options)
    npcData = type(npcData) == "table" and npcData or {}
    options = type(options) == "table" and options or {}

    local melee = clamp(getSkillLevel(npcData, "Melee"), 0, 20) / 20
    local ranged = clamp(getSkillLevel(npcData, "Shooting"), 0, 20) / 20
    local threatCount = math.max(0, tonumber(options.threatCount) or tonumber(npcData.zombieThreatCount) or 0)
    local state = tostring(npcData.autoProtectActiveState or npcData.state or "")

    local evadeChance = tonumber(DTNPCCombat.CONFIG.ZombieEvadeBaseChance) or 0
    evadeChance = evadeChance
        + (melee * (tonumber(DTNPCCombat.CONFIG.ZombieEvadeMeleeWeight) or 0))
        + (ranged * (tonumber(DTNPCCombat.CONFIG.ZombieEvadeRangedWeight) or 0))

    if isMobileCombatState(state) or npcData.isMovingState == true then
        evadeChance = evadeChance + (tonumber(DTNPCCombat.CONFIG.ZombieEvadeMovingBonus) or 0)
    else
        evadeChance = evadeChance - (tonumber(DTNPCCombat.CONFIG.ZombieEvadeStationaryPenalty) or 0)
    end

    if threatCount > 1 then
        evadeChance = evadeChance - ((threatCount - 1) * (tonumber(DTNPCCombat.CONFIG.ZombieEvadeThreatPenalty) or 0))
    end

    local healthRatio = DTNPCHealth and DTNPCHealth.GetHealthRatio and DTNPCHealth.GetHealthRatio(npcData) or 1
    if healthRatio < 0.45 then
        evadeChance = evadeChance - (tonumber(DTNPCCombat.CONFIG.ZombieEvadeLowHealthPenalty) or 0)
    end

    evadeChance = clamp(
        evadeChance,
        tonumber(DTNPCCombat.CONFIG.ZombieEvadeMinChance) or 0,
        tonumber(DTNPCCombat.CONFIG.ZombieEvadeMaxChance) or 1
    )

    local mitigation = (melee * 0.12) + (ranged * 0.06)
    if threatCount > 1 then
        mitigation = mitigation - ((threatCount - 1) * 0.02)
    end
    mitigation = clamp(mitigation, 0, tonumber(DTNPCCombat.CONFIG.ZombieDamageMitigationMax) or 0)

    return {
        evadeChance = evadeChance,
        damageMultiplier = 1.0 - mitigation,
        melee = melee,
        ranged = ranged,
        threatCount = threatCount,
    }
end

function DTNPCCombat.ResolveZombieHit(zombie, npcData, attacker, damage, options)
    local profile = DTNPCCombat.GetZombieDefenseProfile(zombie, npcData, options)
    local roll

    if ZombRandFloat then
        roll = ZombRandFloat(0.0, 1.0)
    else
        roll = (ZombRand(10000) or 0) / 10000
    end

    local evaded = roll < profile.evadeChance
    if evaded then
        if npcData then
            npcData.lastZombieEvadeAt = nowMillis()
        end
        return {
            evaded = true,
            damage = 0,
            damageMultiplier = 0,
            evadeChance = profile.evadeChance,
            cooldownTicks = math.max(1, tonumber(DTNPCCombat.CONFIG.ZombieEvadeRetryTicks) or 1),
        }
    end

    local resolvedDamage = math.max(0.01, (tonumber(damage) or 0) * (tonumber(profile.damageMultiplier) or 1.0))
    return {
        evaded = false,
        damage = resolvedDamage,
        damageMultiplier = profile.damageMultiplier,
        evadeChance = profile.evadeChance,
        cooldownTicks = 0,
    }
end

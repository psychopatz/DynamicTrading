-- ==============================================================================
-- DT_DamageSystem.lua
-- Centralized damage scaling and combat effects for NPCs.
-- ==============================================================================

DT_DamageSystem = DT_DamageSystem or {}

DT_DamageSystem.DEFAULT_SKILL_LEVEL = DT_DamageSystem.DEFAULT_SKILL_LEVEL or 5
DT_DamageSystem.RANGED_MULTIPLIER_MIN = DT_DamageSystem.RANGED_MULTIPLIER_MIN or 15.0
DT_DamageSystem.RANGED_MULTIPLIER_MAX = DT_DamageSystem.RANGED_MULTIPLIER_MAX or 25.0
DT_DamageSystem.MELEE_MULTIPLIER_MIN = DT_DamageSystem.MELEE_MULTIPLIER_MIN or 8.0
DT_DamageSystem.MELEE_MULTIPLIER_MAX = DT_DamageSystem.MELEE_MULTIPLIER_MAX or 14.0

local function getNPCDamageDealtMultiplier()
    if DTNPCHealth and DTNPCHealth.Internal and DTNPCHealth.Internal.getNPCDamageDealtMultiplier then
        return math.max(0, tonumber(DTNPCHealth.Internal.getNPCDamageDealtMultiplier()) or 1.0)
    end

    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    local configured = sandbox and tonumber(sandbox.NPCDamageDealtMultiplier) or nil
    if configured and configured >= 0 then
        return configured
    end

    return 1.0
end

function DT_DamageSystem.rollWeaponDamage(item)
    if not item then return 0.5 end
    local minDamage = item.getMinDamage and tonumber(item:getMinDamage()) or nil
    local maxDamage = item.getMaxDamage and tonumber(item:getMaxDamage()) or nil

    if not minDamage or minDamage <= 0 then
        minDamage = maxDamage or 0.35
    end
    if not maxDamage or maxDamage < minDamage then
        maxDamage = minDamage
    end

    if ZombRandFloat then
        return ZombRandFloat(minDamage, maxDamage)
    end
    return (minDamage + maxDamage) * 0.5
end

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

local function resolveSkillLevel(npcData, attackType, options)
    options = type(options) == "table" and options or {}
    local explicitLevel = tonumber(options.skillLevel)
    if explicitLevel ~= nil then
        return clamp(explicitLevel, 0, 20)
    end

    local skillID = attackType == "ranged" and "Shooting" or "Melee"
    local fallback = tonumber(DT_DamageSystem.DEFAULT_SKILL_LEVEL) or 5
    if npcData and DTNPCProtect and DTNPCProtect.GetSkillLevel then
        fallback = DTNPCProtect.GetSkillLevel(npcData, skillID)
    end

    return clamp(fallback, 0, 20)
end

local function resolveAttackMultiplier(attackType, normalized, options)
    options = type(options) == "table" and options or {}
    local minMultiplier = nil
    local maxMultiplier = nil

    if attackType == "ranged" then
        minMultiplier = tonumber(options.minMultiplier) or tonumber(DT_DamageSystem.RANGED_MULTIPLIER_MIN) or 15.0
        maxMultiplier = tonumber(options.maxMultiplier) or tonumber(DT_DamageSystem.RANGED_MULTIPLIER_MAX) or 25.0
    elseif attackType == "melee" then
        minMultiplier = tonumber(options.minMultiplier) or tonumber(DT_DamageSystem.MELEE_MULTIPLIER_MIN) or 8.0
        maxMultiplier = tonumber(options.maxMultiplier) or tonumber(DT_DamageSystem.MELEE_MULTIPLIER_MAX) or 14.0
    else
        minMultiplier = tonumber(options.minMultiplier) or 1.0
        maxMultiplier = tonumber(options.maxMultiplier) or minMultiplier
    end

    if maxMultiplier < minMultiplier then
        maxMultiplier = minMultiplier
    end

    return minMultiplier + ((maxMultiplier - minMultiplier) * normalized)
end

function DT_DamageSystem.GetScaledDamage(npcData, attackType, weaponItem, options)
    options = type(options) == "table" and options or {}

    local baseDamage = tonumber(options.baseDamage)
    if baseDamage == nil then
        baseDamage = DT_DamageSystem.rollWeaponDamage(weaponItem)
    end
    baseDamage = math.max(0, baseDamage)

    local dealtMultiplier = 1.0
    if options.applyDealtMultiplier ~= false then
        dealtMultiplier = getNPCDamageDealtMultiplier()
    end

    local skillLevel = resolveSkillLevel(npcData, attackType, options)
    local normalized = skillLevel / 20
    local attackMultiplier = resolveAttackMultiplier(attackType, normalized, options)
    return baseDamage * attackMultiplier * dealtMultiplier
end

function DT_DamageSystem.CalculateHitEffects(shooter, target, damage, attackType)
    local result = {
        damage = damage,
        hitReaction = attackType == "ranged" and "ShotBelly" or "HitReaction",
        isHeadshot = false
    }

    if attackType == "ranged" then
        local shootingSkill = 5
        -- Try to get shooter's skill if shooter is an NPC table or object
        if shooter and type(shooter) == "table" and DTNPCProtect and DTNPCProtect.GetSkillLevel then
            shootingSkill = DTNPCProtect.GetSkillLevel(shooter, "Shooting")
        end
        
        local headshotChance = 5 + (shootingSkill * 2) -- e.g. 5% at skill 0, 45% at skill 20
        
        if ZombRand(100) < headshotChance then
            -- Headshots deal massive damage (4x)
            result.damage = damage * 4.0
            result.isHeadshot = true
            result.hitReaction = "ShotHead"
        end
    end

    -- Enforce flinch for bullets
    if attackType == "ranged" and target and target.setHitReaction then
        target:setHitReaction(result.hitReaction)
    end

    return result
end

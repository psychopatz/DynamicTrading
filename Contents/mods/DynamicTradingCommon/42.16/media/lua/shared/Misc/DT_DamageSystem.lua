-- ==============================================================================
-- DT_DamageSystem.lua
-- Centralized damage scaling and combat effects for NPCs.
-- ==============================================================================

DT_DamageSystem = DT_DamageSystem or {}

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

function DT_DamageSystem.GetScaledDamage(npcData, attackType, weaponItem)
    local baseDamage = DT_DamageSystem.rollWeaponDamage(weaponItem)
    
    if attackType == "ranged" then
        local shootingSkill = 5
        if npcData and DTNPCProtect and DTNPCProtect.GetSkillLevel then
            shootingSkill = DTNPCProtect.GetSkillLevel(npcData, "Shooting")
        end
        local normalized = math.min(math.max(shootingSkill, 0), 20) / 20
        -- Ranged multiplier: 15.0x to 25.0x based on skill
        -- This ensures bullets are impactful against 100-health targets.
        local multiplier = 15.0 + (normalized * 10.0)
        return baseDamage * multiplier
    end

    if attackType == "melee" then
        local meleeSkill = 5
        if npcData and DTNPCProtect and DTNPCProtect.GetSkillLevel then
            meleeSkill = DTNPCProtect.GetSkillLevel(npcData, "Melee")
        end
        local normalized = math.min(math.max(meleeSkill, 0), 20) / 20
        -- Melee multiplier: Retain original (0.8 to 1.7x)
        local multiplier = 0.8 + (normalized * 0.9)
        return baseDamage * multiplier
    end

    return baseDamage
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

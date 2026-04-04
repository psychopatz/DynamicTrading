-- ==============================================================================
-- DTNPC_ProtectCombat_logic.lua
-- Combat stats and hit resolution for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local clamp = Internal.clamp

local function rollWeaponDamage(item)
    local minDamage = item and item.getMinDamage and tonumber(item:getMinDamage()) or nil
    local maxDamage = item and item.getMaxDamage and tonumber(item:getMaxDamage()) or nil

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

Internal.rollWeaponDamage = rollWeaponDamage

function DTNPCProtect.GetRangedCombatStats(npcData)
    local shooting = DTNPCProtect.GetSkillLevel(npcData, "Shooting")
    local normalized = math.min(math.max(shooting, 0), 20) / 20
    local weaponItem = DTNPCProtect.CreateLoadoutWeaponItem(npcData, "ranged")
    local avgDamage = rollWeaponDamage(weaponItem)
    local scaledDamage = avgDamage * (0.75 + (normalized * 0.75))

    return {
        hitStill = math.floor(22 + (normalized * 58)),
        hitMove = math.floor(10 + (normalized * 35)),
        fireRate = math.max(36, math.floor(96 - (normalized * 44))),
        damage = math.max(0.22 + (normalized * 0.5), scaledDamage),
    }
end

function DTNPCProtect.GetMeleeCombatStats(npcData)
    local melee = DTNPCProtect.GetSkillLevel(npcData, "Melee")
    local normalized = math.min(math.max(melee, 0), 20) / 20
    local weaponItem = DTNPCProtect.CreateLoadoutWeaponItem(npcData, "melee")
    local weaponRange = weaponItem and weaponItem.getMaxRange and tonumber(weaponItem:getMaxRange()) or 1.0
    local avgDamage = rollWeaponDamage(weaponItem)
    local scaledDamage = avgDamage * (0.8 + (normalized * 0.9))

    return {
        hitChance = math.floor(55 + (normalized * 40)),
        attackRate = math.max(16, math.floor(34 - (normalized * 18))),
        damage = math.max(0.45, scaledDamage),
        chaseSpeed = 0.05 + (normalized * 0.025),
        reach = clamp(weaponRange + 0.15, 1.15, 1.9),
    }
end

function DTNPCProtect.ApplyCombatHit(zombie, npcData, target, options)
    if not zombie or not target or target:isDead() then
        return false, false
    end

    options = type(options) == "table" and options or {}
    local attackType = options.attackType or "generic"
    local damage = math.max(0.05, tonumber(options.damage) or 0.1)
    local applied = false
    local isPlayerTarget = instanceof(target, "IsoPlayer")
    local targetModData = target.getModData and target:getModData() or nil
    local targetNPCData = targetModData and (targetModData.DTNPC_Data or targetModData.DTNPCBrain) or nil
    local isDTNPCTarget = targetModData and targetModData.IsDTNPC == true and targetNPCData ~= nil

    if isDTNPCTarget and DTNPCHealth and DTNPCHealth.IsCustomHealthEnabled and DTNPCHealth.IsCustomHealthEnabled(targetNPCData) then
        if attackType == "ranged" then
            local shootingSkill = DTNPCProtect.GetSkillLevel(npcData, "Shooting")
            local normalized = math.min(math.max(shootingSkill, 0), 20) / 20
            local weaponItem = DTNPCProtect.CreateLoadoutWeaponItem(npcData, "ranged")
            if weaponItem then
                damage = math.max(damage, rollWeaponDamage(weaponItem) * (0.75 + (normalized * 0.75)))
            end
        elseif attackType == "melee" then
            local meleeSkill = DTNPCProtect.GetSkillLevel(npcData, "Melee")
            local normalized = math.min(math.max(meleeSkill, 0), 20) / 20
            local weaponItem = DTNPCProtect.CreateLoadoutWeaponItem(npcData, "melee")
            if weaponItem then
                damage = math.max(damage, rollWeaponDamage(weaponItem) * (0.8 + (normalized * 0.9)))
            end
        end

        return DTNPCHealth.ApplyDamage(target, targetNPCData, damage, zombie, {
            source = "dt_npc_combat",
            attackType = attackType,
            queueFallbackIgnore = false,
        })
    end

    if isPlayerTarget then
        local bodyDamage = target.getBodyDamage and target:getBodyDamage() or nil
        local bodyPart = bodyDamage
            and bodyDamage.getBodyPart
            and BodyPartType
            and BodyPartType.Torso_Upper
            and bodyDamage:getBodyPart(BodyPartType.Torso_Upper)
            or nil

        if bodyPart and bodyPart.AddDamage then
            local appliedDamage = damage
            if attackType == "melee" then
                appliedDamage = damage * 0.8
            end

            bodyPart:AddDamage(appliedDamage)
            if attackType == "ranged" then
                if bodyPart.setHaveBullet then
                    bodyPart:setHaveBullet(true, 0)
                end
                if bodyPart.setBleedingTime then
                    bodyPart:setBleedingTime(math.max(10, tonumber(bodyPart.getBleedingTime and bodyPart:getBleedingTime() or 0) or 0))
                end
            end

            if bodyDamage.Update then
                bodyDamage:Update()
            end
            if target.setAttackedBy then
                target:setAttackedBy(zombie)
            end
            if target.setHitReaction then
                target:setHitReaction("HitReaction")
            end
            if target.getEmitter then
                target:getEmitter():playSound("ImpactFlesh")
            end

            applied = true
        end
    elseif attackType == "ranged" then
        local shootingSkill = DTNPCProtect.GetSkillLevel(npcData, "Shooting")
        local normalized = math.min(math.max(shootingSkill, 0), 20) / 20
        local weaponItem = DTNPCProtect.CreateLoadoutWeaponItem(npcData, "ranged")

        if weaponItem then
            damage = math.max(damage, rollWeaponDamage(weaponItem) * (0.75 + (normalized * 0.75)))

            if target.setBumpDone then
                target:setBumpDone(true)
            end
            if target.setPlayerAttackPosition and target.testDotSide then
                target:setPlayerAttackPosition(target:testDotSide(zombie))
            end
            if target.setHitFromBehind and zombie.isBehind then
                local ok, behind = pcall(function()
                    return zombie:isBehind(target)
                end)
                if ok then
                    target:setHitFromBehind(behind == true)
                end
            end
            if target.setHitReaction then
                target:setHitReaction("ShotBelly")
            end

            local cell = getCell()
            local fakeZombie = cell and cell.getFakeZombieForHit and cell:getFakeZombieForHit() or nil
            local didHit = pcall(function()
                target:Hit(weaponItem, fakeZombie or zombie, damage, false, 1, false)
            end)
            if didHit then
                applied = true
                if target.setAttackedBy then
                    target:setAttackedBy(zombie)
                end
            end
        end
    elseif attackType == "melee" then
        local meleeSkill = DTNPCProtect.GetSkillLevel(npcData, "Melee")
        local normalized = math.min(math.max(meleeSkill, 0), 20) / 20
        local weaponItem = DTNPCProtect.CreateLoadoutWeaponItem(npcData, "melee")

        if weaponItem then
            damage = math.max(damage, rollWeaponDamage(weaponItem) * (0.8 + (normalized * 0.9)))

            if target.setPlayerAttackPosition and target.testDotSide then
                target:setPlayerAttackPosition(target:testDotSide(zombie))
            end
            if target.setHitHeadWhileOnFloor then
                target:setHitHeadWhileOnFloor(0)
            end
            if target.setHitLegsWhileOnFloor then
                target:setHitLegsWhileOnFloor(false)
            end
            if target.setAttackedBy then
                target:setAttackedBy(zombie)
            end
            if target.setHitFromBehind and zombie.isBehind then
                local ok, behind = pcall(function()
                    return zombie:isBehind(target)
                end)
                if ok then
                    target:setHitFromBehind(behind == true)
                end
            end

            local cell = getCell()
            local fakeZombie = cell and cell.getFakeZombieForHit and cell:getFakeZombieForHit() or nil
            local didHit = pcall(function()
                target:Hit(weaponItem, fakeZombie or zombie, damage, false, 1, false)
            end)
            if didHit then
                applied = true
                local hitSound = weaponItem.getZombieHitSound and weaponItem:getZombieHitSound() or nil
                if hitSound and hitSound ~= "" and target.playSound then
                    target:playSound(hitSound)
                elseif target.getEmitter then
                    target:getEmitter():playSound("ZombieImpact")
                end
            end
        end
    end

    if not applied then
        target:setHealth(target:getHealth() - damage)
        if target.getEmitter then
            target:getEmitter():playSound("ZombieImpact")
        end
        applied = true
    end

    local killed = target:isDead() or target:getHealth() <= 0
    if killed then
        if not target:isDead() then
            target:Kill(zombie)
        end
    elseif target.setHitReaction then
        target:setHitReaction(attackType == "ranged" and "ShotBelly" or "HitReaction")
    end

    if applied and (attackType == "melee" or attackType == "ranged") then
        local skillID = attackType == "ranged" and "Shooting" or "Melee"
        local xpGain = attackType == "ranged"
            and (DTNPCProtect.COMBAT_SKILL_XP.ShootingHit or 0)
            or (DTNPCProtect.COMBAT_SKILL_XP.MeleeHit or 0)
        if killed then
            xpGain = xpGain + (
                attackType == "ranged"
                    and (DTNPCProtect.COMBAT_SKILL_XP.ShootingKillBonus or 0)
                    or (DTNPCProtect.COMBAT_SKILL_XP.MeleeKillBonus or 0)
            )
        end
        DTNPCProtect.AddSkillXP(npcData, skillID, xpGain)
    end

    return applied, killed
end

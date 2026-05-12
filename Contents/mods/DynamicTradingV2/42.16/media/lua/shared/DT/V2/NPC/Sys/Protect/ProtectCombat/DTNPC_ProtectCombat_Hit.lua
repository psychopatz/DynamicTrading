-- ==============================================================================
-- DTNPC_ProtectCombat_Hit.lua
-- Combat hit application for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getAttackWeaponItem = Internal.ProtectCombatGetAttackWeaponItem
local playSuccessfulHitSound = Internal.ProtectCombatPlaySuccessfulHitSound

function DTNPCProtect.ApplyCombatHit(zombie, npcData, target, options)
    if not zombie or not target or target:isDead() then
        return false, false
    end
    if DTNPCProtect.IsCombatCapable then
        local capable = DTNPCProtect.IsCombatCapable(zombie, npcData)
        if not capable then
            if DTNPCProtect.StopCombatActions then
                DTNPCProtect.StopCombatActions(zombie, npcData, "not_capable")
            end
            return false, false
        end
    end

    options = type(options) == "table" and options or {}
    local attackType = options.attackType or "generic"
    local damage = math.max(0.05, tonumber(options.damage) or 0.1)
    local applied = false
    local weaponItem = getAttackWeaponItem(npcData, attackType)
    local isPlayerTarget = instanceof(target, "IsoPlayer")
    local targetModData = target.getModData and target:getModData() or nil
    local targetUUID = targetModData and targetModData.DTNPC_UUID or nil
    local targetNPCData = (DTNPC and DTNPC.GetData and DTNPC.GetData(target))
        or (targetModData and (targetModData.DTNPC_Data or targetModData.DTNPCBrain))
        or (targetUUID and DTNPCManager and DTNPCManager.Data and DTNPCManager.Data[targetUUID])
        or nil
    local isDTNPCTarget = targetNPCData ~= nil
        and targetModData ~= nil
        and (targetModData.IsDTNPC == true or targetUUID ~= nil)

    damage = DT_DamageSystem.GetScaledDamage(npcData, attackType, weaponItem)
    local hitEffects = DT_DamageSystem.CalculateHitEffects(npcData, target, damage, attackType)
    damage = hitEffects.damage

    if isDTNPCTarget and DTNPCHealth and DTNPCHealth.IsCustomHealthEnabled and DTNPCHealth.IsCustomHealthEnabled(targetNPCData) then
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
            if target.setHitReaction and DTNPCProtect.CanApplyPlayerHitReaction(npcData, target) then
                target:setHitReaction("HitReaction")
            end
            playSuccessfulHitSound(zombie, target, weaponItem, attackType)

            applied = true
        end
    elseif attackType == "ranged" then
        if weaponItem then
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
                playSuccessfulHitSound(zombie, target, weaponItem, attackType)
            end
        end
    elseif attackType == "melee" then
        if weaponItem then
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
                playSuccessfulHitSound(zombie, target, weaponItem, attackType)
            end
        end
    end

    if not applied then
        target:setHealth(target:getHealth() - damage)
        playSuccessfulHitSound(zombie, target, weaponItem, attackType)
        applied = true
    end

    local killed = target:isDead() or target:getHealth() <= 0
    if killed then
        if not target:isDead() then
            target:Kill(zombie)
        end
    elseif target.setHitReaction
        and (not isPlayerTarget or DTNPCProtect.CanApplyPlayerHitReaction(npcData, target)) then
        target:setHitReaction(attackType == "ranged" and "ShotBelly" or "HitReaction")
    end

    if applied and not killed and not isPlayerTarget and not isDTNPCTarget then
        if DTNPC_ZombieAggro and DTNPC_ZombieAggro.OnZombieProvoked then
            DTNPC_ZombieAggro.OnZombieProvoked(target, zombie)
        elseif target.pathToLocation then
            target:pathToLocation(zombie:getX(), zombie:getY(), zombie:getZ())
        end
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

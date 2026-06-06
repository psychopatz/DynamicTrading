-- ==============================================================================
-- DTNPC_ProtectCombat_Hit.lua
-- Combat hit application for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local getAttackWeaponItem = Internal.ProtectCombatGetAttackWeaponItem
local playSuccessfulHitSound = Internal.ProtectCombatPlaySuccessfulHitSound

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
    return 0
end

local function addBodyPartCandidate(parts, partType, weight)
    if partType then
        parts[#parts + 1] = {
            partType = partType,
            weight = math.max(1, tonumber(weight) or 1),
        }
    end
end

local function choosePlayerHitBodyPart(bodyDamage)
    if not bodyDamage or not bodyDamage.getBodyPart or not BodyPartType then
        return nil
    end

    local parts = {}
    addBodyPartCandidate(parts, BodyPartType.Torso_Upper, 5)
    addBodyPartCandidate(parts, BodyPartType.Torso_Lower, 4)
    addBodyPartCandidate(parts, BodyPartType.UpperArm_L, 2)
    addBodyPartCandidate(parts, BodyPartType.UpperArm_R, 2)
    addBodyPartCandidate(parts, BodyPartType.ForeArm_L, 2)
    addBodyPartCandidate(parts, BodyPartType.ForeArm_R, 2)
    addBodyPartCandidate(parts, BodyPartType.UpperLeg_L, 2)
    addBodyPartCandidate(parts, BodyPartType.UpperLeg_R, 2)
    addBodyPartCandidate(parts, BodyPartType.LowerLeg_L, 1)
    addBodyPartCandidate(parts, BodyPartType.LowerLeg_R, 1)
    addBodyPartCandidate(parts, BodyPartType.Head, 1)

    local totalWeight = 0
    for i = 1, #parts do
        totalWeight = totalWeight + parts[i].weight
    end
    if totalWeight <= 0 then
        return nil
    end

    local roll = ZombRand and ZombRand(totalWeight) or math.floor(totalWeight * 0.5)
    local cursor = 0
    for i = 1, #parts do
        cursor = cursor + parts[i].weight
        if roll < cursor then
            return bodyDamage:getBodyPart(parts[i].partType)
        end
    end

    return bodyDamage:getBodyPart(BodyPartType.Torso_Upper)
end

local function setBodyPartBleeding(bodyPart, seconds)
    if not bodyPart or not bodyPart.setBleedingTime then
        return false
    end

    local current = tonumber(bodyPart.getBleedingTime and bodyPart:getBleedingTime() or 0) or 0
    bodyPart:setBleedingTime(math.max(current, tonumber(seconds) or 0))
    return true
end

local function arePlayerWoundsEnabled()
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    if sandbox and sandbox.NPCPlayerWounds ~= nil then
        return sandbox.NPCPlayerWounds == true
    end
    return true
end

local function addPlayerWoundEffects(bodyPart, attackType, damage, weaponItem)
    if not bodyPart then
        return
    end

    local resolvedDamage = math.max(0, tonumber(damage) or 0)
    if bodyPart.setAdditionalPain then
        local currentPain = tonumber(bodyPart.getAdditionalPain and bodyPart:getAdditionalPain() or 0) or 0
        bodyPart:setAdditionalPain(math.min(100, currentPain + math.max(3, resolvedDamage * 0.35)))
    end

    local isRanged = attackType == "ranged"
    local maxWeaponDamage = weaponItem and weaponItem.getMaxDamage and tonumber(weaponItem:getMaxDamage()) or 0
    local heavyMelee = attackType == "melee" and maxWeaponDamage >= 1.2
    if isRanged or heavyMelee or resolvedDamage >= 12 then
        setBodyPartBleeding(bodyPart, isRanged and 45 or 25)
    end

    if bodyPart.setCutTime and (heavyMelee or resolvedDamage >= 16) then
        local currentCut = tonumber(bodyPart.getCutTime and bodyPart:getCutTime() or 0) or 0
        bodyPart:setCutTime(math.max(currentCut, 8))
    elseif bodyPart.setScratchTime and attackType == "melee" then
        local currentScratch = tonumber(bodyPart.getScratchTime and bodyPart:getScratchTime() or 0) or 0
        bodyPart:setScratchTime(math.max(currentScratch, 6))
    end
end

local function reducePlayerOverallHealth(target, bodyDamage, damage, attackType)
    if not target or not bodyDamage then
        return false, false
    end

    local resolvedDamage = math.max(0, tonumber(damage) or 0)
    if resolvedDamage <= 0 then
        return false, false
    end

    local healthLoss = resolvedDamage * (attackType == "ranged" and 0.42 or 0.34)
    healthLoss = clamp(healthLoss, 0.65, attackType == "ranged" and 22 or 16)
    local killed = false
    local changed = false

    if bodyDamage.getOverallBodyHealth and bodyDamage.setOverallBodyHealth then
        local currentHealth = tonumber(bodyDamage:getOverallBodyHealth()) or 100
        local newHealth = math.max(0, currentHealth - healthLoss)
        bodyDamage:setOverallBodyHealth(newHealth)
        killed = newHealth <= 0
        changed = true
    elseif bodyDamage.ReduceGeneralHealth then
        bodyDamage:ReduceGeneralHealth(healthLoss)
        local currentHealth = bodyDamage.getOverallBodyHealth and tonumber(bodyDamage:getOverallBodyHealth()) or nil
        killed = currentHealth ~= nil and currentHealth <= 0
        changed = true
    elseif target.getHealth and target.setHealth then
        local currentHealth = tonumber(target:getHealth()) or 1
        target:setHealth(math.max(0, currentHealth - (healthLoss / 100)))
        killed = target.getHealth and (tonumber(target:getHealth()) or 0) <= 0 or false
        changed = true
    end

    return changed, killed
end

local function syncPlayerDamage(target, bodyDamage)
    if bodyDamage and bodyDamage.Update then
        bodyDamage:Update()
    end
    if target and target.sendPlayerStatsPacket then
        pcall(function()
            target:sendPlayerStatsPacket()
        end)
    end
end

function DTNPCProtect.ApplyZombieShove(zombie, npcData, targetZombie, options)
    if not zombie or not npcData or not targetZombie or targetZombie:isDead() then
        return false
    end

    local targetModData = targetZombie.getModData and targetZombie:getModData() or nil
    if targetModData and targetModData.IsDTNPC == true then
        return false
    end
    if targetZombie.getVariableBoolean and targetZombie:getVariableBoolean("Bandit") then
        return false
    end

    local capable = true
    if DTNPCProtect.IsCombatCapable then
        capable = DTNPCProtect.IsCombatCapable(zombie, npcData) == true
    end
    if not capable then
        return false
    end

    options = type(options) == "table" and options or {}

    if targetZombie.setAttackedBy then
        targetZombie:setAttackedBy(zombie)
    end
    if targetZombie.setPlayerAttackPosition and targetZombie.testDotSide then
        targetZombie:setPlayerAttackPosition(targetZombie:testDotSide(zombie))
    end
    if targetZombie.setHitFromBehind and zombie.isBehind then
        local ok, behind = pcall(function()
            return zombie:isBehind(targetZombie)
        end)
        if ok then
            targetZombie:setHitFromBehind(behind == true)
        end
    end
    if targetZombie.setHitForce then
        targetZombie:setHitForce(math.max(1.0, tonumber(options.hitForce) or 1.15))
    end
    if targetZombie.setStaggerBack then
        pcall(targetZombie.setStaggerBack, targetZombie, true)
    end
    if targetZombie.setKnockedDown then
        targetZombie:setKnockedDown(true)
    end
    if targetZombie.pathToCharacter then
        targetZombie:pathToCharacter(zombie)
    end

    local currentTime = nowMillis()
    local retreatLockMs = math.max(150, tonumber(options.retreatLockMs) or 900)
    npcData.damageRetreatUntil = math.max(tonumber(npcData.damageRetreatUntil) or 0, currentTime + retreatLockMs)
    npcData.damageRetreatFromX = targetZombie:getX()
    npcData.damageRetreatFromY = targetZombie:getY()
    npcData._dtLastZombieShoveAt = currentTime

    if DTNPC and DTNPC.SetMeleeCombatIdleState then
        DTNPC.SetMeleeCombatIdleState(zombie, npcData)
    end

    return true
end

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
    local forceKilled = false
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

    if damage <= 0.1 then
        damage = DT_DamageSystem.GetScaledDamage(npcData, attackType, weaponItem)
    end
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
        local bodyPart = choosePlayerHitBodyPart(bodyDamage)

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
            end

            if arePlayerWoundsEnabled() then
                addPlayerWoundEffects(bodyPart, attackType, appliedDamage, weaponItem)
            end

            local _, killedByHealth = reducePlayerOverallHealth(target, bodyDamage, appliedDamage, attackType)
            forceKilled = killedByHealth == true
            syncPlayerDamage(target, bodyDamage)
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

    local killed = forceKilled or target:isDead() or target:getHealth() <= 0
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

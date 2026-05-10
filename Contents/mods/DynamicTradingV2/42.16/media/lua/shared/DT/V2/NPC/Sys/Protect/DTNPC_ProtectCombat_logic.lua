-- ==============================================================================
-- DTNPC_ProtectCombat_logic.lua
-- Combat stats and hit resolution for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local clamp = Internal.clamp
local nowMillis = Internal.nowMillis
local getZombieRuntimeID = Internal.getZombieRuntimeID
local getPlayerRuntimeID = Internal.getPlayerRuntimeID

local COMBAT_RHYTHM_RESET_MS = 4500

local COMBAT_FLAVOR = {
    meleeRecovery = {
        "Need a breath.",
        "Backing off a step.",
        "Easy. Re-center.",
        "Hold still. Not done yet.",
    },
    rangedRecovery = {
        "Hold. Repositioning.",
        "Need a cleaner shot.",
        "Give me a second.",
        "Backing up for space.",
    },
}

local function rollInt(minValue, maxValue)
    local safeMin = math.floor(tonumber(minValue) or 0)
    local safeMax = math.floor(tonumber(maxValue) or safeMin)
    if safeMax < safeMin then
        safeMax = safeMin
    end
    if safeMax <= safeMin then
        return safeMin
    end
    return safeMin + ZombRand((safeMax - safeMin) + 1)
end

local function getNearbyZombiePressure(originX, originY, originZ, radius, excludedIDs)
    local zombieList = getCell() and getCell():getZombieList() or nil
    if not zombieList then
        return {
            count = 0,
            closest = 9999,
            centerX = originX,
            centerY = originY,
        }
    end

    local safeRadius = math.max(0.25, tonumber(radius) or DTNPCProtect.CONFIG.MeleeCrowdDangerRadius or 2.4)
    local radiusSq = safeRadius * safeRadius
    local count = 0
    local closest = 9999
    local weightedX = 0
    local weightedY = 0
    local totalWeight = 0

    for i = 0, zombieList:size() - 1 do
        local candidate = zombieList:get(i)
        if candidate and not candidate:isDead() then
            local modData = candidate:getModData()
            if not (modData and modData.IsDTNPC)
                and math.abs((candidate:getZ() or 0) - (originZ or 0)) <= DTNPCProtect.CONFIG.FloorTolerance then
                local candidateID = getZombieRuntimeID(candidate)
                if not (excludedIDs and excludedIDs[candidateID]) then
                    local dx = candidate:getX() - originX
                    local dy = candidate:getY() - originY
                    local distSq = (dx * dx) + (dy * dy)
                    if distSq <= radiusSq then
                        local dist = math.sqrt(distSq)
                        local weight = 1 / math.max(0.25, dist)
                        count = count + 1
                        closest = math.min(closest, dist)
                        weightedX = weightedX + (candidate:getX() * weight)
                        weightedY = weightedY + (candidate:getY() * weight)
                        totalWeight = totalWeight + weight
                    end
                end
            end
        end
    end

    return {
        count = count,
        closest = closest,
        centerX = totalWeight > 0 and (weightedX / totalWeight) or originX,
        centerY = totalWeight > 0 and (weightedY / totalWeight) or originY,
    }
end

function DTNPCProtect.GetNearbyZombiePressure(zombie, radius, excludedIDs)
    if not zombie then
        return {
            count = 0,
            closest = 9999,
            centerX = 0,
            centerY = 0,
        }
    end

    return getNearbyZombiePressure(zombie:getX(), zombie:getY(), zombie:getZ(), radius, excludedIDs)
end

local function resolveCombatTargetKey(target)
    if not target then
        return nil
    end
    if instanceof and instanceof(target, "IsoPlayer") then
        return getPlayerRuntimeID and getPlayerRuntimeID(target) or tostring(target)
    end
    return getZombieRuntimeID and getZombieRuntimeID(target) or tostring(target)
end

local function getCombatRhythmBucket(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local rhythm = type(npcData._combatRhythm) == "table" and npcData._combatRhythm or {}
    npcData._combatRhythm = rhythm

    if type(rhythm.flavorTimes) ~= "table" then
        rhythm.flavorTimes = {}
    end

    return rhythm
end

local function recordLinkedWorkerCombatAttack(npcData, attackType)
    if not npcData or not npcData.linkedWorkerID then
        return false
    end

    local colony = type(DC_Colony) == "table" and DC_Colony or nil
    local companion = colony and type(colony.Companion) == "table" and colony.Companion or nil
    if not companion or type(companion.RecordCombatAttack) ~= "function" then
        return false
    end

    local ok = pcall(function()
        companion.RecordCombatAttack(npcData.linkedWorkerID, npcData, attackType, {
            source = "DTNPCProtect",
        })
    end)

    return ok == true
end

local function resetCombatRhythmBucket(rhythm)
    if not rhythm then
        return
    end

    rhythm.targetKey = nil
    rhythm.attackType = nil
    rhythm.burstCount = 0
    rhythm.burstLimit = nil
    rhythm.recoveryUntil = 0
    rhythm.recoveryDistance = nil
    rhythm.lastAttackAt = 0
end

local function pushCombatFlavor(zombie, npcData, flavorKey, sentiment, cooldownMs)
    local lines = COMBAT_FLAVOR[flavorKey]
    if not lines or #lines == 0 then
        return false
    end

    local rhythm = getCombatRhythmBucket(npcData)
    local currentTime = nowMillis()
    local safeCooldown = math.max(0, tonumber(cooldownMs) or 3500)
    local lastTime = tonumber(rhythm.flavorTimes[flavorKey]) or 0
    if currentTime > 0 and lastTime > 0 and (currentTime - lastTime) < safeCooldown then
        return false
    end

    rhythm.flavorTimes[flavorKey] = currentTime

    if DTNPCProtect.PushCompanionNotice then
        local index = rollInt(1, #lines)
        return DTNPCProtect.PushCompanionNotice(zombie, npcData, lines[index], sentiment or "neutral")
    end

    return false
end

function DTNPCProtect.ResetCombatRhythm(npcData)
    if not npcData then
        return false
    end

    local rhythm = getCombatRhythmBucket(npcData)
    resetCombatRhythmBucket(rhythm)
    npcData.combatRecoveryUntil = nil
    return true
end

function DTNPCProtect.GetCombatRhythmProfile(npcData, attackType)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local isRanged = attackType == "ranged"
    local skillID = isRanged and "Shooting" or "Melee"
    local skill = DTNPCProtect.GetSkillLevel(npcData, skillID)
    local normalized = math.min(math.max(skill, 0), 20) / 20

    if isRanged then
        return {
            attackType = attackType,
            skill = skill,
            normalized = normalized,
            burstMin = 1 + math.floor(normalized * 2),
            burstMax = 3 + math.floor(normalized * 2),
            recoveryMinMs = math.floor(1500 - (normalized * 450)),
            recoveryMaxMs = math.floor(2800 - (normalized * 700)),
            recoveryDistance = 6.25 + ((1 - normalized) * 1.5),
            flavorChance = math.floor(42 + (normalized * 18)),
            flavorKey = "rangedRecovery",
            flavorSentiment = "warning",
        }
    end

    return {
        attackType = attackType,
        skill = skill,
        normalized = normalized,
        burstMin = 1 + math.floor(normalized * 2),
        burstMax = 2 + math.floor(normalized * 3),
        recoveryMinMs = math.floor(850 + ((1 - normalized) * 550)),
        recoveryMaxMs = math.floor(1450 + ((1 - normalized) * 800)),
        recoveryDistance = 1.35 + ((1 - normalized) * 0.45),
        flavorChance = math.floor(48 + (normalized * 14)),
        flavorKey = "meleeRecovery",
        flavorSentiment = "warning",
    }
end

function DTNPCProtect.GetCombatRecovery(npcData, attackType, target)
    if not npcData then
        return false, nil
    end

    local profile = DTNPCProtect.GetCombatRhythmProfile(npcData, attackType)
    if attackType == "melee" and DTNPCStamina and DTNPCStamina.IsMeleeFatigued and DTNPCStamina.IsMeleeFatigued(npcData) then
        local untilTime = DTNPCStamina.GetMeleeRecoveryUntil and DTNPCStamina.GetMeleeRecoveryUntil(npcData) or 0
        npcData.combatRecoveryUntil = untilTime
        return true, {
            untilTime = untilTime,
            distance = math.max((profile and profile.recoveryDistance or 1.6) + 0.85, 2.5),
            profile = profile,
            reason = "stamina",
        }
    end

    local rhythm = getCombatRhythmBucket(npcData)
    local currentTime = nowMillis()
    local targetKey = resolveCombatTargetKey(target)
    local lastAttackAt = tonumber(rhythm.lastAttackAt) or 0

    if targetKey == nil then
        resetCombatRhythmBucket(rhythm)
        return false, profile
    end

    if rhythm.targetKey ~= targetKey
        or rhythm.attackType ~= attackType
        or (currentTime > 0 and lastAttackAt > 0 and (currentTime - lastAttackAt) > COMBAT_RHYTHM_RESET_MS) then
        resetCombatRhythmBucket(rhythm)
        rhythm.targetKey = targetKey
        rhythm.attackType = attackType
        rhythm.burstLimit = rollInt(profile.burstMin, profile.burstMax)
    elseif not rhythm.burstLimit then
        rhythm.burstLimit = rollInt(profile.burstMin, profile.burstMax)
    end

    local recoveryUntil = tonumber(rhythm.recoveryUntil) or 0
    if recoveryUntil > 0 and currentTime > 0 and currentTime < recoveryUntil then
        return true, {
            untilTime = recoveryUntil,
            distance = tonumber(rhythm.recoveryDistance) or profile.recoveryDistance,
            profile = profile,
            reason = "rhythm",
        }
    end

    if recoveryUntil > 0 and currentTime > 0 and currentTime >= recoveryUntil then
        rhythm.recoveryUntil = 0
        rhythm.recoveryDistance = nil
        npcData.combatRecoveryUntil = nil
    end

    return false, {
        untilTime = 0,
        distance = profile.recoveryDistance,
        profile = profile,
        reason = nil,
    }
end

function DTNPCProtect.RecordCombatAttack(zombie, npcData, attackType, target)
    if not npcData then
        return false, nil
    end

    if DTNPCCombat and DTNPCCombat.NotifyAttack then
        DTNPCCombat.NotifyAttack(zombie, npcData, attackType, target)
    end
    if attackType == "melee" and DTNPCStamina and DTNPCStamina.ConsumeMeleeAttack then
        DTNPCStamina.ConsumeMeleeAttack(zombie, npcData)
    end
    if DTNPC_ZombieAggro and DTNPC_ZombieAggro.EmitCombatNoise then
        local emitted = DTNPC_ZombieAggro.EmitCombatNoise(zombie, npcData, attackType)
        if emitted ~= true and DTNPC_ZombieAggro.ApplyCombatStimuli then
            DTNPC_ZombieAggro.ApplyCombatStimuli()
        end
    end
    recordLinkedWorkerCombatAttack(npcData, attackType)

    local recovering, recoveryState = DTNPCProtect.GetCombatRecovery(npcData, attackType, target)
    if recovering then
        return true, recoveryState
    end

    local rhythm = getCombatRhythmBucket(npcData)
    local profile = recoveryState and recoveryState.profile or DTNPCProtect.GetCombatRhythmProfile(npcData, attackType)
    local currentTime = nowMillis()

    rhythm.lastAttackAt = currentTime
    rhythm.burstCount = (tonumber(rhythm.burstCount) or 0) + 1

    local burstLimit = tonumber(rhythm.burstLimit) or rollInt(profile.burstMin, profile.burstMax)
    if rhythm.burstCount < burstLimit then
        return false, {
            untilTime = 0,
            distance = profile.recoveryDistance,
            profile = profile,
            reason = nil,
        }
    end

    rhythm.burstCount = 0
    rhythm.burstLimit = rollInt(profile.burstMin, profile.burstMax)
    rhythm.recoveryDistance = profile.recoveryDistance
    rhythm.recoveryUntil = currentTime + rollInt(profile.recoveryMinMs, profile.recoveryMaxMs)
    npcData.combatRecoveryUntil = rhythm.recoveryUntil

    if ZombRand(100) < (profile.flavorChance or 0) then
        pushCombatFlavor(zombie, npcData, profile.flavorKey, profile.flavorSentiment, 3000)
    end

    return true, {
        untilTime = rhythm.recoveryUntil,
        distance = rhythm.recoveryDistance,
        profile = profile,
        reason = "rhythm",
    }
end

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

local function playEmitterSound(character, soundName)
    if not character or not soundName or soundName == "" then
        return false
    end

    local emitter = character.getEmitter and character:getEmitter() or nil
    if emitter and emitter.playSound then
        emitter:playSound(soundName)
        return true
    end

    return false
end

local function getAttackWeaponItem(npcData, attackType)
    if attackType == "ranged" then
        return DTNPCProtect.CreateLoadoutWeaponItem(npcData, "ranged")
    end
    if attackType == "melee" then
        return DTNPCProtect.CreateLoadoutWeaponItem(npcData, "melee")
    end
    return nil
end

local function scaleWeaponDamage(npcData, attackType, baseDamage, weaponItem)
    local damage = math.max(0.05, tonumber(baseDamage) or 0.1)
    if not weaponItem then
        return damage
    end

    if attackType == "ranged" then
        local shootingSkill = DTNPCProtect.GetSkillLevel(npcData, "Shooting")
        local normalized = math.min(math.max(shootingSkill, 0), 20) / 20
        return math.max(damage, rollWeaponDamage(weaponItem) * (0.75 + (normalized * 0.75)))
    end

    if attackType == "melee" then
        local meleeSkill = DTNPCProtect.GetSkillLevel(npcData, "Melee")
        local normalized = math.min(math.max(meleeSkill, 0), 20) / 20
        return math.max(damage, rollWeaponDamage(weaponItem) * (0.8 + (normalized * 0.9)))
    end

    return damage
end

local function playSuccessfulHitSound(zombie, target, weaponItem, attackType)
    if attackType == "ranged" then
        playEmitterSound(target, "ImpactFlesh")
        return
    end

    local swingSound = weaponItem and weaponItem.getSwingSound and weaponItem:getSwingSound() or nil
    local hitSound = weaponItem and weaponItem.getZombieHitSound and weaponItem:getZombieHitSound() or nil

    if playEmitterSound(zombie, swingSound) then
        return
    end
    if target and target.playSound and hitSound and hitSound ~= "" then
        target:playSound(hitSound)
        return
    end
    if playEmitterSound(target, hitSound) then
        return
    end
    playEmitterSound(target, "ImpactFlesh")
end

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
        attackRate = math.max(24, math.floor(42 - (normalized * 16))),
        damage = math.max(0.45, scaledDamage),
        chaseSpeed = 0.045 + (normalized * 0.02),
        reach = clamp(weaponRange + 0.15, 1.15, 1.9),
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
    local recentDamageAmount = 0

    if combatHealth and combatHealth.lastAttackerType == "zombie" then
        local lastDamageAt = tonumber(combatHealth.lastDamageAt) or 0
        if lastDamageAt > 0
            and (currentTime - lastDamageAt) <= (tonumber(DTNPCProtect.CONFIG.MeleeRecentZombieDamageWindowMs) or 4500) then
            recentZombieDamage = true
            recentDamageAmount = math.max(0, tonumber(combatHealth.lastDamageAmount) or 0)
        end
    end

    local excludedIDs = {}
    local targetID = target and getZombieRuntimeID(target) or nil
    if targetID then
        excludedIDs[targetID] = true
    end

    local selfPressure = DTNPCProtect.GetNearbyZombiePressure(
        zombie,
        tonumber(options.pressureRadius) or DTNPCProtect.CONFIG.MeleeCrowdDangerRadius,
        nil
    )
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
        and (selfPressure.count >= math.max(2, crowdThreshold - 1) or lowHealth or recentZombieDamage)
    local surrounded = selfPressure.count >= crowdThreshold
    local severeCrowd = selfPressure.count >= severeThreshold or targetCrowdDanger
    local pressured = recentZombieDamage and (selfPressure.count >= math.max(2, crowdThreshold - 1) or targetPressure.count >= 2)

    if healthRatio > 0.72 and not recentZombieDamage and not severeCrowd then
        surrounded = false
    end

    if not (surrounded or severeCrowd or (lowHealth and selfPressure.count >= 2) or pressured) then
        return {
            shouldDisengage = false,
            selfPressure = selfPressure,
            targetPressure = targetPressure,
            recentZombieDamage = recentZombieDamage,
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
        targetPressure = targetPressure,
        recentZombieDamage = recentZombieDamage,
        recentDamageAmount = recentDamageAmount,
        healthRatio = healthRatio,
    }
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
    local weaponItem = getAttackWeaponItem(npcData, attackType)
    local isPlayerTarget = instanceof(target, "IsoPlayer")
    local targetModData = target.getModData and target:getModData() or nil
    local targetNPCData = targetModData and (targetModData.DTNPC_Data or targetModData.DTNPCBrain) or nil
    local isDTNPCTarget = targetModData and targetModData.IsDTNPC == true and targetNPCData ~= nil

    damage = scaleWeaponDamage(npcData, attackType, damage, weaponItem)

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

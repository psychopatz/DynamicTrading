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
            burstMin = 2 + math.floor(normalized * 2),
            burstMax = 4 + math.floor(normalized * 3),
            recoveryMinMs = math.floor(1200 - (normalized * 450)),
            recoveryMaxMs = math.floor(2200 - (normalized * 700)),
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
        burstMax = 3 + math.floor(normalized * 3),
        recoveryMinMs = math.floor(900 + ((1 - normalized) * 1100)),
        recoveryMaxMs = math.floor(1600 + ((1 - normalized) * 1400)),
        recoveryDistance = 1.85 + ((1 - normalized) * 0.9),
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
        }
    end

    if recoveryUntil > 0 and currentTime > 0 and currentTime >= recoveryUntil then
        rhythm.recoveryUntil = 0
        rhythm.recoveryDistance = nil
    end

    return false, {
        untilTime = 0,
        distance = profile.recoveryDistance,
        profile = profile,
    }
end

function DTNPCProtect.RecordCombatAttack(zombie, npcData, attackType, target)
    if not npcData then
        return false, nil
    end

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
        }
    end

    rhythm.burstCount = 0
    rhythm.burstLimit = rollInt(profile.burstMin, profile.burstMax)
    rhythm.recoveryDistance = profile.recoveryDistance
    rhythm.recoveryUntil = currentTime + rollInt(profile.recoveryMinMs, profile.recoveryMaxMs)

    if ZombRand(100) < (profile.flavorChance or 0) then
        pushCombatFlavor(zombie, npcData, profile.flavorKey, profile.flavorSentiment, 3000)
    end

    return true, {
        untilTime = rhythm.recoveryUntil,
        distance = rhythm.recoveryDistance,
        profile = profile,
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
            if target.setHitReaction then
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

-- ==============================================================================
-- DTNPC_ProtectCombat_Rhythm.lua
-- Combat rhythm, recovery, and recovery flavor text for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local nowMillis = Internal.nowMillis
local rollInt = Internal.ProtectCombatRollInt
local resolveCombatTargetKey = Internal.ResolveCombatTargetKey
local getCombatRhythmBucket = Internal.GetCombatRhythmBucket
local recordLinkedWorkerCombatAttack = Internal.RecordLinkedWorkerCombatAttack
local resetCombatRhythmBucket = Internal.ResetCombatRhythmBucket
local combatRhythmResetMs = Internal.ProtectCombatRhythmResetMs or 4500

local function getCombatFlavorLine(kind)
    local line = DynamicTrading
        and DynamicTrading.FlavorText
        and DynamicTrading.FlavorText.GetRandom
        and DynamicTrading.FlavorText.GetRandom("CompanionCombat", kind)
        or nil
    if line and line ~= "" then
        return line
    end
    return nil
end

local function pushCombatFlavor(zombie, npcData, flavorKey, sentiment, cooldownMs)
    local line = getCombatFlavorLine(flavorKey)
    if not line or line == "" then
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
        return DTNPCProtect.PushCompanionNotice(zombie, npcData, line, sentiment or "neutral")
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
            flavorKey = "ProtectRangedRecovery",
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
        flavorKey = "ProtectMeleeRecovery",
        flavorSentiment = "warning",
    }
end

function DTNPCProtect.GetCombatRecovery(npcData, attackType, target)
    if not npcData then
        return false, nil
    end

    local profile = DTNPCProtect.GetCombatRhythmProfile(npcData, attackType)
    if DTNPCStamina then
        local isFatigued = nil
        local getRecoveryUntil = nil
        local recoveryExtraDistance = attackType == "ranged" and 0.35 or 0.85
        local recoveryMinDistance = attackType == "ranged" and 4.5 or 2.5
        local recoveryBaseDistance = attackType == "ranged" and 6.25 or 1.6

        if attackType == "ranged" then
            isFatigued = DTNPCStamina.IsRangedFatigued
            getRecoveryUntil = DTNPCStamina.GetRangedRecoveryUntil
        else
            isFatigued = DTNPCStamina.IsMeleeFatigued
            getRecoveryUntil = DTNPCStamina.GetMeleeRecoveryUntil
        end

        if isFatigued and isFatigued(npcData) then
            local untilTime = getRecoveryUntil and getRecoveryUntil(npcData) or 0
            npcData.combatRecoveryUntil = untilTime
            return true, {
                untilTime = untilTime,
                distance = math.max((profile and profile.recoveryDistance or recoveryBaseDistance) + recoveryExtraDistance, recoveryMinDistance),
                profile = profile,
                reason = "stamina",
            }
        end
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
        or (currentTime > 0 and lastAttackAt > 0 and (currentTime - lastAttackAt) > combatRhythmResetMs) then
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

    local recovering, recoveryState = DTNPCProtect.GetCombatRecovery(npcData, attackType, target)
    if recovering then
        return true, recoveryState
    end

    if DTNPCCombat and DTNPCCombat.NotifyAttack then
        DTNPCCombat.NotifyAttack(zombie, npcData, attackType, target)
    end

    if attackType == "melee" and DTNPCStamina and DTNPCStamina.ConsumeMeleeAttack then
        DTNPCStamina.ConsumeMeleeAttack(zombie, npcData)
    elseif attackType == "ranged" and DTNPCStamina and DTNPCStamina.ConsumeRangedAttack then
        DTNPCStamina.ConsumeRangedAttack(zombie, npcData)
    end

    if DTNPC_ZombieAggro and DTNPC_ZombieAggro.EmitCombatNoise then
        local emitted = DTNPC_ZombieAggro.EmitCombatNoise(zombie, npcData, attackType)
        if emitted ~= true and DTNPC_ZombieAggro.ApplyCombatStimuli then
            DTNPC_ZombieAggro.ApplyCombatStimuli()
        end
    end

    recordLinkedWorkerCombatAttack(npcData, attackType)

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

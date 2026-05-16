-- ==============================================================================
-- DTNPC_Stamina_MeleeFatigue.lua
-- Combat attack stamina drain and fatigue gating.
-- ==============================================================================

DTNPCStamina = DTNPCStamina or {}
DTNPCStamina.Internal = DTNPCStamina.Internal or {}

local Stamina = DTNPCStamina
local Internal = DTNPCStamina.Internal
local nowMillis = Internal.nowMillis
local getAttackDrainAmount = Internal.getAttackDrainAmount
local markVisible = Internal.markVisible
local setStaminaState = Internal.setStaminaState
local adjustCurrent = Internal.adjustCurrent
local meleeResumeRatio = Internal.MeleeResumeRatio or 0.30
local pushCue = Internal.pushCue

local function resolveAttackType(attackType)
    if attackType == "ranged" then
        return "ranged"
    end
    return "melee"
end

local function getFatigueStateKey(attackType)
    return attackType == "ranged" and "_dtRangedFatigueActive" or "_dtMeleeFatigueActive"
end

local function getFatigueUntilKey(attackType)
    return attackType == "ranged" and "_dtRangedFatigueUntil" or "_dtMeleeFatigueUntil"
end

local function getRecoveryStateName(attackType)
    return attackType == "ranged" and "ranged_recovering" or "melee_recovering"
end

local function getFatigueCueKind(attackType)
    return attackType == "ranged" and "RangedFatigue" or "MeleeFatigue"
end

local function consumeAttack(zombie, npcData, attackType)
    if type(npcData) ~= "table" then
        return false
    end

    attackType = resolveAttackType(attackType)

    Stamina.EnsureDefaults(npcData)

    local drainAmount, normalized = getAttackDrainAmount(npcData, attackType)
    local currentValue, maxValue = adjustCurrent(npcData, -drainAmount)
    markVisible(npcData, 4200)
    npcData._dtLastStaminaActivityAt = nowMillis()

    if currentValue <= (maxValue * 0.18) then
        local fatigueMs = math.floor(950 + ((1 - normalized) * 700))
        local currentTime = nowMillis()
        local fatigueUntilKey = getFatigueUntilKey(attackType)
        local fatigueStateKey = getFatigueStateKey(attackType)
        local previousUntil = tonumber(npcData[fatigueUntilKey]) or 0
        npcData[fatigueStateKey] = true
        npcData[fatigueUntilKey] = math.max(previousUntil, currentTime + fatigueMs)
        setStaminaState(npcData, getRecoveryStateName(attackType))
        pushCue(zombie, npcData, getFatigueCueKind(attackType), "warning", 6500)
        return true
    end

    return false
end

local function isAttackFatigued(npcData, attackType)
    if type(npcData) ~= "table" then
        return false
    end

    attackType = resolveAttackType(attackType)
    Stamina.EnsureDefaults(npcData)

    local currentTime = nowMillis()
    local fatigueUntilKey = getFatigueUntilKey(attackType)
    local fatigueStateKey = getFatigueStateKey(attackType)
    local untilTime = tonumber(npcData[fatigueUntilKey]) or 0
    local active = npcData[fatigueStateKey] == true
    if untilTime <= 0 and not active then
        return false
    end

    local ratio = Stamina.GetRatio(npcData)

    if currentTime < untilTime then
        return true
    end

    if active and ratio < meleeResumeRatio then
        npcData[fatigueUntilKey] = currentTime + 250
        return true
    end

    if ratio <= 0.22 then
        npcData[fatigueStateKey] = true
        npcData[fatigueUntilKey] = currentTime + 250
        return true
    end

    npcData[fatigueStateKey] = false
    npcData[fatigueUntilKey] = 0
    return false
end

local function getAttackRecoveryUntil(npcData, attackType)
    attackType = resolveAttackType(attackType)
    if not isAttackFatigued(npcData, attackType) then
        return 0
    end
    return tonumber(npcData[getFatigueUntilKey(attackType)]) or 0
end

function Stamina.ConsumeCombatAttack(zombie, npcData, attackType)
    return consumeAttack(zombie, npcData, attackType)
end

function Stamina.ConsumeMeleeAttack(zombie, npcData)
    return consumeAttack(zombie, npcData, "melee")
end

function Stamina.ConsumeRangedAttack(zombie, npcData)
    return consumeAttack(zombie, npcData, "ranged")
end

function Stamina.IsCombatFatigued(npcData, attackType)
    return isAttackFatigued(npcData, attackType)
end

function Stamina.IsMeleeFatigued(npcData)
    return isAttackFatigued(npcData, "melee")
end

function Stamina.IsRangedFatigued(npcData)
    return isAttackFatigued(npcData, "ranged")
end

function Stamina.GetCombatRecoveryUntil(npcData, attackType)
    return getAttackRecoveryUntil(npcData, attackType)
end

function Stamina.GetMeleeRecoveryUntil(npcData)
    return getAttackRecoveryUntil(npcData, "melee")
end

function Stamina.GetRangedRecoveryUntil(npcData)
    return getAttackRecoveryUntil(npcData, "ranged")
end

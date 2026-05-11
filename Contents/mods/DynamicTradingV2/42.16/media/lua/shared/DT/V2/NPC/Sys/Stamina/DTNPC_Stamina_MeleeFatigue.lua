-- ==============================================================================
-- DTNPC_Stamina_MeleeFatigue.lua
-- Melee attack stamina drain and fatigue gating.
-- ==============================================================================

DTNPCStamina = DTNPCStamina or {}
DTNPCStamina.Internal = DTNPCStamina.Internal or {}

local Stamina = DTNPCStamina
local Internal = DTNPCStamina.Internal
local nowMillis = Internal.nowMillis
local getSkillNormalized = Internal.getSkillNormalized
local markVisible = Internal.markVisible
local setStaminaState = Internal.setStaminaState
local adjustCurrent = Internal.adjustCurrent
local meleeResumeRatio = Internal.MeleeResumeRatio or 0.30
local pushCue = Internal.pushCue

function Stamina.ConsumeMeleeAttack(zombie, npcData)
    if type(npcData) ~= "table" then
        return false
    end

    Stamina.EnsureDefaults(npcData)

    local normalized = getSkillNormalized(npcData)
    local drainAmount = 10.5 - (normalized * 3.0)
    local currentValue, maxValue = adjustCurrent(npcData, -drainAmount)
    markVisible(npcData, 4200)
    npcData._dtLastStaminaActivityAt = nowMillis()

    if currentValue <= (maxValue * 0.18) then
        local fatigueMs = math.floor(950 + ((1 - normalized) * 700))
        local currentTime = nowMillis()
        local previousUntil = tonumber(npcData._dtMeleeFatigueUntil) or 0
        npcData._dtMeleeFatigueActive = true
        npcData._dtMeleeFatigueUntil = math.max(previousUntil, currentTime + fatigueMs)
        setStaminaState(npcData, "melee_recovering")
        pushCue(zombie, npcData, "MeleeFatigue", "warning", 6500)
        return true
    end

    return false
end

function Stamina.IsMeleeFatigued(npcData)
    if type(npcData) ~= "table" then
        return false
    end

    Stamina.EnsureDefaults(npcData)

    local currentTime = nowMillis()
    local untilTime = tonumber(npcData._dtMeleeFatigueUntil) or 0
    local active = npcData._dtMeleeFatigueActive == true
    if untilTime <= 0 and not active then
        return false
    end

    local ratio = Stamina.GetRatio(npcData)

    if currentTime < untilTime then
        return true
    end

    if active and ratio < meleeResumeRatio then
        npcData._dtMeleeFatigueUntil = currentTime + 250
        return true
    end

    if ratio <= 0.22 then
        npcData._dtMeleeFatigueActive = true
        npcData._dtMeleeFatigueUntil = currentTime + 250
        return true
    end

    npcData._dtMeleeFatigueActive = false
    npcData._dtMeleeFatigueUntil = 0
    return false
end

function Stamina.GetMeleeRecoveryUntil(npcData)
    if not Stamina.IsMeleeFatigued(npcData) then
        return 0
    end
    return tonumber(npcData._dtMeleeFatigueUntil) or 0
end

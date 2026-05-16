-- ==============================================================================
-- DTNPC_Stamina_Shared.lua
-- Shared helpers and default state for DTNPCStamina.
-- ==============================================================================

DTNPCStamina = DTNPCStamina or {}
DTNPCStamina.Internal = DTNPCStamina.Internal or {}

local Stamina = DTNPCStamina
local Internal = DTNPCStamina.Internal

local function getSandbox()
    return SandboxVars and SandboxVars.DynamicTrading or nil
end

local function getSandboxThreshold()
    local sandbox = getSandbox()
    return tonumber(sandbox and sandbox.NPCStaminaThreshold) or 0.40
end

Internal.MoveExhaustResumeRatio = getSandboxThreshold()
Internal.MeleeResumeRatio = Internal.MoveExhaustResumeRatio * 0.75
Internal.MoveExhaustPauseRatio = 0.25

local function nowMillis()
    if getTimeInMillis then
        return getTimeInMillis()
    end
    if getGameTime and getGameTime() and getGameTime().getWorldAgeHours then
        return math.floor((tonumber(getGameTime():getWorldAgeHours()) or 0) * 3600000)
    end
    return 0
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

local function getSkillAverage(npcData)
    local melee = DTNPCProtect and DTNPCProtect.GetSkillLevel and DTNPCProtect.GetSkillLevel(npcData, "Melee") or 0
    local shooting = DTNPCProtect and DTNPCProtect.GetSkillLevel and DTNPCProtect.GetSkillLevel(npcData, "Shooting") or 0
    return ((tonumber(melee) or 0) + (tonumber(shooting) or 0)) * 0.5
end

local function getAttackSkillLevel(npcData, attackType)
    local skillID = attackType == "ranged" and "Shooting" or "Melee"
    return DTNPCProtect and DTNPCProtect.GetSkillLevel and DTNPCProtect.GetSkillLevel(npcData, skillID) or 0
end

local function getSkillNormalized(npcData)
    return clamp(getSkillAverage(npcData) / 20, 0, 1)
end

local function getAttackSkillNormalized(npcData, attackType)
    return clamp(getAttackSkillLevel(npcData, attackType) / 20, 0, 1)
end

local function getAttackBaseCost(attackType)
    local sandbox = getSandbox()
    local key = attackType == "ranged" and "NPCRangedStaminaCost" or "NPCMeleeStaminaCost"
    return math.max(0, tonumber(sandbox and sandbox[key]) or 30)
end

local function getAttackDrainAmount(npcData, attackType)
    local normalized = getAttackSkillNormalized(npcData, attackType)
    local baseCost = getAttackBaseCost(attackType)
    return math.max(0, baseCost * (1 - (normalized * 0.9))), normalized, baseCost
end

local function getMaxStaminaForSkills(npcData)
    local average = getSkillAverage(npcData)
    return math.floor(100 + (average * 2.5))
end

local function getElapsedSeconds(npcData, key, currentTime, maxMs)
    if type(npcData) ~= "table" then
        return 0
    end

    currentTime = tonumber(currentTime) or nowMillis()
    local previousTime = tonumber(npcData[key]) or 0
    npcData[key] = currentTime

    if currentTime <= 0 or previousTime <= 0 then
        return 0
    end

    local deltaMs = currentTime - previousTime
    if deltaMs < 0 then
        deltaMs = 0
    end
    if maxMs and deltaMs > maxMs then
        deltaMs = maxMs
    end

    return deltaMs / 1000
end

local function markVisible(npcData, durationMs)
    if type(npcData) ~= "table" then
        return
    end

    local currentTime = nowMillis()
    local untilTime = currentTime + math.max(500, math.floor(tonumber(durationMs) or 0))
    local previous = tonumber(npcData._dtStaminaVisibleUntil) or 0
    npcData._dtStaminaVisibleUntil = math.max(previous, untilTime)
end

local function setStaminaState(npcData, state)
    if type(npcData) ~= "table" then
        return false
    end

    local resolved = tostring(state or "fresh")
    if npcData.staminaState == resolved then
        return false
    end

    npcData.staminaState = resolved
    return true
end

local function adjustCurrent(npcData, delta)
    if type(npcData) ~= "table" then
        return 0, 0
    end

    local maxValue = math.max(1, tonumber(npcData.staminaMax) or 1)
    local currentValue = clamp((tonumber(npcData.staminaCurrent) or maxValue) + (tonumber(delta) or 0), 0, maxValue)
    npcData.staminaCurrent = currentValue
    return currentValue, maxValue
end

function Stamina.EnsureDefaults(npcData)
    if type(npcData) ~= "table" then
        return nil
    end

    local resolvedMax = getMaxStaminaForSkills(npcData)
    local previousMax = tonumber(npcData.staminaMax)
    local currentValue = tonumber(npcData.staminaCurrent)

    if previousMax and previousMax > 0 and currentValue ~= nil and previousMax ~= resolvedMax then
        currentValue = clamp((currentValue / previousMax) * resolvedMax, 0, resolvedMax)
    end

    npcData.staminaMax = resolvedMax
    if currentValue == nil then
        currentValue = resolvedMax
    end
    npcData.staminaCurrent = clamp(currentValue, 0, resolvedMax)
    npcData.staminaState = npcData.staminaState or "fresh"
    npcData._dtSprintMode = npcData._dtSprintMode or "fresh"
    npcData._dtSprintSlowUntil = tonumber(npcData._dtSprintSlowUntil) or 0
    npcData._dtMeleeFatigueUntil = tonumber(npcData._dtMeleeFatigueUntil) or 0
    npcData._dtRangedFatigueUntil = tonumber(npcData._dtRangedFatigueUntil) or 0
    npcData._dtStaminaVisibleUntil = tonumber(npcData._dtStaminaVisibleUntil) or 0

    return npcData.staminaCurrent, npcData.staminaMax
end

function Stamina.GetRatio(npcData)
    Stamina.EnsureDefaults(npcData)
    local maxValue = math.max(1, tonumber(npcData and npcData.staminaMax) or 1)
    return clamp((tonumber(npcData and npcData.staminaCurrent) or maxValue) / maxValue, 0, 1)
end

Internal.nowMillis = nowMillis
Internal.clamp = clamp
Internal.getSkillAverage = getSkillAverage
Internal.getSkillNormalized = getSkillNormalized
Internal.getAttackSkillLevel = getAttackSkillLevel
Internal.getAttackSkillNormalized = getAttackSkillNormalized
Internal.getAttackBaseCost = getAttackBaseCost
Internal.getAttackDrainAmount = getAttackDrainAmount
Internal.getElapsedSeconds = getElapsedSeconds
Internal.markVisible = markVisible
Internal.setStaminaState = setStaminaState
Internal.adjustCurrent = adjustCurrent

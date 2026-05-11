-- ==============================================================================
-- DTNPC_Stamina_Passive.lua
-- Passive stamina recovery processing.
-- ==============================================================================

DTNPCStamina = DTNPCStamina or {}
DTNPCStamina.Internal = DTNPCStamina.Internal or {}

local Stamina = DTNPCStamina
local Internal = DTNPCStamina.Internal
local nowMillis = Internal.nowMillis
local getSkillNormalized = Internal.getSkillNormalized
local getElapsedSeconds = Internal.getElapsedSeconds
local markVisible = Internal.markVisible
local setStaminaState = Internal.setStaminaState
local adjustCurrent = Internal.adjustCurrent
local moveExhaustResumeRatio = Internal.MoveExhaustResumeRatio or 0.40

function Stamina.ProcessPassive(zombie, npcData, state)
    if type(npcData) ~= "table" then
        return false
    end
    if tostring(state or npcData.state or "") == "Incapacitated" then
        return false
    end

    Stamina.EnsureDefaults(npcData)

    local currentTime = nowMillis()
    local lastActiveAt = tonumber(npcData._dtLastStaminaActivityAt) or 0
    if currentTime > 0 and lastActiveAt > 0 and (currentTime - lastActiveAt) < 160 then
        return false
    end

    local elapsed = getElapsedSeconds(npcData, "_dtLastPassiveStaminaAt", currentTime, 350)
    if elapsed <= 0 then
        return false
    end

    local normalized = getSkillNormalized(npcData)
    local ratioBefore = Stamina.GetRatio(npcData)
    local recoverRate = 4.3

    if npcData.isMovingState == true then
        recoverRate = 1.1
    elseif tostring(state or "") == "Attack" or tostring(state or "") == "AttackRange" then
        recoverRate = 2.0
    elseif tostring(state or "") == "ProtectMelee" or tostring(state or "") == "ProtectRanged" then
        recoverRate = 2.2
    end

    if Stamina.IsMeleeFatigued(npcData) then
        recoverRate = math.max(recoverRate, 4.8)
    end

    adjustCurrent(npcData, recoverRate * (1 + (normalized * 0.18)) * elapsed)

    local ratioAfter = Stamina.GetRatio(npcData)
    if npcData._dtMoveExhaustedActive == true and ratioAfter >= moveExhaustResumeRatio then
        npcData._dtMoveExhaustedActive = false
    end
    if ratioAfter > ratioBefore and ratioAfter < 0.995 then
        markVisible(npcData, 2600)
    end

    local slowUntil = tonumber(npcData._dtSprintSlowUntil) or 0
    if slowUntil > 0 and currentTime >= slowUntil and ratioAfter > 0.3 then
        npcData._dtSprintSlowUntil = 0
    end

    if slowUntil > currentTime or ratioAfter <= 0.18 then
        setStaminaState(npcData, "recovering")
        npcData._dtSprintMode = "recovering"
    elseif ratioAfter <= 0.4 then
        setStaminaState(npcData, "winded")
        npcData._dtSprintMode = "winded"
    elseif ratioAfter <= 0.68 then
        setStaminaState(npcData, "steady")
        npcData._dtSprintMode = "steady"
    else
        setStaminaState(npcData, "fresh")
        npcData._dtSprintMode = "fresh"
    end

    return true
end

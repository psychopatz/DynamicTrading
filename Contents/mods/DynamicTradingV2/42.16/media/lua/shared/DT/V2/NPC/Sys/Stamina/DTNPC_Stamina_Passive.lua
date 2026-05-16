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


function Stamina.ProcessPassive(zombie, npcData, state)
    if type(npcData) ~= "table" then
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
    local recoverRate = 10.5 -- Increased to compensate for zombie hostility
    local stateName = tostring(state or npcData.state or "")

    local sandbox = SandboxVars and SandboxVars.DynamicTrading or nil
    local multiplier = tonumber(sandbox and sandbox.NPCStaminaRegenMultiplier) or 1.0
    recoverRate = recoverRate * multiplier

    if npcData.isMovingState == true then
        recoverRate = recoverRate * 0.25 -- Roughly 1.1 / 4.3
    elseif stateName == "Attack" or stateName == "AttackRange" then
        recoverRate = recoverRate * 0.46 -- Roughly 2.0 / 4.3
    elseif stateName == "ProtectMelee" or stateName == "ProtectRanged" then
        recoverRate = recoverRate * 0.51 -- Roughly 2.2 / 4.3
    end
    if stateName == "Incapacitated" then
        local profile = Stamina.GetMovementStateProfile and Stamina.GetMovementStateProfile("incap_crawl") or nil
        recoverRate = recoverRate * (tonumber(profile and profile.passiveRecoverMultiplier) or 0.32)
    end

    local meleeFatigued = Stamina.IsMeleeFatigued and Stamina.IsMeleeFatigued(npcData)
    local rangedFatigued = Stamina.IsRangedFatigued and Stamina.IsRangedFatigued(npcData)
    if meleeFatigued or rangedFatigued then
        recoverRate = math.max(recoverRate, 4.8 * multiplier)
    end

    adjustCurrent(npcData, recoverRate * (1 + (normalized * 0.18)) * elapsed)

    local ratioAfter = Stamina.GetRatio(npcData)
    local activeProfileKey = npcData._dtMoveExhaustedProfileKey or npcData._dtLastMoveProfileKey
    if stateName == "Incapacitated" then
        activeProfileKey = "incap_crawl"
    end
    local _, _, resumeThreshold = Internal.resolveMovementThresholds(activeProfileKey)
    if npcData._dtMoveExhaustedActive == true and ratioAfter >= resumeThreshold then
        npcData._dtMoveExhaustedActive = false
        npcData._dtMoveExhaustedProfileKey = nil
    end
    if ratioAfter > ratioBefore and ratioAfter < 0.995 then
        markVisible(npcData, 2600)
    end

    local slowUntil = tonumber(npcData._dtSprintSlowUntil) or 0
    if slowUntil > 0 and currentTime >= slowUntil and ratioAfter > 0.3 then
        npcData._dtSprintSlowUntil = 0
    end

    local lowThreshold = stateName == "Incapacitated" and 0.60 or 0.18
    if slowUntil > currentTime or ratioAfter <= lowThreshold then
        setStaminaState(npcData, "recovering")
        npcData._dtSprintMode = "recovering"
    elseif ratioAfter <= (stateName == "Incapacitated" and 0.75 or 0.4) then
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

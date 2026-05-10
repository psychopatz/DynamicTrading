-- ==============================================================================
-- DTNPC_Stamina.lua
-- Shared stamina runtime for DT NPC movement pacing, melee fatigue, and UI sync.
-- ==============================================================================

DTNPCStamina = DTNPCStamina or {}

require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_Combat"

local Stamina = DTNPCStamina

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

local function getSkillNormalized(npcData)
    return clamp(getSkillAverage(npcData) / 20, 0, 1)
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

local function getCueLine(kind)
    if DynamicTrading and DynamicTrading.FlavorText and DynamicTrading.FlavorText.GetRandom then
        local line = DynamicTrading.FlavorText.GetRandom("CompanionCombat", kind)
        if line and line ~= "" then
            return line
        end
    end

    if kind == "StaminaSlow" then
        local lines = {
            "Slowing down. Need a breath.",
            "Can't hold this pace forever.",
            "Easy. Need to catch my breath.",
        }
        return lines[ZombRand(#lines) + 1]
    end
    if kind == "CatchBreath" then
        local lines = {
            "Give me a second.",
            "Catching my breath.",
            "Need a breather.",
        }
        return lines[ZombRand(#lines) + 1]
    end

    local lines = {
        "Need a second before I swing again.",
        "Arms are burning. Backing off.",
        "Hold them a moment. Re-centering.",
    }
    return lines[ZombRand(#lines) + 1]
end

local function pushCue(zombie, npcData, kind, sentiment, cooldownMs)
    if not zombie or not npcData then
        return false
    end

    local currentTime = nowMillis()
    local safeCooldown = math.max(0, tonumber(cooldownMs) or 5000)
    local cues = type(npcData._dtStaminaCueTimes) == "table" and npcData._dtStaminaCueTimes or {}
    npcData._dtStaminaCueTimes = cues

    local lastTime = tonumber(cues[kind]) or 0
    if currentTime > 0 and lastTime > 0 and (currentTime - lastTime) < safeCooldown then
        return false
    end
    cues[kind] = currentTime

    if DTNPCProtect and DTNPCProtect.PushCombatFlavorNotice then
        local pushed = DTNPCProtect.PushCombatFlavorNotice(zombie, npcData, kind, sentiment or "warning", "Companion", kind)
        if pushed == true then
            return true
        end
    end

    if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        return DTNPCProtect.PushCompanionNotice(zombie, npcData, getCueLine(kind), sentiment or "warning")
    end

    return false
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

local function getMovementDrainRate(profile)
    local mode = tostring(profile and profile.mode or "travel")
    if mode == "flee" then
        return 5.8
    end
    if mode == "pursuit" or mode == "melee_pursuit" then
        return 6.2
    end
    if mode == "follow" then
        return 5.0
    end
    if mode == "travel" or mode == "goto" or mode == "departure" then
        return 4.9
    end
    return 4.6
end

local function getMovementRecoverRate(profile, moving)
    if moving == true then
        if profile and profile.requestedRun == true then
            return 0.6
        end
        return 1.9
    end
    return 3.9
end

local function getBreatherMs(npcData)
    local normalized = getSkillNormalized(npcData)
    return math.floor(1600 + ((1 - normalized) * 900))
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
    npcData._dtStaminaVisibleUntil = tonumber(npcData._dtStaminaVisibleUntil) or 0

    return npcData.staminaCurrent, npcData.staminaMax
end

function Stamina.GetRatio(npcData)
    Stamina.EnsureDefaults(npcData)
    local maxValue = math.max(1, tonumber(npcData and npcData.staminaMax) or 1)
    return clamp((tonumber(npcData and npcData.staminaCurrent) or maxValue) / maxValue, 0, 1)
end

function Stamina.BuildMovementProfile(zombie, npcData, options)
    if type(npcData) ~= "table" then
        return nil
    end

    Stamina.EnsureDefaults(npcData)

    options = type(options) == "table" and options or {}
    local baseSpeed = math.max(0, tonumber(options.speed) or 0)
    local requestedRun = options.desiredRun == true
        or (type(options.anim) == "table" and options.anim.isRunning == true)
        or baseSpeed >= 0.06
    local ratio = Stamina.GetRatio(npcData)
    local currentTime = nowMillis()
    local cooldownUntil = tonumber(npcData._dtSprintSlowUntil) or 0
    local cooldownActive = cooldownUntil > 0 and currentTime > 0 and currentTime < cooldownUntil
    local resolvedSpeed = baseSpeed
    local isRunning = requestedRun
    local state = "fresh"

    if not requestedRun or baseSpeed <= 0.001 then
        resolvedSpeed = baseSpeed
        isRunning = false
        if ratio <= 0.22 or cooldownActive then
            state = "recovering"
        elseif ratio <= 0.52 then
            state = "steady"
        else
            state = "fresh"
        end
    elseif cooldownActive or ratio <= 0.18 then
        resolvedSpeed = math.max(0.039, math.min(baseSpeed * 0.7, 0.052))
        isRunning = false
        state = "recovering"
    elseif ratio <= 0.38 then
        resolvedSpeed = math.max(0.044, baseSpeed * 0.84)
        isRunning = resolvedSpeed > 0.058
        state = "winded"
    elseif ratio <= 0.62 then
        resolvedSpeed = baseSpeed * 0.92
        isRunning = true
        state = "steady"
    else
        resolvedSpeed = baseSpeed
        isRunning = true
        state = "fresh"
    end

    return {
        baseSpeed = baseSpeed,
        speed = resolvedSpeed,
        requestedRun = requestedRun,
        isRunning = isRunning,
        animSpeed = isRunning and 1.2 or 1.0,
        dtWalkType = isRunning and "Run" or "Walk",
        mode = tostring(options.mode or "travel"),
        ratio = ratio,
        state = state,
    }
end

function Stamina.ApplyMovementTick(zombie, npcData, profile, result)
    if type(npcData) ~= "table" or type(profile) ~= "table" then
        return nil
    end

    Stamina.EnsureDefaults(npcData)

    result = type(result) == "table" and result or {}
    local currentTime = nowMillis()
    local elapsed = getElapsedSeconds(npcData, "_dtLastMoveStaminaAt", currentTime, 250)
    npcData._dtLastStaminaActivityAt = currentTime

    local normalized = getSkillNormalized(npcData)
    local currentState = npcData.staminaState
    local maxValue = math.max(1, tonumber(npcData.staminaMax) or 1)
    local currentValue = tonumber(npcData.staminaCurrent) or maxValue

    if result.moved == true and profile.requestedRun == true then
        local drainRate = getMovementDrainRate(profile) * (1 - (normalized * 0.2))
        if elapsed > 0 then
            currentValue = adjustCurrent(npcData, -(drainRate * elapsed))
        end
        markVisible(npcData, 4200)

        if currentValue <= (maxValue * 0.11) then
            local currentSlowUntil = tonumber(npcData._dtSprintSlowUntil) or 0
            if currentSlowUntil <= currentTime then
                npcData._dtSprintSlowUntil = currentTime + getBreatherMs(npcData)
                pushCue(zombie, npcData, "CatchBreath", "warning", 6500)
            end
        elseif currentValue <= (maxValue * 0.34) and currentState ~= "winded" then
            pushCue(zombie, npcData, "StaminaSlow", "warning", 6500)
        end
    else
        local recoverRate = getMovementRecoverRate(profile, result.moved == true) * (1 + (normalized * 0.18))
        if elapsed > 0 then
            adjustCurrent(npcData, recoverRate * elapsed)
        end
        if result.moved == true or (tonumber(npcData.staminaCurrent) or maxValue) < maxValue then
            markVisible(npcData, 3000)
        end
    end

    local ratio = Stamina.GetRatio(npcData)
    local nextState = profile.state
    if ratio > 0.7 and (tonumber(npcData._dtSprintSlowUntil) or 0) <= currentTime then
        nextState = "fresh"
    elseif ratio > 0.42 and (tonumber(npcData._dtSprintSlowUntil) or 0) <= currentTime then
        nextState = "steady"
    elseif (tonumber(npcData._dtSprintSlowUntil) or 0) > currentTime or ratio <= 0.18 then
        nextState = "recovering"
    else
        nextState = "winded"
    end

    setStaminaState(npcData, nextState)
    npcData._dtSprintMode = nextState
    return nextState
end

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
    if untilTime <= 0 then
        return false
    end

    if currentTime < untilTime then
        return true
    end

    if Stamina.GetRatio(npcData) <= 0.22 then
        npcData._dtMeleeFatigueUntil = currentTime + 250
        return true
    end

    npcData._dtMeleeFatigueUntil = 0
    return false
end

function Stamina.GetMeleeRecoveryUntil(npcData)
    if not Stamina.IsMeleeFatigued(npcData) then
        return 0
    end
    return tonumber(npcData._dtMeleeFatigueUntil) or 0
end

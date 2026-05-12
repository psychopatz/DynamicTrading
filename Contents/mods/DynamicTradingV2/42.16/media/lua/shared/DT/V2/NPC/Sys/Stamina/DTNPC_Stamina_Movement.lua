-- ==============================================================================
-- DTNPC_Stamina_Movement.lua
-- Movement stamina profile and drain processing.
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
local pushCue = Internal.pushCue

local function getMovementDrainRate(profile)
    local mode = tostring(profile and profile.mode or "travel")
    if mode == "flee" then
        return 7.5
    end
    if mode == "pursuit" or mode == "melee_pursuit" then
        return 7.0
    end
    if mode == "follow" then
        return 8.5
    end
    if mode == "travel" or mode == "goto" or mode == "departure" then
        return 5.5
    end
    if mode == "incap_crawl" then
        return 5.2
    end
    return 5.2
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
    local exhausted = false
    local mode = tostring(options.mode or "travel")
    local moveExhausted = npcData._dtMoveExhaustedActive == true

    local staminaStateProfile, pauseThreshold, resumeThreshold = Internal.resolveMovementThresholds(options.profileKey)

    if mode ~= "retreat" then
        if moveExhausted and ratio < resumeThreshold then
            exhausted = true
        elseif ratio <= pauseThreshold then
            exhausted = true
            npcData._dtMoveExhaustedActive = true
            npcData._dtMoveExhaustedProfileKey = staminaStateProfile and staminaStateProfile.key or tostring(options.profileKey or mode)
        else
            npcData._dtMoveExhaustedActive = false
            npcData._dtMoveExhaustedProfileKey = nil
        end

        if exhausted then
            resolvedSpeed = 0
            isRunning = false
            state = "recovering"
        elseif mode == "follow" then
            resolvedSpeed = baseSpeed
            isRunning = false
            if ratio <= 0.30 or cooldownActive then
                state = "recovering"
            elseif ratio <= 0.60 then
                state = "steady"
            else
                state = "fresh"
            end
        elseif not requestedRun or baseSpeed <= 0.001 then
            resolvedSpeed = baseSpeed
            isRunning = false
            if ratio <= 0.30 or cooldownActive then
                state = "recovering"
            elseif ratio <= 0.60 then
                state = "steady"
            else
                state = "fresh"
            end
        elseif cooldownActive or ratio <= 0.30 then
            resolvedSpeed = math.max(0.028, math.min(baseSpeed * 0.68, 0.045))
            isRunning = false
            state = "recovering"
        elseif ratio <= 0.55 then
            resolvedSpeed = math.max(0.032, math.min(baseSpeed * 0.82, 0.055))
            isRunning = resolvedSpeed > 0.05
            state = "steady"
        else
            resolvedSpeed = baseSpeed
            isRunning = requestedRun
            state = "fresh"
        end
    elseif not requestedRun or baseSpeed <= 0.001 then
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

    local dtWalkType = isRunning and "Run" or "Walk"
    local animSpeed = isRunning and 1.2 or 1.0
    local walkType = not isRunning and "1" or "1"
    local crawl = false
    if DTNPCMobility and DTNPCMobility.GetLocomotionProfile then
        local locomotionProfile = DTNPCMobility.GetLocomotionProfile(options.profileKey)
        if type(locomotionProfile) == "table" then
            dtWalkType = locomotionProfile.dtWalkType or dtWalkType
            animSpeed = tonumber(locomotionProfile.animSpeed) or animSpeed
            walkType = locomotionProfile.walkType ~= nil and locomotionProfile.walkType or walkType
            crawl = locomotionProfile.crawl == true
        end
    end

    return {
        baseSpeed = baseSpeed,
        speed = resolvedSpeed,
        requestedRun = requestedRun,
        isRunning = isRunning,
        animSpeed = animSpeed,
        dtWalkType = dtWalkType,
        walkType = walkType,
        crawl = crawl,
        mode = mode,
        ratio = ratio,
        state = state,
        exhausted = exhausted,
        profileKey = staminaStateProfile and staminaStateProfile.key or tostring(options.profileKey or "default"),
        drainMultiplier = tonumber(staminaStateProfile and staminaStateProfile.drainMultiplier) or 1.0,
        pauseThreshold = pauseThreshold,
        resumeThreshold = resumeThreshold,
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
    local pauseThreshold = tonumber(profile.pauseThreshold) or tonumber(Internal.MoveExhaustPauseRatio) or 0.25
    local resumeThreshold = tonumber(profile.resumeThreshold) or tonumber(Internal.MoveExhaustResumeRatio) or 0.40
    local drainMultiplier = tonumber(profile.drainMultiplier) or 1.0
    npcData._dtLastMoveProfileKey = profile.profileKey

    if result.moved == true then
        local drainRate = getMovementDrainRate(profile) * drainMultiplier * (1 - (normalized * 0.2))
        if profile.requestedRun == true then
            drainRate = drainRate * 1.15
        end
        if elapsed > 0 then
            currentValue = adjustCurrent(npcData, -(drainRate * elapsed))
        end
        markVisible(npcData, 4200)

        if currentValue <= (maxValue * pauseThreshold) then
            npcData._dtMoveExhaustedActive = true
            npcData._dtMoveExhaustedProfileKey = profile.profileKey
            local currentSlowUntil = tonumber(npcData._dtSprintSlowUntil) or 0
            if currentSlowUntil <= currentTime then
                npcData._dtSprintSlowUntil = currentTime + getBreatherMs(npcData)
                pushCue(zombie, npcData, "CatchBreath", "warning", 6500)
            end
        elseif currentValue <= (maxValue * math.max(0.34, math.min(0.70, resumeThreshold))) then
            if profile.mode == "follow" then
                npcData._dtMoveExhaustedActive = true
                npcData._dtMoveExhaustedProfileKey = profile.profileKey
            end
            pushCue(zombie, npcData, "StaminaSlow", "warning", 6500)
        elseif profile.mode == "follow" and currentValue <= (maxValue * (tonumber(Internal.MoveExhaustPauseRatio) or 0.25)) then
            npcData._dtMoveExhaustedActive = true
            pushCue(zombie, npcData, "CatchBreath", "warning", 6500)
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
    if npcData._dtMoveExhaustedActive == true and ratio >= resumeThreshold then
        npcData._dtMoveExhaustedActive = false
        npcData._dtMoveExhaustedProfileKey = nil
    end
    local nextState = profile.state
    if ratio >= math.min(0.90, resumeThreshold + 0.22) and (tonumber(npcData._dtSprintSlowUntil) or 0) <= currentTime then
        nextState = "fresh"
    elseif ratio >= resumeThreshold and (tonumber(npcData._dtSprintSlowUntil) or 0) <= currentTime then
        nextState = "steady"
    elseif (tonumber(npcData._dtSprintSlowUntil) or 0) > currentTime or ratio <= pauseThreshold then
        nextState = "recovering"
    else
        nextState = "winded"
    end

    setStaminaState(npcData, nextState)
    npcData._dtSprintMode = nextState
    return nextState
end

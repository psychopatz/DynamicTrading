DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal

function Internal.getReserveDaysLeft(storedAmount, dailyNeed)
    local perDay = tonumber(dailyNeed) or 0
    if perDay <= 0 then
        return nil
    end

    local days = (tonumber(storedAmount) or 0) / perDay
    return math.max(0, days)
end

function Internal.getReserveHoursLeft(storedAmount, hourlyNeed)
    local perHour = tonumber(hourlyNeed) or 0
    if perHour <= 0 then
        return nil
    end

    return math.max(0, (tonumber(storedAmount) or 0) / perHour)
end

function Internal.getNextRefillHours(caloriesHoursLeft, hydrationHoursLeft)
    if caloriesHoursLeft and hydrationHoursLeft then
        return math.min(caloriesHoursLeft, hydrationHoursLeft)
    end
    return caloriesHoursLeft or hydrationHoursLeft
end

function Internal.getReserveBarData(storedAmount, dailyNeed)
    local stored = math.max(0, tonumber(storedAmount) or 0)
    local usage = math.max(0, tonumber(dailyNeed) or 0)
    if usage <= 0 then
        return {
            stored = stored,
            usage = usage,
            fillRatio = 0,
            overflow = 0,
            daysLeft = nil
        }
    end

    local rawRatio = stored / usage
    return {
        stored = stored,
        usage = usage,
        fillRatio = math.max(0, math.min(1, rawRatio)),
        overflow = math.max(0, stored - usage),
        daysLeft = math.max(0, rawRatio)
    }
end

function Internal.getNutritionBarData(unitLabel, currentBufferAmount, carryoverAmount, provisionReserveAmount, dailyNeed)
    local unitName = tostring(unitLabel or "Nutrition")
    local currentBuffer = math.max(0, tonumber(currentBufferAmount) or 0)
    local carryover = math.max(0, tonumber(carryoverAmount) or 0)
    local provisionReserve = math.max(0, tonumber(provisionReserveAmount) or 0)
    local data = Internal.getReserveBarData(currentBuffer, dailyNeed)
    data.carryover = carryover
    data.provisionReserve = provisionReserve
    data.currentBuffer = currentBuffer
    data.daysLeft = Internal.getReserveDaysLeft(currentBuffer + carryover + provisionReserve, dailyNeed)
    data.summaryText = unitName .. " Reserve " .. Internal.formatReserveValue(provisionReserve)
        .. " | Carryover " .. Internal.formatReserveValue(carryover)
    return data
end

function Internal.getHealthBarData(currentHp, maxHp)
    local safeMax = math.max(1, tonumber(maxHp) or 100)
    local safeCurrent = math.max(0, math.min(safeMax, tonumber(currentHp) or safeMax))
    return {
        stored = safeCurrent,
        usage = safeMax,
        fillRatio = safeCurrent / safeMax,
        overflow = 0,
        daysLeft = nil,
        captionText = safeCurrent <= 0 and "dead" or "current hp",
        summaryText = Internal.formatReserveValue(safeCurrent) .. " / " .. Internal.formatReserveValue(safeMax)
    }
end

function Internal.getScavengeSearchProgressData(worker, profile)
    local config = Internal.Config or {}
    local normalizedJob = config.NormalizeJobType and config.NormalizeJobType(worker and worker.jobType) or tostring(worker and worker.jobType or "")
    if normalizedJob ~= ((config.JobTypes or {}).Scavenge) then
        return nil
    end

    local cycleHours = math.max(
        0.01,
        tonumber(worker and worker.workCycleHours)
            or tonumber(config.GetEffectiveCycleHours and config.GetEffectiveCycleHours(worker, profile))
            or tonumber(profile and profile.cycleHours)
            or 16
    )
    local progressHours = math.max(0, tonumber(worker and worker.workProgress) or 0)
    if progressHours > cycleHours then
        progressHours = progressHours % cycleHours
    end

    local baseSpeed = math.max(
        0.01,
        tonumber(worker and worker.baseWorkSpeedMultiplier)
            or tonumber(config.GetBaseWorkSpeedMultiplier and config.GetBaseWorkSpeedMultiplier(worker, profile))
            or 1
    )
    local archetypeSpeed = math.max(0.01, tonumber(config.GetJobSpeedMultiplier and config.GetJobSpeedMultiplier(worker and worker.archetypeID, worker and worker.jobType) or 1) or 1)
    local equipmentSpeed = math.max(0.01, tonumber(worker and worker.scavengeSearchSpeedMultiplier) or 1)
    local effectiveSpeed = baseSpeed * archetypeSpeed * equipmentSpeed
    local remainingProgressHours = math.max(0, cycleHours - progressHours)
    local remainingWorldHours = effectiveSpeed > 0 and (remainingProgressHours / effectiveSpeed) or nil
    local presenceState = tostring(worker and worker.presenceState or "")
    local scavengeState = tostring((config.PresenceStates or {}).Scavenging or "Scavenging")

    local captionText = "Loot roll when full"
    if presenceState == scavengeState and worker and worker.jobEnabled then
        captionText = Internal.formatDurationHours(remainingWorldHours) .. " to next loot roll"
    elseif worker and worker.jobEnabled then
        captionText = "Progress pauses while travelling"
    end

    return {
        stored = progressHours,
        usage = cycleHours,
        fillRatio = math.max(0, math.min(1, progressHours / cycleHours)),
        overflow = 0,
        daysLeft = nil,
        captionText = captionText,
        progressHours = progressHours,
        cycleHours = cycleHours,
        remainingWorldHours = remainingWorldHours,
        baseSpeedMultiplier = baseSpeed,
        archetypeSpeedMultiplier = archetypeSpeed,
        equipmentSpeedMultiplier = equipmentSpeed,
        effectiveSpeedMultiplier = effectiveSpeed,
        summaryText = Internal.formatDecimal(progressHours, 1)
            .. " / "
            .. Internal.formatDecimal(cycleHours, 1)
            .. "h | Speed x"
            .. Internal.formatDecimal(effectiveSpeed, 2)
    }
end

DT_Labour = DT_Labour or {}
DT_Labour.Config = DT_Labour.Config or {}

local Config = DT_Labour.Config

function Config.GetCurrentWorldHours()
    local gt = getGameTime()
    if not gt then return 0 end
    return tonumber(gt:getWorldAgeHours()) or 0
end

function Config.GetCurrentHour()
    return math.floor(Config.GetCurrentWorldHours())
end

function Config.GetSandboxTable()
    return SandboxVars and SandboxVars.DynamicTrading or {}
end

function Config.GetSandboxNumber(key, fallback)
    local sandbox = Config.GetSandboxTable()
    local value = tonumber(sandbox and sandbox[key])
    if value == nil then
        return fallback
    end
    return value
end

function Config.GetLabourDailyCaloriesUse()
    return math.max(0, Config.GetSandboxNumber("LabourDailyCaloriesUse", Config.DEFAULT_LABOUR_DAILY_CALORIES_USE) or Config.DEFAULT_LABOUR_DAILY_CALORIES_USE)
end

function Config.GetLabourDailyHydrationUse()
    return math.max(0, Config.GetSandboxNumber("LabourDailyHydrationUse", Config.DEFAULT_LABOUR_DAILY_HYDRATION_USE) or Config.DEFAULT_LABOUR_DAILY_HYDRATION_USE)
end

function Config.GetDefaultWorkerCarryWeight()
    return math.max(0, Config.GetSandboxNumber("LabourBaseCarryWeight", Config.DEFAULT_WORKER_CARRY_WEIGHT) or Config.DEFAULT_WORKER_CARRY_WEIGHT)
end

function Config.GetScavengeTravelHours()
    return math.max(0, Config.GetSandboxNumber("NPCTradingWalkHours", Config.DEFAULT_SCAVENGE_TRAVEL_HOURS) or Config.DEFAULT_SCAVENGE_TRAVEL_HOURS)
end

function Config.GetEffectiveDailyCaloriesNeed(worker, profile)
    return Config.GetLabourDailyCaloriesUse()
end

function Config.GetEffectiveDailyHydrationNeed(worker, profile)
    return Config.GetLabourDailyHydrationUse()
end

function Config.GetEffectiveHourlyCaloriesNeed(worker, profile)
    local hoursPerDay = tonumber(Config.HOURS_PER_DAY) or 24
    if hoursPerDay <= 0 then
        return 0
    end
    return Config.GetEffectiveDailyCaloriesNeed(worker, profile) / hoursPerDay
end

function Config.GetEffectiveHourlyHydrationNeed(worker, profile)
    local hoursPerDay = tonumber(Config.HOURS_PER_DAY) or 24
    if hoursPerDay <= 0 then
        return 0
    end
    return Config.GetEffectiveDailyHydrationNeed(worker, profile) / hoursPerDay
end

return Config

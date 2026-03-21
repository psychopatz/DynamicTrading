DT_Labour = DT_Labour or {}
DT_Labour.Registry = DT_Labour.Registry or {}
DT_Labour.Registry.Internal = DT_Labour.Registry.Internal or {}

local Config = DT_Labour.Config
local Nutrition = DT_Labour.Nutrition
local Registry = DT_Labour.Registry
local Internal = Registry.Internal

function Internal.EnsureArray(value)
    return type(value) == "table" and value or {}
end

function Internal.CopyShallow(source)
    local copy = {}
    for key, value in pairs(source or {}) do
        copy[key] = value
    end
    return copy
end

function Internal.GetDisplayNameForFullType(fullType)
    if not fullType or not getScriptManager then
        return tostring(fullType or "Unknown Item")
    end

    local item = getScriptManager():getItem(fullType)
    if item and item.getDisplayName then
        return item:getDisplayName()
    end

    return tostring(fullType or "Unknown Item")
end

function Internal.EnsureActivityLog(worker)
    if not worker then
        return {}
    end

    worker.activityLog = Internal.EnsureArray(worker.activityLog)
    local limit = math.max(1, tonumber(Config.WORKER_ACTIVITY_LOG_LIMIT) or 40)
    while #worker.activityLog > limit do
        table.remove(worker.activityLog, 1)
    end
    return worker.activityLog
end

function Internal.AppendActivityLog(worker, message, worldHour, category)
    if not worker or not message or tostring(message) == "" then
        return
    end

    local activityLog = Internal.EnsureActivityLog(worker)
    activityLog[#activityLog + 1] = {
        hour = tonumber(worldHour) or ((Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour()),
        text = tostring(message),
        category = tostring(category or "general")
    }

    local limit = math.max(1, tonumber(Config.WORKER_ACTIVITY_LOG_LIMIT) or 40)
    while #activityLog > limit do
        table.remove(activityLog, 1)
    end
end

function Internal.BuildStarterNutritionLedger(template)
    local existing = Internal.CopyShallow(template and template.nutritionLedger or nil)
    if #existing > 0 then
        return existing
    end

    return existing
end

function Internal.GetStarterReserveTotals(template)
    local existing = Internal.CopyShallow(template and template.nutritionLedger or nil)
    local templateCalories = tonumber(template and template.caloriesCached) or 0
    local templateHydration = tonumber(template and template.hydrationCached) or 0
    if #existing > 0 then
        return templateCalories, templateHydration
    end
    if templateCalories > 0 or templateHydration > 0 then
        return templateCalories, templateHydration
    end

    local starterCalories = Config.RandomRangeInclusive(
        Config.RECRUIT_START_CALORIES_MIN,
        Config.RECRUIT_START_CALORIES_MAX
    )
    local starterHydration = Config.RandomRangeInclusive(
        Config.RECRUIT_START_HYDRATION_MIN,
        Config.RECRUIT_START_HYDRATION_MAX
    )

    return starterCalories, starterHydration
end

return Internal

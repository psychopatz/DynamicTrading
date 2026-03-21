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

function Internal.BuildStarterNutritionLedger(template)
    local existing = Internal.CopyShallow(template and template.nutritionLedger or nil)
    if #existing > 0 then
        return existing
    end

    local templateCalories = tonumber(template and template.caloriesCached) or 0
    local templateHydration = tonumber(template and template.hydrationCached) or 0
    if templateCalories > 0 or templateHydration > 0 then
        existing[#existing + 1] = Nutrition.BuildStarterReserveEntry(templateCalories, templateHydration)
        return existing
    end

    local starterCalories = Config.RandomRangeInclusive(
        Config.RECRUIT_START_CALORIES_MIN,
        Config.RECRUIT_START_CALORIES_MAX
    )
    local starterHydration = Config.RandomRangeInclusive(
        Config.RECRUIT_START_HYDRATION_MIN,
        Config.RECRUIT_START_HYDRATION_MAX
    )

    existing[#existing + 1] = Nutrition.BuildStarterReserveEntry(starterCalories, starterHydration)
    return existing
end

return Internal

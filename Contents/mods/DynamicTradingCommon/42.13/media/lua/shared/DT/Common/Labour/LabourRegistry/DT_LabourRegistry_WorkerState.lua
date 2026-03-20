DT_Labour = DT_Labour or {}
DT_Labour.Registry = DT_Labour.Registry or {}
DT_Labour.Registry.Internal = DT_Labour.Registry.Internal or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Internal = Registry.Internal

function Registry.RecalculateWorker(worker)
    if not worker then return end

    worker.nutritionLedger = Internal.EnsureArray(worker.nutritionLedger)
    worker.toolLedger = Internal.EnsureArray(worker.toolLedger)
    worker.outputLedger = Internal.EnsureArray(worker.outputLedger)
    worker.moneyStored = math.max(0, math.floor(tonumber(worker.moneyStored) or 0))
    worker.jobType = Config.NormalizeJobType(worker.jobType or worker.profession)
    worker.archetypeID = Config.NormalizeArchetypeID(worker.archetypeID or worker.profession)
    worker.profession = worker.profession or worker.jobType
    if (tonumber(worker.dailyHydrationNeed) or 0) > 0 and (tonumber(worker.dailyHydrationNeed) or 0) < 25 then
        worker.dailyHydrationNeed = (tonumber(worker.dailyHydrationNeed) or 0) * (Config.HYDRATION_POINTS_PER_THIRST or 1000)
    end

    local calories = 0
    local hydration = 0
    local outputCount = 0
    local tags = {}

    for i = #worker.nutritionLedger, 1, -1 do
        local entry = worker.nutritionLedger[i]
        local entryCalories = tonumber(entry and entry.caloriesRemaining) or 0
        local entryHydration = tonumber(entry and entry.hydrationRemaining) or 0
        if entryHydration > 0 and entryHydration < 25 then
            entryHydration = entryHydration * (Config.HYDRATION_POINTS_PER_THIRST or 1000)
            entry.hydrationRemaining = entryHydration
        end

        if entryCalories <= 0 and entryHydration <= 0 then
            table.remove(worker.nutritionLedger, i)
        else
            calories = calories + entryCalories
            hydration = hydration + entryHydration
        end
    end

    for i = #worker.toolLedger, 1, -1 do
        local entry = worker.toolLedger[i]
        if not entry or not entry.fullType then
            table.remove(worker.toolLedger, i)
        else
            for _, tag in ipairs(entry.tags or {}) do
                tags[tag] = true
            end
        end
    end

    for _, entry in ipairs(worker.outputLedger) do
        outputCount = outputCount + (tonumber(entry.qty) or 0)
    end

    worker.caloriesCached = calories
    worker.hydrationCached = hydration
    worker.outputCount = outputCount
    worker.assignedToolTags = tags
end

function Registry.WorkerHasRequiredTools(worker)
    local profile = Config.GetJobProfile(worker and worker.jobType)
    Registry.RecalculateWorker(worker)
    local tagMap = worker and worker.assignedToolTags or {}

    for _, requiredTag in ipairs(profile.requiredToolTags or {}) do
        local matched = false
        for itemTag, enabled in pairs(tagMap or {}) do
            if enabled and Config.TagMatches(itemTag, requiredTag) then
                matched = true
                break
            end
        end
        if not matched then
            return false
        end
    end

    return true
end

return Registry

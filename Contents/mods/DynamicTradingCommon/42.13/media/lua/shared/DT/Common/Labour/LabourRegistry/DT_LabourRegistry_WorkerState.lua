DT_Labour = DT_Labour or {}
DT_Labour.Registry = DT_Labour.Registry or {}
DT_Labour.Registry.Internal = DT_Labour.Registry.Internal or {}

local Config = DT_Labour.Config
local Registry = DT_Labour.Registry
local Internal = Registry.Internal

local function clampAmount(value)
    return math.max(0, tonumber(value) or 0)
end

local function getReserveCaps(worker)
    local profile = Config.GetJobProfile(worker and worker.jobType)
    local dailyCaloriesNeed = Config.GetEffectiveDailyCaloriesNeed and Config.GetEffectiveDailyCaloriesNeed(worker, profile)
        or tonumber(worker and worker.dailyCaloriesNeed)
        or tonumber(profile and profile.dailyCaloriesNeed)
        or 0
    local dailyHydrationNeed = Config.GetEffectiveDailyHydrationNeed and Config.GetEffectiveDailyHydrationNeed(worker, profile)
        or tonumber(worker and worker.dailyHydrationNeed)
        or tonumber(profile and profile.dailyHydrationNeed)
        or 0
    return clampAmount(dailyCaloriesNeed), clampAmount(dailyHydrationNeed)
end

local function normalizeLedgerEntry(entry)
    if DT_Labour and DT_Labour.Nutrition and DT_Labour.Nutrition.SanitizeLedgerEntry then
        return DT_Labour.Nutrition.SanitizeLedgerEntry(entry)
    end

    if not entry then
        return 0, 0
    end
    local calories = clampAmount(entry.caloriesRemaining)
    local hydration = clampAmount(entry.hydrationRemaining)
    if hydration > 0 and hydration < 25 then
        hydration = hydration * (Config.HYDRATION_POINTS_PER_THIRST or 1000)
    end

    entry.caloriesRemaining = calories
    entry.hydrationRemaining = hydration
    return calories, hydration
end

local function getLedgerTotals(worker)
    local calories = 0
    local hydration = 0
    for _, entry in ipairs(worker and worker.nutritionLedger or {}) do
        local entryCalories, entryHydration = normalizeLedgerEntry(entry)
        calories = calories + entryCalories
        hydration = hydration + entryHydration
    end
    return calories, hydration
end

local function migrateLegacyNutritionModel(worker)
    local currentVersion = tonumber(worker and worker.nutritionModelVersion) or 0
    local targetVersion = tonumber(Config.NUTRITION_MODEL_VERSION) or 3
    if not worker or currentVersion >= targetVersion then
        return
    end

    worker.nutritionLedger = Internal.EnsureArray(worker.nutritionLedger)
    worker.caloriesOverflow = clampAmount(worker.caloriesOverflow)
    worker.hydrationOverflow = clampAmount(worker.hydrationOverflow)

    local onBodyCalories = clampAmount(worker.caloriesCached) + worker.caloriesOverflow
    local onBodyHydration = clampAmount(worker.hydrationCached) + worker.hydrationOverflow
    for index = #worker.nutritionLedger, 1, -1 do
        local entry = worker.nutritionLedger[index]
        if DT_Labour and DT_Labour.Nutrition and DT_Labour.Nutrition.IsSyntheticReserveEntry and DT_Labour.Nutrition.IsSyntheticReserveEntry(entry) then
            local calories, hydration = normalizeLedgerEntry(entry)
            onBodyCalories = onBodyCalories + calories
            onBodyHydration = onBodyHydration + hydration
            table.remove(worker.nutritionLedger, index)
        end
    end

    local caloriesCap, hydrationCap = getReserveCaps(worker)
    if DT_Labour and DT_Labour.Nutrition and DT_Labour.Nutrition.SetOnBodyTotals then
        DT_Labour.Nutrition.SetOnBodyTotals(worker, onBodyCalories, onBodyHydration, caloriesCap, hydrationCap)
    else
        worker.caloriesCached = onBodyCalories
        worker.hydrationCached = onBodyHydration
    end
    worker.nutritionModelVersion = targetVersion
end

function Registry.RecalculateWorker(worker)
    if not worker then return end

    worker.nutritionLedger = Internal.EnsureArray(worker.nutritionLedger)
    worker.toolLedger = Internal.EnsureArray(worker.toolLedger)
    worker.outputLedger = Internal.EnsureArray(worker.outputLedger)
    Internal.EnsureActivityLog(worker)
    worker.moneyStored = math.max(0, math.floor(tonumber(worker.moneyStored) or 0))
    worker.jobType = Config.NormalizeJobType(worker.jobType or worker.profession)
    worker.archetypeID = Config.NormalizeArchetypeID(worker.archetypeID or worker.profession)
    worker.profession = worker.profession or worker.jobType
    if (tonumber(worker.dailyHydrationNeed) or 0) > 0 and (tonumber(worker.dailyHydrationNeed) or 0) < 25 then
        worker.dailyHydrationNeed = (tonumber(worker.dailyHydrationNeed) or 0) * (Config.HYDRATION_POINTS_PER_THIRST or 1000)
    end
    worker.maxHp = math.max(1, tonumber(worker.maxHp) or tonumber(worker.healthMax) or Config.DEFAULT_WORKER_MAX_HP or 100)
    worker.hp = math.max(0, math.min(worker.maxHp, tonumber(worker.hp) or tonumber(worker.health) or worker.maxHp))
    worker.lastNutritionCheckpoint = math.max(
        0,
        math.floor(tonumber(worker.lastNutritionCheckpoint) or Config.GetMealCheckpointCountAtHour(worker.lastSimHour or 0))
    )
    migrateLegacyNutritionModel(worker)
    worker.caloriesCached = clampAmount(worker.caloriesCached)
    worker.hydrationCached = clampAmount(worker.hydrationCached)
    worker.caloriesOverflow = clampAmount(worker.caloriesOverflow)
    worker.hydrationOverflow = clampAmount(worker.hydrationOverflow)
    local caloriesCap, hydrationCap = getReserveCaps(worker)
    if DT_Labour and DT_Labour.Nutrition and DT_Labour.Nutrition.NormalizeOnBodyReserve then
        DT_Labour.Nutrition.NormalizeOnBodyReserve(worker, caloriesCap, hydrationCap)
    end

    local storedCalories = 0
    local storedHydration = 0
    local outputCount = 0
    local tags = {}

    for i = #worker.nutritionLedger, 1, -1 do
        local entry = worker.nutritionLedger[i]
        local entryCalories, entryHydration = normalizeLedgerEntry(entry)

        if entryCalories <= 0 and entryHydration <= 0 then
            table.remove(worker.nutritionLedger, i)
        else
            storedCalories = storedCalories + entryCalories
            storedHydration = storedHydration + entryHydration
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

    worker.storedCalories = storedCalories
    worker.storedHydration = storedHydration
    worker.currentCaloriesBuffer = clampAmount(worker.caloriesCached)
    worker.currentHydrationBuffer = clampAmount(worker.hydrationCached)
    worker.carryoverCalories = clampAmount(worker.caloriesOverflow)
    worker.carryoverHydration = clampAmount(worker.hydrationOverflow)
    worker.bufferCaloriesTotal = worker.currentCaloriesBuffer + worker.carryoverCalories
    worker.bufferHydrationTotal = worker.currentHydrationBuffer + worker.carryoverHydration
    worker.provisionCaloriesReserve = storedCalories
    worker.provisionHydrationReserve = storedHydration
    worker.combinedCaloriesTotal = worker.bufferCaloriesTotal + storedCalories
    worker.combinedHydrationTotal = worker.bufferHydrationTotal + storedHydration

    worker.caloriesOverflow = worker.carryoverCalories
    worker.hydrationOverflow = worker.carryoverHydration
    worker.reserveCaloriesTotal = worker.bufferCaloriesTotal
    worker.reserveHydrationTotal = worker.bufferHydrationTotal
    worker.totalCaloriesAvailable = worker.combinedCaloriesTotal
    worker.totalHydrationAvailable = worker.combinedHydrationTotal
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

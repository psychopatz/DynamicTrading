DT_Labour = DT_Labour or {}
DT_Labour.Nutrition = DT_Labour.Nutrition or {}
DT_Labour.Nutrition.Internal = DT_Labour.Nutrition.Internal or {}

local Config = DT_Labour.Config
local Nutrition = DT_Labour.Nutrition
local Internal = Nutrition.Internal

function Internal.FindNextConsumableEntry(worker)
    if not worker then
        return nil, nil
    end

    Internal.PruneEmptyEntries(worker)
    worker.nutritionLedger = worker.nutritionLedger or {}
    return (#worker.nutritionLedger > 0) and 1 or nil, worker.nutritionLedger[1]
end

function Nutrition.ConsumeProvisionItem(worker, ledgerIndex, caloriesCap, hydrationCap)
    if not worker then
        return 0, 0, nil
    end

    local index = tonumber(ledgerIndex) or nil
    local entry = nil

    if index then
        entry = worker.nutritionLedger and worker.nutritionLedger[index] or nil
    else
        index, entry = Internal.FindNextConsumableEntry(worker)
    end

    if not index or not entry then
        return 0, 0, nil
    end

    local calories, hydration, changed = Internal.NormalizeLedgerEntry(entry)
    table.remove(worker.nutritionLedger, index)
    Nutrition.AddReserveAmounts(worker, calories, hydration, caloriesCap, hydrationCap)
    if not changed then
        local registryInternal = DT_Labour and DT_Labour.Registry and DT_Labour.Registry.Internal or nil
        if not (registryInternal and registryInternal.ApplyNutritionCacheDelta and registryInternal.ApplyNutritionCacheDelta(worker, -calories, -hydration)) then
            Internal.MarkNutritionDirty(worker)
        end
    else
        Internal.MarkNutritionDirty(worker)
    end
    local displayName = tostring(entry.displayName or entry.fullType or "Provision")
    local actionVerb = (hydration > 0 and calories <= 0) and "Drank" or "Ate"
    Internal.AppendWorkerLog(
        worker,
        actionVerb .. " " .. displayName .. " (" .. string.format("%.0f", calories) .. " cal, " .. string.format("%.0f", hydration) .. " hyd).",
        (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour(),
        "nutrition"
    )
    Internal.PruneEmptyEntries(worker)
    return calories, hydration, entry
end

function Nutrition.RefillReserveToTargets(worker, caloriesTarget, hydrationTarget, caloriesCap, hydrationCap)
    if not worker then
        return 0, 0
    end

    local caloriesMoved = 0
    local hydrationMoved = 0
    local targetCalories = Internal.ClampAmount(caloriesTarget)
    local targetHydration = Internal.ClampAmount(hydrationTarget)
    local consumedCount = 0

    while consumedCount < 512 do
        local totalCalories, totalHydration = Internal.GetOnBodyTotals(worker)
        if totalCalories >= targetCalories and totalHydration >= targetHydration then
            break
        end

        local addedCalories, addedHydration = Nutrition.ConsumeProvisionItem(worker, nil, caloriesCap, hydrationCap)
        if addedCalories <= 0 and addedHydration <= 0 then
            break
        end

        caloriesMoved = caloriesMoved + addedCalories
        hydrationMoved = hydrationMoved + addedHydration
        consumedCount = consumedCount + 1
    end

    return caloriesMoved, hydrationMoved
end

return Nutrition

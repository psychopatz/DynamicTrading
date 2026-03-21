require "DT/Common/Labour/DT_Labour_Config"
require "DT/Common/Trading/DT_Economy_Common"

DT_Labour = DT_Labour or {}
DT_Labour.Nutrition = DT_Labour.Nutrition or {}

local Config = DT_Labour.Config
local Nutrition = DT_Labour.Nutrition
local ExpectedStaticNutritionCache = {}

local function appendWorkerLog(worker, message, worldHour, category)
    local registryInternal = DT_Labour and DT_Labour.Registry and DT_Labour.Registry.Internal or nil
    if registryInternal and registryInternal.AppendActivityLog then
        registryInternal.AppendActivityLog(worker, message, worldHour, category)
    end
end

local function clampAmount(value)
    return math.max(0, tonumber(value) or 0)
end

local function getScriptItem(invItem)
    if not invItem or not invItem.getFullType then return nil end
    return getScriptManager():getItem(invItem:getFullType())
end

local function getScriptItemByFullType(fullType)
    if not fullType or not getScriptManager then
        return nil
    end
    return getScriptManager():getItem(fullType)
end

local function createItemByFullType(fullType)
    if not fullType or not InventoryItemFactory or not InventoryItemFactory.CreateItem then
        return nil
    end
    return InventoryItemFactory.CreateItem(fullType)
end

local function readNumericValue(source, getterName)
    if not source then
        return 0
    end

    local getter = source[getterName]
    if not getter then
        return 0
    end

    return tonumber(getter(source)) or 0
end

local function containsText(haystack, needle)
    if not haystack or not needle then
        return false
    end
    return string.find(string.lower(tostring(haystack)), string.lower(tostring(needle)), 1, true) ~= nil
end

local function isWaterHydrationSource(invItem, scriptItem)
    if invItem and invItem.isWaterSource and invItem:isWaterSource() then
        return true
    end

    local fullType = invItem and invItem.getFullType and invItem:getFullType() or nil
    local displayName = invItem and invItem.getDisplayName and invItem:getDisplayName() or nil
    local scriptName = scriptItem and scriptItem.getDisplayName and scriptItem:getDisplayName() or nil

    if containsText(fullType, "water") or containsText(displayName, "water") or containsText(scriptName, "water") then
        return true
    end

    return false
end

local function normalizeHydrationPoints(rawValue)
    local normalized = math.abs(Config.NormalizeUnitValue(rawValue))
    if normalized <= 0 then
        return 0
    end

    return normalized * (Config.HYDRATION_POINTS_PER_THIRST or 1000)
end

local function normalizeCaloriesFromHunger(rawValue)
    local normalized = math.abs(Config.NormalizeUnitValue(rawValue))
    if normalized <= 0 then
        return 0
    end

    return normalized * 1800
end

local function chooseStaticNutrition(instanceValue, scriptValue)
    local instanceAmount = clampAmount(instanceValue)
    local scriptAmount = clampAmount(scriptValue)

    if scriptAmount <= 0 then
        return instanceAmount
    end

    if instanceAmount <= 0 then
        return scriptAmount
    end

    if instanceAmount <= (scriptAmount * 1.5) then
        return instanceAmount
    end

    return scriptAmount
end

local function getExpectedStaticNutritionForFullType(fullType)
    if not fullType then
        return 0, 0, nil
    end

    local cached = ExpectedStaticNutritionCache[fullType]
    if cached then
        return cached.calories or 0, cached.hydration or 0, cached.scriptItem
    end

    local scriptItem = getScriptItemByFullType(fullType)
    if not scriptItem then
        return 0, 0, nil
    end

    local createdItem = createItemByFullType(fullType)
    local instanceCalories = clampAmount(readNumericValue(createdItem, "getCalories"))
    local scriptCalories = clampAmount(readNumericValue(scriptItem, "getCalories"))
    local instanceHungerCalories = normalizeCaloriesFromHunger(readNumericValue(createdItem, "getHungerChange"))
    local scriptHungerCalories = 0
    if DynamicTrading and DynamicTrading.Economy and DynamicTrading.Economy.Common then
        scriptHungerCalories = normalizeCaloriesFromHunger(DynamicTrading.Economy.Common.GetNormalizedHunger(scriptItem))
    end
    local expectedCalories = chooseStaticNutrition(instanceCalories, scriptCalories)
    if expectedCalories <= 0 then
        expectedCalories = chooseStaticNutrition(instanceHungerCalories, scriptHungerCalories)
    end

    local instanceHydration = normalizeHydrationPoints(readNumericValue(createdItem, "getThirstChange"))
    local scriptHydration = normalizeHydrationPoints(readNumericValue(scriptItem, "getThirstChange"))
    local expectedHydration = chooseStaticNutrition(instanceHydration, scriptHydration)

    ExpectedStaticNutritionCache[fullType] = {
        calories = expectedCalories,
        hydration = expectedHydration,
        scriptItem = scriptItem,
    }

    return expectedCalories, expectedHydration, scriptItem
end

function Nutrition.GetItemNutrition(invItem)
    if not invItem then
        return 0, 0
    end

    local scriptItem = getScriptItem(invItem)
    local instanceCalories = clampAmount(readNumericValue(invItem, "getCalories"))
    local scriptCalories = clampAmount(readNumericValue(scriptItem, "getCalories"))
    local instanceHungerCalories = normalizeCaloriesFromHunger(readNumericValue(invItem, "getHungerChange"))
    local scriptHungerCalories = 0
    if scriptItem and DynamicTrading and DynamicTrading.Economy and DynamicTrading.Economy.Common then
        scriptHungerCalories = normalizeCaloriesFromHunger(DynamicTrading.Economy.Common.GetNormalizedHunger(scriptItem))
    end

    local calories = chooseStaticNutrition(instanceCalories, scriptCalories)
    if calories <= 0 then
        calories = chooseStaticNutrition(instanceHungerCalories, scriptHungerCalories)
    end

    local dynamicFluidItem = isWaterHydrationSource(invItem, scriptItem)
        and invItem.getFluidContainer
        and invItem:getFluidContainer()
    local instanceHydration = normalizeHydrationPoints(readNumericValue(invItem, "getThirstChange"))
    local scriptHydration = normalizeHydrationPoints(readNumericValue(scriptItem, "getThirstChange"))
    local hydration = 0

    if dynamicFluidItem then
        local fluidContainer = invItem:getFluidContainer()
        if fluidContainer and fluidContainer.getAmount then
            local amount = tonumber(fluidContainer:getAmount()) or 0
            if amount > 0 then
                hydration = amount > 10 and amount or (amount * 100)
            end
        end
    end

    if hydration <= 0 then
        hydration = chooseStaticNutrition(instanceHydration, scriptHydration)
    end

    return calories, hydration
end

function Nutrition.BuildEntryFromItem(invItem)
    if not invItem then return nil, "Missing item." end

    local calories, hydration = Nutrition.GetItemNutrition(invItem)
    if calories <= 0 and hydration <= 0 then
        return nil, "Item does not provide calories or hydration."
    end

    return {
        fullType = invItem:getFullType(),
        displayName = invItem.getDisplayName and invItem:getDisplayName() or invItem:getFullType(),
        itemID = invItem.getID and invItem:getID() or nil,
        caloriesRemaining = calories,
        hydrationRemaining = hydration
    }
end

function Nutrition.BuildStarterReserveEntry(calories, hydration)
    return {
        fullType = "DT.LabourStarterReserve",
        displayName = "Starter Reserve",
        caloriesRemaining = math.max(0, tonumber(calories) or 0),
        hydrationRemaining = math.max(0, tonumber(hydration) or 0)
    }
end

function Nutrition.IsSyntheticReserveEntry(entry)
    local fullType = entry and tostring(entry.fullType or "") or ""
    return string.find(fullType, "^DT%.Labour") ~= nil
end

function Nutrition.SanitizeLedgerEntry(entry)
    if not entry then
        return 0, 0
    end

    local calories = clampAmount(entry.caloriesRemaining)
    local hydration = clampAmount(entry.hydrationRemaining)
    if hydration > 0 and hydration < 25 then
        hydration = hydration * (Config.HYDRATION_POINTS_PER_THIRST or 1000)
    end

    local expectedCalories, expectedHydration, scriptItem = getExpectedStaticNutritionForFullType(entry.fullType)
    local isStaticFood = not Nutrition.IsSyntheticReserveEntry(entry) and not isWaterHydrationSource(nil, scriptItem)

    if expectedCalories > 0 and calories > (expectedCalories * 1.5) then
        calories = expectedCalories
    end
    if expectedHydration > 0 and hydration > (expectedHydration * 1.5) then
        hydration = expectedHydration
    end
    if isStaticFood then
        if expectedCalories > 0 and calories <= 0 and hydration > 0 then
            calories = expectedCalories
        end
        if expectedHydration > 0 and hydration <= 0 and calories > 0 then
            hydration = expectedHydration
        end
    end

    entry.caloriesRemaining = calories
    entry.hydrationRemaining = hydration
    return calories, hydration
end

local function normalizeLedgerEntry(entry)
    return Nutrition.SanitizeLedgerEntry(entry)
end

local function pruneEmptyEntries(worker)
    if not worker then
        return
    end

    worker.nutritionLedger = worker.nutritionLedger or {}
    for i = #worker.nutritionLedger, 1, -1 do
        local calories, hydration = normalizeLedgerEntry(worker.nutritionLedger[i])
        if calories <= 0.0001 and hydration <= 0.0001 then
            table.remove(worker.nutritionLedger, i)
        end
    end
end

local function getReserveCaps(caloriesCap, hydrationCap)
    return clampAmount(caloriesCap), clampAmount(hydrationCap)
end

local function getOnBodyTotals(worker)
    if not worker then
        return 0, 0
    end

    return clampAmount(worker.caloriesCached) + clampAmount(worker.caloriesOverflow),
        clampAmount(worker.hydrationCached) + clampAmount(worker.hydrationOverflow)
end

local function normalizeOnBodyReserve(worker, caloriesCap, hydrationCap)
    if not worker then
        return 0, 0, 0, 0
    end

    local safeCaloriesCap, safeHydrationCap = getReserveCaps(caloriesCap, hydrationCap)
    local totalCalories, totalHydration = getOnBodyTotals(worker)

    worker.caloriesCached = math.min(totalCalories, safeCaloriesCap)
    worker.hydrationCached = math.min(totalHydration, safeHydrationCap)
    worker.caloriesOverflow = math.max(0, totalCalories - safeCaloriesCap)
    worker.hydrationOverflow = math.max(0, totalHydration - safeHydrationCap)

    return worker.caloriesCached, worker.hydrationCached, worker.caloriesOverflow, worker.hydrationOverflow
end

local function setOnBodyTotals(worker, calories, hydration, caloriesCap, hydrationCap)
    if not worker then
        return
    end

    worker.caloriesCached = clampAmount(calories)
    worker.hydrationCached = clampAmount(hydration)
    worker.caloriesOverflow = 0
    worker.hydrationOverflow = 0
    normalizeOnBodyReserve(worker, caloriesCap, hydrationCap)
end

local function findNextConsumableEntry(worker)
    if not worker then
        return nil, nil
    end

    pruneEmptyEntries(worker)
    worker.nutritionLedger = worker.nutritionLedger or {}
    return (#worker.nutritionLedger > 0) and 1 or nil, worker.nutritionLedger[1]
end

function Nutrition.PruneEmptyEntries(worker)
    pruneEmptyEntries(worker)
end

function Nutrition.GetLedgerTotals(worker)
    local calories = 0
    local hydration = 0
    for _, entry in ipairs(worker and worker.nutritionLedger or {}) do
        local entryCalories, entryHydration = normalizeLedgerEntry(entry)
        calories = calories + entryCalories
        hydration = hydration + entryHydration
    end
    return calories, hydration
end

function Nutrition.GetTotalAvailableAmounts(worker)
    local onBodyCalories, onBodyHydration = getOnBodyTotals(worker)
    local ledgerCalories, ledgerHydration = Nutrition.GetLedgerTotals(worker)
    return onBodyCalories + ledgerCalories, onBodyHydration + ledgerHydration
end

function Nutrition.GetOnBodyTotals(worker)
    return getOnBodyTotals(worker)
end

function Nutrition.NormalizeOnBodyReserve(worker, caloriesCap, hydrationCap)
    return normalizeOnBodyReserve(worker, caloriesCap, hydrationCap)
end

function Nutrition.SetOnBodyTotals(worker, calories, hydration, caloriesCap, hydrationCap)
    setOnBodyTotals(worker, calories, hydration, caloriesCap, hydrationCap)
end

function Nutrition.AddReserveAmounts(worker, calories, hydration, caloriesCap, hydrationCap)
    if not worker then
        return
    end

    local totalCalories, totalHydration = getOnBodyTotals(worker)
    setOnBodyTotals(
        worker,
        totalCalories + clampAmount(calories),
        totalHydration + clampAmount(hydration),
        caloriesCap,
        hydrationCap
    )
end

function Nutrition.ConsumeReserveAmounts(worker, caloriesNeeded, hydrationNeeded, caloriesCap, hydrationCap)
    if not worker then
        return true, true
    end

    local caloriesTarget = clampAmount(caloriesNeeded)
    local hydrationTarget = clampAmount(hydrationNeeded)
    local totalCalories, totalHydration = getOnBodyTotals(worker)
    local caloriesUsed = math.min(totalCalories, caloriesTarget)
    local hydrationUsed = math.min(totalHydration, hydrationTarget)

    setOnBodyTotals(
        worker,
        totalCalories - caloriesUsed,
        totalHydration - hydrationUsed,
        caloriesCap,
        hydrationCap
    )

    return caloriesUsed >= (caloriesTarget - 0.0001), hydrationUsed >= (hydrationTarget - 0.0001)
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
        index, entry = findNextConsumableEntry(worker)
    end

    if not index or not entry then
        return 0, 0, nil
    end

    local calories, hydration = normalizeLedgerEntry(entry)
    table.remove(worker.nutritionLedger, index)
    Nutrition.AddReserveAmounts(worker, calories, hydration, caloriesCap, hydrationCap)
    local displayName = tostring(entry.displayName or entry.fullType or "Provision")
    local actionVerb = (hydration > 0 and calories <= 0) and "Drank" or "Ate"
    appendWorkerLog(
        worker,
        actionVerb .. " " .. displayName .. " (" .. string.format("%.0f", calories) .. " cal, " .. string.format("%.0f", hydration) .. " hyd).",
        (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour(),
        "nutrition"
    )
    pruneEmptyEntries(worker)
    return calories, hydration, entry
end

function Nutrition.RefillReserveToTargets(worker, caloriesTarget, hydrationTarget, caloriesCap, hydrationCap)
    if not worker then
        return 0, 0
    end

    local caloriesMoved = 0
    local hydrationMoved = 0
    local targetCalories = clampAmount(caloriesTarget)
    local targetHydration = clampAmount(hydrationTarget)
    local consumedCount = 0

    while consumedCount < 512 do
        local totalCalories, totalHydration = getOnBodyTotals(worker)
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

function Nutrition.ConsumeAmounts(worker, caloriesNeeded, hydrationNeeded)
    if not worker then
        return true, true
    end

    local totalCalories, totalHydration = getOnBodyTotals(worker)
    return Nutrition.ConsumeReserveAmounts(worker, caloriesNeeded, hydrationNeeded, totalCalories, totalHydration)
end

function Nutrition.ConsumeForHours(worker, caloriesPerHour, hydrationPerHour, hours)
    if not worker or hours <= 0 then
        return true, true
    end

    local caloriesNeeded = math.max(0, caloriesPerHour * hours)
    local hydrationNeeded = math.max(0, hydrationPerHour * hours)
    return Nutrition.ConsumeAmounts(worker, caloriesNeeded, hydrationNeeded)
end

return Nutrition

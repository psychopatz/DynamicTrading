require "DT/Common/Labour/DT_Labour_Config"
require "DT/Common/Trading/DT_Economy_Common"

DT_Labour = DT_Labour or {}
DT_Labour.Nutrition = DT_Labour.Nutrition or {}

local Config = DT_Labour.Config
local Nutrition = DT_Labour.Nutrition

local function getScriptItem(invItem)
    if not invItem or not invItem.getFullType then return nil end
    return getScriptManager():getItem(invItem:getFullType())
end

local function containsText(haystack, needle)
    if not haystack or not needle then
        return false
    end
    return string.find(string.lower(tostring(haystack)), string.lower(tostring(needle)), 1, true) ~= nil
end

local function isWaterHydrationSource(invItem, scriptItem)
    if not invItem then
        return false
    end

    if invItem.isWaterSource and invItem:isWaterSource() then
        return true
    end

    local fullType = invItem.getFullType and invItem:getFullType() or nil
    local displayName = invItem.getDisplayName and invItem:getDisplayName() or nil
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

function Nutrition.GetItemNutrition(invItem)
    if not invItem then
        return 0, 0
    end

    local scriptItem = getScriptItem(invItem)
    local calories = 0
    local thirstChange = 0

    if invItem.getCalories then
        calories = tonumber(invItem:getCalories()) or 0
    end
    if calories <= 0 and scriptItem and scriptItem.getCalories then
        calories = tonumber(scriptItem:getCalories()) or 0
    end

    if invItem.getThirstChange then
        thirstChange = tonumber(invItem:getThirstChange()) or 0
    end
    if thirstChange == 0 and scriptItem and scriptItem.getThirstChange then
        thirstChange = tonumber(scriptItem:getThirstChange()) or 0
    end

    local hydration = normalizeHydrationPoints(thirstChange)

    if hydration <= 0 and isWaterHydrationSource(invItem, scriptItem) and invItem.getFluidContainer and invItem:getFluidContainer() then
        local fluidContainer = invItem:getFluidContainer()
        if fluidContainer and fluidContainer.getAmount then
            local amount = tonumber(fluidContainer:getAmount()) or 0
            if amount > 0 then
                hydration = amount > 10 and amount or (amount * 100)
            end
        end
    end

    if calories <= 0 and scriptItem and scriptItem.getHungerChange then
        local hungerChange = DynamicTrading.Economy.Common.GetNormalizedHunger(scriptItem)
        if hungerChange < 0 then
            calories = math.abs(hungerChange) * 1800
        end
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

local function consumeField(worker, fieldName, amount)
    if not worker or amount <= 0 then
        return true
    end

    local remaining = amount
    worker.nutritionLedger = worker.nutritionLedger or {}

    for _, entry in ipairs(worker.nutritionLedger) do
        if remaining <= 0 then break end
        local current = tonumber(entry[fieldName]) or 0
        if current > 0 then
            local used = math.min(current, remaining)
            entry[fieldName] = current - used
            remaining = remaining - used
        end
    end

    return remaining <= 0.0001
end

function Nutrition.ConsumeAmounts(worker, caloriesNeeded, hydrationNeeded)
    if not worker then
        return true, true
    end

    local enoughCalories = consumeField(worker, "caloriesRemaining", math.max(0, tonumber(caloriesNeeded) or 0))
    local enoughHydration = consumeField(worker, "hydrationRemaining", math.max(0, tonumber(hydrationNeeded) or 0))
    return enoughCalories, enoughHydration
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

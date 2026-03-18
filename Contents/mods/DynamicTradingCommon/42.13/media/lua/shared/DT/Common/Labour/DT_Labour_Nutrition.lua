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

    local hydration = math.abs(Config.NormalizeUnitValue(thirstChange))

    if hydration <= 0 and invItem.getFluidContainer and invItem:getFluidContainer() then
        local fluidContainer = invItem:getFluidContainer()
        if fluidContainer and fluidContainer.getAmount then
            hydration = tonumber(fluidContainer:getAmount()) or 0
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

function Nutrition.ConsumeForHours(worker, caloriesPerHour, hydrationPerHour, hours)
    if not worker or hours <= 0 then
        return true, true
    end

    local caloriesNeeded = math.max(0, caloriesPerHour * hours)
    local hydrationNeeded = math.max(0, hydrationPerHour * hours)

    local enoughCalories = consumeField(worker, "caloriesRemaining", caloriesNeeded)
    local enoughHydration = consumeField(worker, "hydrationRemaining", hydrationNeeded)

    return enoughCalories, enoughHydration
end

return Nutrition

DT_LabourSupplyWindow = DT_LabourSupplyWindow or {}
DT_LabourSupplyWindow.Internal = DT_LabourSupplyWindow.Internal or {}

local Internal = DT_LabourSupplyWindow.Internal

Internal.Config = DT_Labour.Config
Internal.Nutrition = DT_Labour.Nutrition
Internal.ENTRY_SCAN_BATCH_SIZE = 40
Internal.RAW_SCAN_STEP_LIMIT = 600
Internal.NutritionPreviewCache = Internal.NutritionPreviewCache or {}

function Internal.getCommandModule()
    local config = Internal.Config
    if type(config) == "table" and config.COMMAND_MODULE and config.COMMAND_MODULE ~= "" then
        return config.COMMAND_MODULE
    end
    return "DynamicTrading_V2"
end

function Internal.getLocalPlayer()
    local config = Internal.Config
    if config.GetPlayerObject then
        return config.GetPlayerObject()
    end
    if getSpecificPlayer then
        return getSpecificPlayer(0)
    end
    return getPlayer and getPlayer() or nil
end

function Internal.getCachedNutritionPreview(invItem)
    if not invItem then
        return 0, 0
    end

    local hasDynamicFluid = invItem.getFluidContainer and invItem:getFluidContainer() ~= nil
    local fullType = invItem.getFullType and invItem:getFullType() or nil
    local cache = Internal.NutritionPreviewCache

    if not hasDynamicFluid and fullType and cache[fullType] then
        local cached = cache[fullType]
        return cached.calories or 0, cached.hydration or 0
    end

    local calories, hydration = Internal.Nutrition.GetItemNutrition(invItem)
    calories = math.max(0, tonumber(calories) or 0)
    hydration = math.max(0, tonumber(hydration) or 0)

    if not hasDynamicFluid and fullType then
        cache[fullType] = {
            calories = calories,
            hydration = hydration
        }
    end

    return calories, hydration
end

function Internal.formatEntryLabel(entry)
    if not entry then
        return "Unknown Item"
    end

    return tostring(entry.displayName or entry.fullType or "Unknown Item")
end

function Internal.buildInventoryEntry(invItem)
    local calories, hydration = Internal.getCachedNutritionPreview(invItem)
    return {
        invItem = invItem,
        itemID = invItem:getID(),
        displayName = invItem:getDisplayName(),
        fullType = invItem:getFullType(),
        calories = calories,
        hydration = hydration,
        canDeposit = calories > 0 or hydration > 0,
        texture = invItem.getTex and invItem:getTex() or nil,
    }
end

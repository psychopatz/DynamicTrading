DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

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

function Internal.buildInventoryEntry(invItem)
    local calories, hydration = Internal.getCachedNutritionPreview(invItem)
    local fullType = invItem:getFullType()
    local tags = Internal.Config.GetItemCombinedTags and Internal.Config.GetItemCombinedTags(fullType)
        or (Internal.Config.FindItemTags and Internal.Config.FindItemTags(fullType))
        or {}
    return {
        kind = "player",
        invItem = invItem,
        itemID = invItem:getID(),
        displayName = invItem:getDisplayName(),
        fullType = fullType,
        calories = calories,
        hydration = hydration,
        canDeposit = calories > 0 or hydration > 0,
        canAssignTool = Internal.Config.IsLabourToolFullType and Internal.Config.IsLabourToolFullType(fullType) or false,
        tags = tags,
        texture = invItem.getTex and invItem:getTex() or nil,
    }
end

function Internal.buildWorkerSupplyEntry(entry, index)
    if not entry then
        return nil
    end

    return {
        kind = "worker",
        itemID = entry.itemID,
        ledgerIndex = index,
        displayName = entry.displayName,
        fullType = entry.fullType,
        calories = math.max(0, tonumber(entry.caloriesRemaining) or 0),
        hydration = math.max(0, tonumber(entry.hydrationRemaining) or 0),
        texture = entry.texture or Internal.getTextureForFullType(entry.fullType),
        pending = entry.pending == true,
    }
end

function Internal.buildWorkerToolEntry(entry, index)
    if not entry then
        return nil
    end

    local tags = entry.tags or {}
    if Internal.Config.GetItemCombinedTags and entry.fullType then
        tags = Internal.Config.GetItemCombinedTags(entry.fullType)
    end

    return {
        kind = "tool",
        ledgerIndex = index,
        displayName = entry.displayName,
        fullType = entry.fullType,
        tags = tags,
        texture = entry.texture or Internal.getTextureForFullType(entry.fullType),
        pending = entry.pending == true,
    }
end

function Internal.buildWorkerOutputEntry(entry, index)
    if not entry then
        return nil
    end

    return {
        kind = "output",
        ledgerIndex = index,
        displayName = Internal.getDisplayNameForFullType(entry.fullType),
        fullType = entry.fullType,
        qty = math.max(1, tonumber(entry.qty) or 1),
        texture = entry.texture or Internal.getTextureForFullType(entry.fullType),
    }
end

function Internal.buildWorkerEntryFromPlayerEntry(entry)
    if not entry then
        return nil
    end

    return {
        kind = "worker",
        itemID = entry.itemID,
        displayName = entry.displayName,
        fullType = entry.fullType,
        calories = math.max(0, tonumber(entry.calories) or 0),
        hydration = math.max(0, tonumber(entry.hydration) or 0),
        texture = entry.texture,
        pending = true,
    }
end

function Internal.buildWorkerToolEntryFromPlayerEntry(entry)
    if not entry then
        return nil
    end

    return {
        kind = "tool",
        displayName = entry.displayName,
        fullType = entry.fullType,
        tags = entry.tags or {},
        texture = entry.texture,
        pending = true,
    }
end

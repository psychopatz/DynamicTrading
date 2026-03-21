DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

Internal.Config = DT_Labour and DT_Labour.Config or Internal.Config or {}
Internal.Nutrition = DT_Labour and DT_Labour.Nutrition or Internal.Nutrition or {}
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

function Internal.normalizeFilterText(text)
    local value = string.lower(tostring(text or ""))
    value = string.gsub(value, "^%s+", "")
    value = string.gsub(value, "%s+$", "")
    return value
end

function Internal.matchesFilter(entry, filterText)
    local filter = Internal.normalizeFilterText(filterText)
    if filter == "" then
        return true
    end

    local haystacks = {
        string.lower(tostring(entry.displayName or "")),
        string.lower(tostring(entry.fullType or "")),
    }

    for _, haystack in ipairs(haystacks) do
        if haystack ~= "" and string.find(haystack, filter, 1, true) then
            return true
        end
    end

    return false
end

function Internal.compareEntries(a, b)
    local aName = string.lower(Internal.formatEntryLabel(a))
    local bName = string.lower(Internal.formatEntryLabel(b))
    if aName == bName then
        return tostring(a.fullType or "") < tostring(b.fullType or "")
    end
    return aName < bName
end

function Internal.resolveWorkerDetail(workerID)
    if not workerID then
        return nil
    end

    if isClient() and not isServer() then
        local cache = DT_MainWindow and DT_MainWindow.cachedDetails or nil
        return cache and cache[workerID] or nil
    end

    if DT_Labour and DT_Labour.Registry and DT_Labour.Registry.GetWorkerDetailsForOwner then
        local owner = nil
        local player = Internal.getLocalPlayer()
        if Internal.Config and Internal.Config.GetOwnerUsername then
            owner = Internal.Config.GetOwnerUsername(player)
        end
        return DT_Labour.Registry.GetWorkerDetailsForOwner(owner or "local", workerID)
    end

    return nil
end

function Internal.buildInventoryEntry(invItem)
    local calories, hydration = Internal.getCachedNutritionPreview(invItem)
    return {
        kind = "player",
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
        texture = entry.texture,
        pending = entry.pending == true,
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

function Internal.getWorkerSupplyTotals(entries)
    local totals = {
        count = 0,
        calories = 0,
        hydration = 0,
    }

    for _, entry in ipairs(entries or {}) do
        totals.count = totals.count + 1
        totals.calories = totals.calories + math.max(0, tonumber(entry.calories) or 0)
        totals.hydration = totals.hydration + math.max(0, tonumber(entry.hydration) or 0)
    end

    return totals
end

function Internal.getSearchText(box)
    if not box then
        return ""
    end
    if box.getInternalText then
        return box:getInternalText()
    end
    if box.getText then
        return box:getText()
    end
    return ""
end

function DT_SupplyWindow:sendLabourCommand(command, args)
    local player = Internal.getLocalPlayer()
    if not player then
        return false
    end

    if isClient() and not isServer() then
        sendClientCommand(player, Internal.getCommandModule(), command, args or {})
        return true
    end

    if DT_Labour and DT_Labour.Network and DT_Labour.Network.HandleCommand then
        DT_Labour.Network.HandleCommand(player, command, args or {})
        return true
    end

    return false
end

DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

Internal.Config = DT_Labour and DT_Labour.Config or Internal.Config or {}
Internal.Nutrition = DT_Labour and DT_Labour.Nutrition or Internal.Nutrition or {}
Internal.ENTRY_SCAN_BATCH_SIZE = 40
Internal.RAW_SCAN_STEP_LIMIT = 600
Internal.NutritionPreviewCache = Internal.NutritionPreviewCache or {}
Internal.TextureCache = Internal.TextureCache or {}
Internal.Tabs = {
    Provisions = "provisions",
    Output = "output",
    Equipment = "equipment",
}

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

function Internal.getDisplayNameForFullType(fullType)
    if not fullType or not getScriptManager then
        return tostring(fullType or "Unknown Item")
    end

    local item = getScriptManager():getItem(fullType)
    if item and item.getDisplayName then
        return item:getDisplayName()
    end

    return tostring(fullType or "Unknown Item")
end

local function isValidItemTexture(tex)
    return tex and tex.getName and tex:getName() ~= "Question_Highlight"
end

local function safeCall(target, methodName, ...)
    if not target or not target[methodName] then
        return nil
    end

    local ok, result = pcall(target[methodName], target, ...)
    if ok then
        return result
    end

    return nil
end

local function tryTexture(textureName)
    if not textureName or textureName == "" then
        return nil
    end

    local tex = getTexture(textureName)
    if isValidItemTexture(tex) then
        return tex
    end

    return nil
end

local function normalizeIconVariants(rawVariants)
    if not rawVariants then
        return nil
    end

    if type(rawVariants) == "string" then
        local variants = {}
        for entry in string.gmatch(rawVariants, "([^;]+)") do
            entry = entry:gsub("^%s+", ""):gsub("%s+$", "")
            if entry ~= "" then
                variants[#variants + 1] = entry
            end
        end
        return #variants > 0 and variants or nil
    end

    if type(rawVariants) == "table" then
        return #rawVariants > 0 and rawVariants or nil
    end

    if rawVariants.size and rawVariants.get then
        local variants = {}
        for i = 0, rawVariants:size() - 1 do
            local entry = rawVariants:get(i)
            if entry and tostring(entry) ~= "" then
                variants[#variants + 1] = tostring(entry)
            end
        end
        return #variants > 0 and variants or nil
    end

    return nil
end

local function getScriptIconVariants(script)
    if not script then
        return nil
    end

    local candidates = {
        safeCall(script, "getIconsForTexture"),
        safeCall(script, "getIconsForTextures"),
        safeCall(script, "getIconsForTextureString"),
        safeCall(script, "getIconsForTextureChoices"),
    }

    for _, candidate in ipairs(candidates) do
        local variants = normalizeIconVariants(candidate)
        if variants then
            return variants
        end
    end

    return nil
end

local function resolveScriptVariantTexture(script)
    local variants = getScriptIconVariants(script)
    if not variants then
        return nil
    end

    for _, variant in ipairs(variants) do
        local tex = tryTexture("Item_" .. variant)
            or tryTexture(variant)
            or tryTexture("media/textures/Item_" .. variant .. ".png")
        if tex then
            return tex
        end
    end

    return nil
end

local function resolveInventoryItemTexture(item)
    if not item then
        return nil
    end

    if item.getTex then
        local tex = item:getTex()
        if isValidItemTexture(tex) then
            return tex
        end
    end

    if item.getIcon then
        local icon = item:getIcon()
        if icon and type(icon) ~= "string" and isValidItemTexture(icon) then
            return icon
        end
    end

    local tex = safeCall(item, "getTexture")
    if isValidItemTexture(tex) then
        return tex
    end

    return nil
end

function Internal.getTextureForFullType(fullType)
    if not fullType then
        return nil
    end

    local cache = Internal.TextureCache or {}
    Internal.TextureCache = cache
    if cache[fullType] ~= nil then
        return cache[fullType]
    end

    local texture = nil
    local script = getScriptManager and getScriptManager():getItem(fullType) or nil

    if DT_TradingWindow and DT_TradingWindow.GetItemTexture then
        texture = DT_TradingWindow.GetItemTexture(fullType, nil)
    end

    if not isValidItemTexture(texture) and script then
        texture = resolveScriptVariantTexture(script)
    end

    if not isValidItemTexture(texture) and script then
        local iconStr = safeCall(script, "getIcon")
        if iconStr and iconStr ~= "" then
            texture = tryTexture("Item_" .. iconStr)
                or tryTexture(iconStr)
                or tryTexture("media/textures/Item_" .. iconStr .. ".png")
        end
    end

    if not isValidItemTexture(texture) and script and script.getClothingItem then
        local clothingItem = script:getClothingItem()
        if clothingItem and clothingItem ~= "" then
            texture = tryTexture("Item_" .. clothingItem) or tryTexture(clothingItem)
        end
    end

    if not isValidItemTexture(texture) and InventoryItemFactory and InventoryItemFactory.CreateItem then
        local ok, item = pcall(InventoryItemFactory.CreateItem, fullType)
        if ok and item then
            texture = resolveInventoryItemTexture(item)
        end
    end

    cache[fullType] = isValidItemTexture(texture) and texture or false
    return cache[fullType] or nil
end

function Internal.getOutputTabLabel(worker)
    if not worker or not worker.jobType then
        return "Merchandise"
    end

    local config = Internal.Config or {}
    local jobTypes = config.JobTypes or {}
    local normalizedJob = config.NormalizeJobType and config.NormalizeJobType(worker and worker.jobType) or tostring(worker and worker.jobType or "")

    if normalizedJob == jobTypes.Farm then
        return "Yield"
    end
    if normalizedJob == jobTypes.Fish then
        return "Catch"
    end
    if normalizedJob == jobTypes.Scavenge then
        return "Haul"
    end

    return "Merchandise"
end

function Internal.getActiveWorkerTabLabel(window)
    local activeTab = window and window.activeTab or Internal.Tabs.Provisions
    if activeTab == Internal.Tabs.Equipment then
        return "Equipment"
    end
    if activeTab == Internal.Tabs.Output then
        return Internal.getOutputTabLabel(window and window.workerData)
    end
    return "Provisions"
end

function Internal.getRequiredToolSummary(worker)
    local config = Internal.Config or {}
    local profile = config.GetJobProfile and config.GetJobProfile(worker and worker.jobType) or {}
    local requiredTags = profile and profile.requiredToolTags or {}
    if not requiredTags or #requiredTags <= 0 then
        return "Any labour tool"
    end
    return table.concat(requiredTags, ", ")
end

function Internal.buildInventoryEntry(invItem)
    local calories, hydration = Internal.getCachedNutritionPreview(invItem)
    local fullType = invItem:getFullType()
    local tags = Internal.Config.FindItemTags and Internal.Config.FindItemTags(fullType) or {}
    return {
        kind = "player",
        invItem = invItem,
        itemID = invItem:getID(),
        displayName = invItem:getDisplayName(),
        fullType = fullType,
        calories = calories,
        hydration = hydration,
        canDeposit = calories > 0 or hydration > 0,
        canAssignTool = Internal.Config.HasMatchingTag and Internal.Config.HasMatchingTag(tags, "Tool") or false,
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

    return {
        kind = "tool",
        ledgerIndex = index,
        displayName = entry.displayName,
        fullType = entry.fullType,
        tags = entry.tags or {},
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

function Internal.getWorkerTabSummary(window, entries)
    local activeTab = window and window.activeTab or Internal.Tabs.Provisions

    if activeTab == Internal.Tabs.Equipment then
        return tostring(#(entries or {})) .. " equipped"
    end

    if activeTab == Internal.Tabs.Output then
        local stacks = 0
        local totalQty = 0
        for _, entry in ipairs(entries or {}) do
            stacks = stacks + 1
            totalQty = totalQty + math.max(1, tonumber(entry.qty) or 1)
        end
        return tostring(stacks) .. " stacks | " .. tostring(totalQty) .. " total"
    end

    local totals = Internal.getWorkerSupplyTotals(entries)
    return tostring(totals.count) .. " entries | "
        .. string.format("%.0f cal", totals.calories) .. " | "
        .. string.format("%.0f hyd", totals.hydration)
end

function Internal.shouldShowPlayerEntry(entry, activeTab)
    if not entry then
        return false
    end

    if activeTab == Internal.Tabs.Equipment then
        return true
    end

    if activeTab == Internal.Tabs.Output then
        return false
    end

    return entry.canDeposit == true
end

function Internal.shouldShowWorkerEntry(entry, activeTab)
    if not entry then
        return false
    end

    if activeTab == Internal.Tabs.Equipment or activeTab == Internal.Tabs.Output then
        return true
    end

    return (tonumber(entry.calories) or 0) > 0 or (tonumber(entry.hydration) or 0) > 0
end

function Internal.getPlayerEntryPresentation(entry, activeTab, worker)
    if activeTab == Internal.Tabs.Equipment then
        if entry.canAssignTool then
            return {
                statText = Internal.getRequiredToolSummary(worker),
                badgeText = "Tool",
                dimmed = false,
            }
        end
        return {
            statText = "Not a labour tool",
            badgeText = "Preview",
            dimmed = true,
        }
    end

    if activeTab == Internal.Tabs.Output then
        return {
            statText = "Worker storage tab",
            badgeText = "Read Only",
            dimmed = true,
        }
    end

    if entry.canDeposit then
        return {
            statText = string.format("+%.0f cal | +%.0f hyd", entry.calories or 0, entry.hydration or 0),
            badgeText = "Ready",
            dimmed = false,
        }
    end

    return {
        statText = "No calories or hydration",
        badgeText = "Preview",
        dimmed = true,
    }
end

function Internal.getWorkerEntryPresentation(entry, activeTab)
    if activeTab == Internal.Tabs.Equipment then
        local tags = entry.tags or {}
        local tagText = (#tags > 0) and table.concat(tags, ", ") or "Assigned labour tool"
        return {
            statText = tagText,
            badgeText = "",
        }
    end

    if activeTab == Internal.Tabs.Output then
        return {
            statText = "Qty " .. tostring(entry.qty or 1),
            badgeText = "",
        }
    end

    return {
        statText = string.format("%.0f cal left | %.0f hyd left", entry.calories or 0, entry.hydration or 0),
        badgeText = "",
    }
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

local Internal = DT_PricingOptionsTabInternal
local CreateInternal = DT_PricingOptionsCreateInternal

function CreateInternal.OnRefreshPrices(state)
    DynamicTrading.PriceConfig.RequestSync()
    Internal.refreshAll(state)
    Internal.setStatus(state, "Requested latest price config from the server.", false)
end

function CreateInternal.OnCollapseAll(state)
    local tag
    local node

    for tag in pairs(state.nodeMap or {}) do
        node = state.nodeMap[tag]
        if node and node.childKeys and #node.childKeys > 0 then
            state.collapsed[tag] = true
        end
    end
    Internal.persistTreeState(state)
    Internal.refreshAll(state)
    Internal.setStatus(state, "Collapsed all pricing categories.", false)
end

function CreateInternal.OnApplyPreset(state)
    local presetName = CreateInternal.GetSelectedPresetName(state)
    local success
    local payload
    local warnings

    if presetName == "" then
        Internal.setStatus(state, "No saved preset selected.", true)
        return
    end

    state.presetEntry:setText(presetName)
    success, payload, warnings = DT_PricePresetIO.importPreset(presetName)
    if not success then
        Internal.setStatus(state, tostring(payload or "Preset import failed."), true)
        return
    end
    if not Internal.sendPriceCommand("ImportPricePreset", {
        tagMultipliers = payload.tagMultipliers,
        itemOverrides = payload.itemOverrides
    }) then
        Internal.setStatus(state, "Unable to apply preset.", true)
        return
    end
    if warnings and #warnings > 0 then
        Internal.setStatus(state, "Preset applied with " .. tostring(#warnings) .. " warnings.", false)
    else
        Internal.setStatus(state, "Preset applied: " .. presetName, false)
    end
    CreateInternal.RefreshPresetSelector(state, presetName)
end

function CreateInternal.OnRefreshPresetList(state)
    CreateInternal.RefreshPresetSelector(state)
    Internal.setStatus(state, "Saved preset list refreshed.", false)
end

function CreateInternal.OnApplyTag(state)
    local tag = state.selectedTag
    local multiplier = tonumber(state.multiplierEntry:getText() or "")

    if not tag then
        Internal.setStatus(state, "Select a tag branch first.", true)
        return
    end
    if multiplier == nil then
        Internal.setStatus(state, "Enter a valid tag multiplier.", true)
        return
    end
    if not Internal.sendPriceCommand("ApplyPriceTagMultiplier", { tag = tag, multiplier = multiplier }) then
        Internal.setStatus(state, "Unable to send tag update.", true)
    end
end

function CreateInternal.OnResetTag(state)
    if not state.selectedTag then
        Internal.setStatus(state, "Select a tag branch to reset.", true)
        return
    end
    state.multiplierEntry:setText("1.0")
    if not Internal.sendPriceCommand("ApplyPriceTagMultiplier", { tag = state.selectedTag, multiplier = 1.0 }) then
        Internal.setStatus(state, "Unable to send tag reset.", true)
    end
end

function CreateInternal.OnApplyItem(state)
    local basePrice

    if not state.selectedItemKey then
        Internal.setStatus(state, "Select an item override target first.", true)
        return
    end
    basePrice = tonumber(state.itemOverrideEntry:getText() or "")
    if basePrice == nil then
        Internal.setStatus(state, "Enter a valid item base price.", true)
        return
    end
    if not Internal.sendPriceCommand("ApplyItemBasePriceOverride", { itemKey = state.selectedItemKey, basePrice = basePrice }) then
        Internal.setStatus(state, "Unable to send item override.", true)
    end
end

function CreateInternal.OnResetItem(state)
    if not state.selectedItemKey then
        Internal.setStatus(state, "Select an item override target first.", true)
        return
    end
    if not Internal.sendPriceCommand("ResetItemBasePriceOverride", { itemKey = state.selectedItemKey }) then
        Internal.setStatus(state, "Unable to send item reset.", true)
    end
end

function CreateInternal.OnExportPreset(state)
    local success
    local result

    success, result = DT_PricePresetIO.exportPreset(state.presetEntry:getText(), DynamicTrading.PriceConfig.GetData())
    if success then
        CreateInternal.RefreshPresetSelector(state, state.presetEntry:getText())
        Internal.setStatus(state, "Preset exported to " .. tostring(DT_PricePresetIO.getExportPathHint(state.presetEntry:getText())), false)
    else
        Internal.setStatus(state, tostring(result or "Preset export failed."), true)
    end
end

function CreateInternal.OnImportPreset(state)
    local success
    local payload
    local warnings

    success, payload, warnings = DT_PricePresetIO.importPreset(state.presetEntry:getText())
    if not success then
        Internal.setStatus(state, tostring(payload or "Preset import failed."), true)
        return
    end
    if not Internal.sendPriceCommand("ImportPricePreset", {
        tagMultipliers = payload.tagMultipliers,
        itemOverrides = payload.itemOverrides
    }) then
        Internal.setStatus(state, "Unable to send preset import.", true)
        return
    end
    if warnings and #warnings > 0 then
        Internal.setStatus(state, "Preset parsed with " .. tostring(#warnings) .. " local warnings. Server validation in progress.", false)
    else
        Internal.setStatus(state, "Preset import requested.", false)
    end
    CreateInternal.RefreshPresetSelector(state, payload.name or state.presetEntry:getText())
end

function CreateInternal.OnResetAll(state)
    if not Internal.sendPriceCommand("ResetAllPriceOverrides", {}) then
        Internal.setStatus(state, "Unable to send reset-all command.", true)
    end
end

function CreateInternal.OnSearch(state)
    Internal.requestSearchRefresh(state)
end

function CreateInternal.OnClearSearch(state)
    state.searchEntry:setText("")
    Internal.requestSearchRefresh(state)
end

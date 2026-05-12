local Internal = DT_PricingOptionsTabInternal

function Internal.refreshDetailPanel(state)
    local node
    local selectedRow
    local row
    local lines
    local overrideValue
    local previewKeys
    local config
    local masterList
    local index
    local itemKey
    local itemData
    local displayName
    local defaultBase
    local effectiveBase

    if not state.details then
        return
    end

    node = Internal.getSelectedNode(state)
    if state.selectedTagLabel then
        state.selectedTagLabel:setName("Selected Tag: " .. tostring(node and node.tag or "none"))
    end

    if not node then
        if state.multiplierEntry then
            state.multiplierEntry:setText("1.0")
        end
        if state.itemOverrideEntry then
            state.itemOverrideEntry:setText("")
        end
        state.details:setText(" <RGB:0.70,0.70,0.70> Select a tag branch to edit pricing. <LINE> <LINE> Tags are detected dynamically from the active registry and item tag data. ")
        state.details:paginate()
        return
    end

    if state.multiplierEntry then
        state.multiplierEntry:setText(tostring(node.directMultiplier or 1.0))
    end

    lines = {}
    lines[#lines + 1] = " <RGB:0.95,0.95,0.95> Tag: " .. tostring(node.tag)
    lines[#lines + 1] = " <LINE> <RGB:0.70,0.70,0.70> Matching Items: " .. tostring(node.count or 0)
    lines[#lines + 1] = " <LINE> <RGB:0.70,0.70,0.70> Effective Branch Multiplier: " .. Internal.formatMultiplier(node.effectiveMultiplier or 1.0)

    if node.directMultiplier ~= nil then
        lines[#lines + 1] = " <LINE> <RGB:0.80,1.00,0.80> Direct Override: " .. Internal.formatMultiplier(node.directMultiplier)
    else
        lines[#lines + 1] = " <LINE> <RGB:0.80,0.80,0.80> Direct Override: none"
    end

    selectedRow = nil
    for _, row in ipairs(state.resultRows or {}) do
        if row.itemKey == state.selectedItemKey then
            selectedRow = row
            break
        end
    end

    if state.itemOverrideEntry then
        overrideValue = state.selectedItemKey and DynamicTrading.PriceConfig.GetData().itemOverrides[state.selectedItemKey] or nil
        if overrideValue ~= nil then
            state.itemOverrideEntry:setText(tostring(overrideValue))
        elseif selectedRow then
            state.itemOverrideEntry:setText(tostring(selectedRow.effectiveBase))
        else
            state.itemOverrideEntry:setText("")
        end
    end

    if selectedRow then
        lines[#lines + 1] = " <LINE> <LINE> <RGB:0.95,0.85,0.45> Selected Item"
        lines[#lines + 1] = " <LINE> <RGB:0.90,0.90,0.90> " .. tostring(selectedRow.displayName) .. " <RGB:0.65,0.65,0.65> (" .. tostring(selectedRow.itemKey) .. ")"
        lines[#lines + 1] = " <LINE> <RGB:0.70,0.70,0.70> Default $" .. Internal.formatPrice(selectedRow.defaultBase) .. " -> Effective $" .. Internal.formatPrice(selectedRow.effectiveBase)
        if selectedRow.directOverride ~= nil then
            lines[#lines + 1] = " <LINE> <RGB:0.80,1.00,0.80> Item Override: $" .. Internal.formatPrice(selectedRow.directOverride)
        else
            lines[#lines + 1] = " <LINE> <RGB:0.80,0.80,0.80> Item Override: none"
        end
    end

    previewKeys = node.samples or {}
    if #previewKeys > 0 then
        lines[#lines + 1] = " <LINE> <LINE> <RGB:0.95,0.85,0.45> Preview"
        config = DynamicTrading.PriceConfig.GetData()
        masterList = DynamicTrading.Config and DynamicTrading.Config.MasterList or {}
        for index = 1, math.min(#previewKeys, Internal.PREVIEW_SAMPLE_COUNT) do
            itemKey = previewKeys[index]
            itemData = masterList[itemKey]
            if itemData then
                displayName = Internal.getItemDisplayName(itemKey, itemData, state.displayNameCache)
                defaultBase = DynamicTrading.PriceConfig.GetDefaultBasePrice(itemKey, itemData)
                effectiveBase = DynamicTrading.PriceConfig.GetEffectiveBasePrice(itemKey, itemData, config)
                lines[#lines + 1] = " <LINE> <RGB:0.90,0.90,0.90> " .. displayName .. " <RGB:0.65,0.65,0.65> (" .. itemKey .. ")"
                lines[#lines + 1] = " <LINE> <RGB:0.70,0.70,0.70> $" .. Internal.formatPrice(defaultBase) .. " -> $" .. Internal.formatPrice(effectiveBase)
            end
        end
    else
        lines[#lines + 1] = " <LINE> <LINE> <RGB:0.70,0.70,0.70> No preview samples found for this branch yet."
    end

    state.details:setText(table.concat(lines))
    state.details:paginate()
end

function Internal.refreshAll(state)
    Internal.refreshTree(state)
    Internal.refreshSearchResults(state)
    Internal.refreshDetailPanel(state)
end

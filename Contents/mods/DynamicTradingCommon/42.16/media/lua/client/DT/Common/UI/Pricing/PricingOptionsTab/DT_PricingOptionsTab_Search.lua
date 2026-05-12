local Internal = DT_PricingOptionsTabInternal

local function buildSearchRows(state)
    local rows = {}
    local selectedTag = state.selectedTag
    local filterText
    local config
    local nameCache
    local masterList
    local itemKey
    local itemData
    local displayName
    local haystack

    if not selectedTag then
        state.searchOverflowCount = 0
        return rows
    end

    filterText = Internal.lower(state.searchEntry and state.searchEntry:getText() or "")
    config = DynamicTrading.PriceConfig.GetData()
    nameCache = state.displayNameCache or {}
    masterList = DynamicTrading.Config and DynamicTrading.Config.MasterList or {}

    for itemKey, itemData in pairs(masterList) do
        if DynamicTrading.PriceConfig.ItemMatchesTag(itemData, selectedTag) then
            displayName = Internal.getItemDisplayName(itemKey, itemData, nameCache)
            haystack = Internal.lower(itemKey .. " " .. displayName)
            if filterText == "" or string.find(haystack, filterText, 1, true) then
                rows[#rows + 1] = {
                    itemKey = itemKey,
                    displayName = displayName,
                    itemData = itemData,
                    defaultBase = DynamicTrading.PriceConfig.GetDefaultBasePrice(itemKey, itemData),
                    effectiveBase = DynamicTrading.PriceConfig.GetEffectiveBasePrice(itemKey, itemData, config),
                    directOverride = config.itemOverrides[itemKey]
                }
            end
        end
    end

    table.sort(rows, function(left, right)
        if left.displayName ~= right.displayName then
            return Internal.sortStrings(left.displayName, right.displayName)
        end
        return left.itemKey < right.itemKey
    end)

    if #rows > Internal.MAX_SEARCH_RESULTS then
        state.searchOverflowCount = #rows - Internal.MAX_SEARCH_RESULTS
        while #rows > Internal.MAX_SEARCH_RESULTS do
            table.remove(rows)
        end
    else
        state.searchOverflowCount = 0
    end

    return rows
end

local function refreshSearchInfo(state)
    local shownCount

    if not state.searchInfoLabel then
        return
    end

    if not state.selectedTag then
        state.searchInfoLabel:setName("Select a tag branch to browse matching items.")
        return
    end

    shownCount = #(state.resultRows or {})
    if state.searchOverflowCount and state.searchOverflowCount > 0 then
        state.searchInfoLabel:setName("Showing " .. tostring(shownCount) .. " results. " .. tostring(state.searchOverflowCount) .. " more match this branch.")
    else
        state.searchInfoLabel:setName("Showing " .. tostring(shownCount) .. " results for the selected branch.")
    end
end

function Internal.refreshSearchResults(state)
    local foundSelected
    local index
    local row

    if not state.resultList then
        return
    end

    state.resultRows = buildSearchRows(state)
    state.resultList:clear()
    state.resultList.selected = -1

    for _, row in ipairs(state.resultRows or {}) do
        state.resultList:addItem(row.displayName, row)
    end

    foundSelected = false
    if state.selectedItemKey then
        for index, row in ipairs(state.resultList.items or {}) do
            if row and row.item and row.item.itemKey == state.selectedItemKey then
                state.resultList.selected = index
                foundSelected = true
                break
            end
        end
    end

    if not foundSelected then
        state.selectedItemKey = nil
    end

    refreshSearchInfo(state)
end

function Internal.onResultMouseDown(listbox, x, y)
    local state = listbox and listbox.parentState or nil
    local row
    local entry

    if not state or not listbox or not listbox.rowAt then
        return
    end

    row = listbox:rowAt(x, y)
    if row == -1 then
        return
    end

    entry = listbox.items[row] and listbox.items[row].item or nil
    if not entry or not entry.itemKey then
        return
    end

    listbox.selected = row
    state.selectedItemKey = entry.itemKey
    Internal.refreshDetailPanel(state)
end

function Internal.drawResultItem(listbox, y, item, alt)
    local row = item and item.item or nil
    local width
    local valueText

    if not row then
        return y + (listbox.itemheight or 36)
    end

    width = listbox.getWidth and listbox:getWidth() or listbox.width or 0

    if listbox.selected == item.index then
        listbox:drawRect(0, y, width, listbox.itemheight, 0.25, 0.35, 0.55, 0.9)
    elseif alt then
        listbox:drawRect(0, y, width, listbox.itemheight, 0.08, 1, 1, 1)
    else
        listbox:drawRect(0, y, width, listbox.itemheight, 0.05, 0, 0, 0)
    end

    listbox:drawText(tostring(row.displayName), 8, y + 3, 0.95, 0.95, 0.95, 1, UIFont.Small)
    listbox:drawText(tostring(row.itemKey), 8, y + 18, 0.65, 0.65, 0.65, 1, UIFont.Small)

    valueText = "$" .. Internal.formatPrice(row.defaultBase) .. " -> $" .. Internal.formatPrice(row.effectiveBase)
    if row.directOverride ~= nil then
        valueText = valueText .. " *"
    end
    listbox:drawText(valueText, math.max(120, width - 170), y + 10, 0.75, 0.9, 0.75, 1, UIFont.Small)
    return y + listbox.itemheight
end

function Internal.requestSearchRefresh(state)
    Internal.refreshSearchResults(state)
    Internal.refreshDetailPanel(state)
end

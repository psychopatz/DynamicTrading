-- =============================================================================
-- DYNAMIC TRADING: OPTIONS UI - PRICING TAB
-- =============================================================================

require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISComboBox"
require "ISUI/ISTextEntryBox"
require "DT/Common/UI/Pricing/DT_PricePresetIO"

DT_PricingOptionsTab = DT_PricingOptionsTab or {}

local MAX_SEARCH_RESULTS = 25
local PREVIEW_SAMPLE_COUNT = 5

local function trim(value)
    local text = tostring(value or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function formatMultiplier(value)
    return string.format("x%.3f", tonumber(value) or 1.0)
end

local function formatPrice(value)
    return tostring(math.floor((tonumber(value) or 0) + 0.5))
end

local function sortStrings(left, right)
    return lower(left) < lower(right)
end

local function sortedKeys(map)
    local keys = {}
    for key in pairs(map or {}) do
        keys[#keys + 1] = key
    end
    table.sort(keys, sortStrings)
    return keys
end

local function getDepth(tag)
    if not tag or tag == "" then
        return 0
    end

    local _, count = string.gsub(tag, "%.", "")
    return count
end

local function getItemDisplayName(itemKey, itemData, cache)
    cache = cache or {}
    if cache[itemKey] ~= nil then
        return cache[itemKey]
    end

    local displayName = itemKey
    if itemData and itemData.item then
        local scriptItem = getScriptManager():getItem(itemData.item)
        if scriptItem and scriptItem:getDisplayName() then
            displayName = scriptItem:getDisplayName()
        end
    end

    cache[itemKey] = displayName
    return displayName
end

local function persistTreeState(state)
    local collapsed = {}
    for tag, isCollapsed in pairs(state.collapsed or {}) do
        if isCollapsed then
            collapsed[#collapsed + 1] = tag
        end
    end
    table.sort(collapsed, sortStrings)

    if DT_ConfigManager and DT_ConfigManager.setPriceCollapsedTags then
        DT_ConfigManager.setPriceCollapsedTags(collapsed)
    end
    if DT_ConfigManager and DT_ConfigManager.setPriceEditorSelection then
        DT_ConfigManager.setPriceEditorSelection(state.selectedTag or "")
    end
end

local function buildBranchStats()
    local stats = {}
    local masterList = DynamicTrading.Config and DynamicTrading.Config.MasterList or {}

    for itemKey, itemData in pairs(masterList) do
        local seen = {}
        for _, tag in ipairs(itemData.tags or {}) do
            local probe = tag
            while probe do
                if not seen[probe] then
                    local entry = stats[probe]
                    if not entry then
                        entry = {
                            count = 0,
                            samples = {},
                            sampleLookup = {}
                        }
                        stats[probe] = entry
                    end

                    entry.count = entry.count + 1
                    if #entry.samples < PREVIEW_SAMPLE_COUNT and not entry.sampleLookup[itemKey] then
                        entry.samples[#entry.samples + 1] = itemKey
                        entry.sampleLookup[itemKey] = true
                    end
                    seen[probe] = true
                end
                probe = string.match(probe, "^(.*)%.")
            end
        end
    end

    return stats
end

local function buildTreeNodes(state)
    local nodeMap = {}
    local rootTags = {}
    local stats = buildBranchStats()
    local knownTags = DynamicTrading.PriceConfig.GetKnownTags()
    local config = DynamicTrading.PriceConfig.GetData()

    for tag in pairs(knownTags) do
        nodeMap[tag] = nodeMap[tag] or { tag = tag, childKeys = {} }
    end
    for tag in pairs(config.tagMultipliers or {}) do
        nodeMap[tag] = nodeMap[tag] or { tag = tag, childKeys = {} }
    end

    for tag, node in pairs(nodeMap) do
        node.childKeys = {}
        node.parentTag = string.match(tag, "^(.*)%.")
        node.depth = getDepth(tag)
        node.label = string.match(tag, "([^.]+)$") or tag
        node.count = stats[tag] and stats[tag].count or 0
        node.samples = stats[tag] and stats[tag].samples or {}
        node.directMultiplier = config.tagMultipliers[tag]
        node.effectiveMultiplier = DynamicTrading.PriceConfig.GetBranchMultiplierForTag(tag, config)
    end

    for tag, node in pairs(nodeMap) do
        if node.parentTag and nodeMap[node.parentTag] then
            nodeMap[node.parentTag].childKeys[#nodeMap[node.parentTag].childKeys + 1] = tag
        else
            rootTags[#rootTags + 1] = tag
        end
    end

    local function sortChildren(keys)
        table.sort(keys, function(left, right)
            local leftNode = nodeMap[left]
            local rightNode = nodeMap[right]
            local leftCount = leftNode and leftNode.count or 0
            local rightCount = rightNode and rightNode.count or 0
            if leftCount ~= rightCount then
                return leftCount > rightCount
            end
            return sortStrings(left, right)
        end)
    end

    sortChildren(rootTags)
    for _, node in pairs(nodeMap) do
        sortChildren(node.childKeys)
    end

    state.treeStats = stats
    state.nodeMap = nodeMap
    state.rootTags = rootTags
end

local function addVisibleNode(state, tag)
    local node = state.nodeMap and state.nodeMap[tag] or nil
    if not node then
        return
    end

    state.treeList:addItem(tag, node)
    if state.collapsed[tag] then
        return
    end

    for _, childTag in ipairs(node.childKeys or {}) do
        addVisibleNode(state, childTag)
    end
end

local function refreshTree(state)
    if not state.treeList then
        return
    end

    buildTreeNodes(state)

    if state.selectedTag and not state.nodeMap[state.selectedTag] then
        state.selectedTag = nil
    end

    state.treeList:clear()
    state.treeList.selected = -1

    for _, tag in ipairs(state.rootTags or {}) do
        addVisibleNode(state, tag)
    end

    if state.selectedTag then
        for index, row in ipairs(state.treeList.items or {}) do
            if row and row.item and row.item.tag == state.selectedTag then
                state.treeList.selected = index
                break
            end
        end
    end
end

local function getSelectedNode(state)
    return state.selectedTag and state.nodeMap and state.nodeMap[state.selectedTag] or nil
end

local function buildSearchRows(state)
    local rows = {}
    local selectedTag = state.selectedTag
    if not selectedTag then
        state.searchOverflowCount = 0
        return rows
    end

    local filterText = lower(state.searchEntry and state.searchEntry:getText() or "")
    local config = DynamicTrading.PriceConfig.GetData()
    local nameCache = state.displayNameCache or {}
    local masterList = DynamicTrading.Config and DynamicTrading.Config.MasterList or {}

    for itemKey, itemData in pairs(masterList) do
        if DynamicTrading.PriceConfig.ItemMatchesTag(itemData, selectedTag) then
            local displayName = getItemDisplayName(itemKey, itemData, nameCache)
            local haystack = lower(itemKey .. " " .. displayName)
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
            return sortStrings(left.displayName, right.displayName)
        end
        return left.itemKey < right.itemKey
    end)

    if #rows > MAX_SEARCH_RESULTS then
        state.searchOverflowCount = #rows - MAX_SEARCH_RESULTS
        while #rows > MAX_SEARCH_RESULTS do
            table.remove(rows)
        end
    else
        state.searchOverflowCount = 0
    end

    return rows
end

local function refreshSearchInfo(state)
    if not state.searchInfoLabel then
        return
    end

    if not state.selectedTag then
        state.searchInfoLabel:setName("Select a tag branch to browse matching items.")
        return
    end

    local shownCount = #(state.resultRows or {})
    if state.searchOverflowCount and state.searchOverflowCount > 0 then
        state.searchInfoLabel:setName("Showing " .. tostring(shownCount) .. " results. " .. tostring(state.searchOverflowCount) .. " more match this branch.")
    else
        state.searchInfoLabel:setName("Showing " .. tostring(shownCount) .. " results for the selected branch.")
    end
end

local function refreshSearchResults(state)
    if not state.resultList then
        return
    end

    state.resultRows = buildSearchRows(state)
    state.resultList:clear()
    state.resultList.selected = -1

    for _, row in ipairs(state.resultRows or {}) do
        state.resultList:addItem(row.displayName, row)
    end

    local foundSelected = false
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

local function setStatus(state, text, isError)
    if not state.statusLabel then
        return
    end

    state.statusLabel:setName(tostring(text or ""))
    if isError then
        state.statusLabel:setColor(1, 0.45, 0.45)
    else
        state.statusLabel:setColor(0.75, 0.85, 0.75)
    end
end

local function refreshDetailPanel(state)
    if not state.details then
        return
    end

    local node = getSelectedNode(state)
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

    local lines = {}
    lines[#lines + 1] = " <RGB:0.95,0.95,0.95> Tag: " .. tostring(node.tag)
    lines[#lines + 1] = " <LINE> <RGB:0.70,0.70,0.70> Matching Items: " .. tostring(node.count or 0)
    lines[#lines + 1] = " <LINE> <RGB:0.70,0.70,0.70> Effective Branch Multiplier: " .. formatMultiplier(node.effectiveMultiplier or 1.0)

    if node.directMultiplier ~= nil then
        lines[#lines + 1] = " <LINE> <RGB:0.80,1.00,0.80> Direct Override: " .. formatMultiplier(node.directMultiplier)
    else
        lines[#lines + 1] = " <LINE> <RGB:0.80,0.80,0.80> Direct Override: none"
    end

    local selectedRow = nil
    for _, row in ipairs(state.resultRows or {}) do
        if row.itemKey == state.selectedItemKey then
            selectedRow = row
            break
        end
    end

    if state.itemOverrideEntry then
        local overrideValue = state.selectedItemKey and DynamicTrading.PriceConfig.GetData().itemOverrides[state.selectedItemKey] or nil
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
        lines[#lines + 1] = " <LINE> <RGB:0.70,0.70,0.70> Default $" .. formatPrice(selectedRow.defaultBase) .. " -> Effective $" .. formatPrice(selectedRow.effectiveBase)
        if selectedRow.directOverride ~= nil then
            lines[#lines + 1] = " <LINE> <RGB:0.80,1.00,0.80> Item Override: $" .. formatPrice(selectedRow.directOverride)
        else
            lines[#lines + 1] = " <LINE> <RGB:0.80,0.80,0.80> Item Override: none"
        end
    end

    local previewKeys = node.samples or {}
    if #previewKeys > 0 then
        lines[#lines + 1] = " <LINE> <LINE> <RGB:0.95,0.85,0.45> Preview"
        local config = DynamicTrading.PriceConfig.GetData()
        local masterList = DynamicTrading.Config and DynamicTrading.Config.MasterList or {}
        for index = 1, math.min(#previewKeys, PREVIEW_SAMPLE_COUNT) do
            local itemKey = previewKeys[index]
            local itemData = masterList[itemKey]
            if itemData then
                local displayName = getItemDisplayName(itemKey, itemData, state.displayNameCache)
                local defaultBase = DynamicTrading.PriceConfig.GetDefaultBasePrice(itemKey, itemData)
                local effectiveBase = DynamicTrading.PriceConfig.GetEffectiveBasePrice(itemKey, itemData, config)
                lines[#lines + 1] = " <LINE> <RGB:0.90,0.90,0.90> " .. displayName .. " <RGB:0.65,0.65,0.65> (" .. itemKey .. ")"
                lines[#lines + 1] = " <LINE> <RGB:0.70,0.70,0.70> $" .. formatPrice(defaultBase) .. " -> $" .. formatPrice(effectiveBase)
            end
        end
    else
        lines[#lines + 1] = " <LINE> <LINE> <RGB:0.70,0.70,0.70> No preview samples found for this branch yet."
    end

    state.details:setText(table.concat(lines))
    state.details:paginate()
end

local function refreshAll(state)
    refreshTree(state)
    refreshSearchResults(state)
    refreshDetailPanel(state)
end

local function sendPriceCommand(command, args)
    local player = getPlayer and getPlayer() or nil
    if not player and getSpecificPlayer then
        player = getSpecificPlayer(0)
    end
    if not player then
        return false
    end

    sendClientCommand(player, "DynamicTrading", command, args or {})
    return true
end

local function onTreeMouseDown(listbox, x, y)
    local state = listbox and listbox.parentState or nil
    if not state or not listbox or not listbox.rowAt then
        return
    end

    local row = listbox:rowAt(x, y)
    if row == -1 then
        return
    end

    local entry = listbox.items[row] and listbox.items[row].item or nil
    if not entry or not entry.tag then
        return
    end

    local isSameSelection = (state.selectedTag == entry.tag)
    listbox.selected = row
    state.selectedTag = entry.tag
    state.selectedItemKey = nil

    if isSameSelection and entry.childKeys and #entry.childKeys > 0 then
        state.collapsed[entry.tag] = not state.collapsed[entry.tag]
    end

    persistTreeState(state)
    refreshAll(state)
end

local function onResultMouseDown(listbox, x, y)
    local state = listbox and listbox.parentState or nil
    if not state or not listbox or not listbox.rowAt then
        return
    end

    local row = listbox:rowAt(x, y)
    if row == -1 then
        return
    end

    local entry = listbox.items[row] and listbox.items[row].item or nil
    if not entry or not entry.itemKey then
        return
    end

    listbox.selected = row
    state.selectedItemKey = entry.itemKey
    refreshDetailPanel(state)
end

local function drawTreeItem(listbox, y, item, alt)
    local node = item and item.item or nil
    if not node then
        return y + (listbox.itemheight or 24)
    end

    local width = listbox.getWidth and listbox:getWidth() or listbox.width or 0

    if listbox.selected == item.index then
        listbox:drawRect(0, y, width, listbox.itemheight, 0.25, 0.35, 0.55, 0.9)
    elseif alt then
        listbox:drawRect(0, y, width, listbox.itemheight, 0.08, 1, 1, 1)
    else
        listbox:drawRect(0, y, width, listbox.itemheight, 0.05, 0, 0, 0)
    end

    local state = listbox.parentState
    local indent = 8 + ((node.depth or 0) * 18)
    local prefix = "   "
    if node.childKeys and #node.childKeys > 0 then
        prefix = state and state.collapsed[node.tag] and "[+] " or "[-] "
    end

    local title = prefix .. tostring(node.label)
    local info = string.format("%d | %s", node.count or 0, formatMultiplier(node.effectiveMultiplier or 1.0))
    if node.directMultiplier ~= nil then
        info = info .. " *"
    end

    listbox:drawText(title, indent, y + 4, 0.9, 0.9, 0.9, 1, UIFont.Small)
    listbox:drawText(info, math.max(110, width - 100), y + 4, 0.7, 0.85, 0.7, 1, UIFont.Small)
    return y + listbox.itemheight
end

local function drawResultItem(listbox, y, item, alt)
    local row = item and item.item or nil
    if not row then
        return y + (listbox.itemheight or 36)
    end

    local width = listbox.getWidth and listbox:getWidth() or listbox.width or 0

    if listbox.selected == item.index then
        listbox:drawRect(0, y, width, listbox.itemheight, 0.25, 0.35, 0.55, 0.9)
    elseif alt then
        listbox:drawRect(0, y, width, listbox.itemheight, 0.08, 1, 1, 1)
    else
        listbox:drawRect(0, y, width, listbox.itemheight, 0.05, 0, 0, 0)
    end

    listbox:drawText(tostring(row.displayName), 8, y + 3, 0.95, 0.95, 0.95, 1, UIFont.Small)
    listbox:drawText(tostring(row.itemKey), 8, y + 18, 0.65, 0.65, 0.65, 1, UIFont.Small)

    local valueText = "$" .. formatPrice(row.defaultBase) .. " -> $" .. formatPrice(row.effectiveBase)
    if row.directOverride ~= nil then
        valueText = valueText .. " *"
    end
    listbox:drawText(valueText, math.max(120, width - 170), y + 10, 0.75, 0.9, 0.75, 1, UIFont.Small)
    return y + listbox.itemheight
end

local function requestSearchRefresh(state)
    refreshSearchResults(state)
    refreshDetailPanel(state)
end

local function getKnownPresetNames(state)
    local names = {}
    local seen = {}

    local function add(name)
        local text = trim(name)
        if text == "" or seen[text] then
            return
        end
        seen[text] = true
        names[#names + 1] = text
    end

    if DT_ConfigManager and DT_ConfigManager.getKnownPricePresets then
        for _, name in ipairs(DT_ConfigManager.getKnownPricePresets() or {}) do
            add(name)
        end
    end

    if DT_ConfigManager and DT_ConfigManager.getLastPricePresetName then
        add(DT_ConfigManager.getLastPricePresetName())
    end

    if state and state.presetEntry then
        add(state.presetEntry:getText())
    end

    if #names == 0 then
        add("default")
    end

    table.sort(names, sortStrings)
    return names
end

local function refreshPresetSelector(state, preferredName)
    if not state or not state.presetCombo then
        return
    end

    local names = getKnownPresetNames(state)
    state.presetCombo:clear()
    for _, name in ipairs(names) do
        state.presetCombo:addOption(name)
    end

    local desired = trim(preferredName or (state.presetEntry and state.presetEntry:getText()) or "")
    local selectedIndex = 1
    for index, name in ipairs(names) do
        if name == desired then
            selectedIndex = index
            break
        end
    end
    state.presetCombo.selected = selectedIndex
end

local function getSelectedPresetName(state)
    if not state or not state.presetCombo then
        return ""
    end

    local selected = state.presetCombo.selected or 1
    if state.presetCombo.getOptionText then
        return trim(state.presetCombo:getOptionText(selected) or "")
    end
    return ""
end

local function relayoutScrollWidget(widget)
    if not widget then
        return
    end

    local width = widget.getWidth and widget:getWidth() or widget.width or 0
    local height = widget.getHeight and widget:getHeight() or widget.height or 0

    if widget.vscroll then
        local scrollW = widget.vscroll.getWidth and widget.vscroll:getWidth() or widget.vscroll.width or 13
        if widget.vscroll.setX then
            widget.vscroll:setX(math.max(0, width - scrollW))
        end
        if widget.vscroll.setY then
            widget.vscroll:setY(0)
        end
        if widget.vscroll.setHeight then
            widget.vscroll:setHeight(height)
        end
    end
end

local function relayoutRichText(widget)
    if not widget then
        return
    end

    relayoutScrollWidget(widget)
    if widget.paginate then
        widget:paginate()
    end
end

function DT_PricingOptionsTab.Refresh(owner)
    local state = owner and owner.pricingState or nil
    if not state then
        return
    end
    refreshAll(state)
end

function DT_PricingOptionsTab.SaveLocalState(owner)
    local state = owner and owner.pricingState or nil
    if not state then
        return
    end

    persistTreeState(state)
    if DT_ConfigManager and DT_ConfigManager.setLastPricePresetName and state.presetEntry then
        DT_ConfigManager.setLastPricePresetName(state.presetEntry:getText())
    end
end

function DT_PricingOptionsTab.Destroy(owner)
    local state = owner and owner.pricingState or nil
    if not state then
        return
    end

    DT_PricingOptionsTab.SaveLocalState(owner)

    if state.onConfigUpdated then
        Events.OnDynamicTradingPriceConfigUpdated.Remove(state.onConfigUpdated)
    end
    if state.onActionResult then
        Events.OnDynamicTradingPriceConfigActionResult.Remove(state.onActionResult)
    end
    if state.panel then
        state.panel.prerender = state.previousPanelPrerender
    end

    owner.pricingState = nil
end

function DT_PricingOptionsTab.OnResize(owner)
    local state = owner and owner.pricingState or nil
    if not state or not state.panel then
        return
    end

    local panel = state.panel
    local pad = 10
    local panelW = panel.getWidth and panel:getWidth() or panel.width or 0
    local panelH = panel.getHeight and panel:getHeight() or panel.height or 0
    local resizeGripPad = 18
    local footerPad = 18
    local leftW = math.max(240, math.min(320, math.floor(panelW * 0.30)))
    local rightX = leftW + (pad * 2)
    local rightW = math.max(320, panelW - rightX - pad - resizeGripPad)
    local paneH = panelH - (pad * 2) - footerPad
    local statusH = 20
    local innerPad = 10
    local leftInnerW = leftW - (innerPad * 2)
    local rightInnerW = rightW - (innerPad * 2)
    local headerH = 176
    local searchH = 70
    local resultH = math.max(120, math.floor((paneH - headerH - searchH - statusH - (pad * 4)) * 0.32))
    local detailY = headerH + searchH + resultH + (pad * 3)
    local detailH = math.max(120, paneH - detailY - statusH - pad)
    local leftFooterY = paneH - 34
    local treeH = math.max(150, leftFooterY - innerPad - 8)

    state.leftPane:setX(pad)
    state.leftPane:setY(pad)
    state.leftPane:setWidth(leftW)
    state.leftPane:setHeight(paneH)

    state.rightPane:setX(rightX)
    state.rightPane:setY(pad)
    state.rightPane:setWidth(rightW)
    state.rightPane:setHeight(paneH)

    state.headerPanel:setX(0)
    state.headerPanel:setY(0)
    state.headerPanel:setWidth(rightW)
    state.headerPanel:setHeight(headerH)

    state.searchPanel:setX(0)
    state.searchPanel:setY(headerH + pad)
    state.searchPanel:setWidth(rightW)
    state.searchPanel:setHeight(searchH)

    state.resultPanel:setX(0)
    state.resultPanel:setY(headerH + searchH + (pad * 2))
    state.resultPanel:setWidth(rightW)
    state.resultPanel:setHeight(resultH)

    state.detailPanel:setX(0)
    state.detailPanel:setY(detailY)
    state.detailPanel:setWidth(rightW)
    state.detailPanel:setHeight(detailH)

    state.treeList:setX(innerPad)
    state.treeList:setY(innerPad)
    state.treeList:setWidth(leftInnerW)
    state.treeList:setHeight(treeH)
    relayoutScrollWidget(state.treeList)

    state.btnRefresh:setX(innerPad)
    state.btnRefresh:setY(leftFooterY)
    state.btnCollapseAll:setX(innerPad + 95)
    state.btnCollapseAll:setY(leftFooterY)

    local labelX = innerPad
    local valueX = 122
    local fieldW = 80
    local buttonW = 78
    local buttonGap = 8
    local rightActionsW = (buttonW * 3) + (buttonGap * 2)

    state.exportHintLabel:setX(innerPad)
    state.exportHintLabel:setY(8)
    if state.exportHintLabel.setWidth then
        state.exportHintLabel:setWidth(rightInnerW)
    end

    state.presetLibraryLabel:setX(labelX)
    state.presetLibraryLabel:setY(30)
    state.presetCombo:setX(valueX)
    state.presetCombo:setY(26)
    state.presetCombo:setWidth(math.max(140, rightW - valueX - 214))
    state.btnApplyPreset:setX(rightW - innerPad - 164)
    state.btnApplyPreset:setY(24)
    state.btnApplyPreset:setWidth(78)
    state.btnRefreshPresets:setX(rightW - innerPad - 78)
    state.btnRefreshPresets:setY(24)
    state.btnRefreshPresets:setWidth(78)

    state.selectedTagLabel:setX(innerPad)
    state.selectedTagLabel:setY(58)
    if state.selectedTagLabel.setWidth then
        state.selectedTagLabel:setWidth(rightInnerW)
    end

    state.multiplierLabel:setX(labelX)
    state.multiplierLabel:setY(86)
    state.multiplierEntry:setX(valueX)
    state.multiplierEntry:setY(82)
    state.multiplierEntry:setWidth(fieldW)
    state.btnApplyTag:setX(valueX + fieldW + buttonGap)
    state.btnApplyTag:setY(80)
    state.btnApplyTag:setWidth(buttonW)
    state.btnResetTag:setX(valueX + fieldW + buttonGap + buttonW + buttonGap)
    state.btnResetTag:setY(80)
    state.btnResetTag:setWidth(buttonW)

    state.itemOverrideLabel:setX(labelX)
    state.itemOverrideLabel:setY(118)
    state.itemOverrideEntry:setX(valueX)
    state.itemOverrideEntry:setY(114)
    state.itemOverrideEntry:setWidth(fieldW)
    state.btnApplyItem:setX(valueX + fieldW + buttonGap)
    state.btnApplyItem:setY(112)
    state.btnApplyItem:setWidth(buttonW)
    state.btnResetItem:setX(valueX + fieldW + buttonGap + buttonW + buttonGap)
    state.btnResetItem:setY(112)
    state.btnResetItem:setWidth(buttonW)

    state.presetLabel:setX(labelX)
    state.presetLabel:setY(150)
    state.presetEntry:setX(valueX)
    state.presetEntry:setY(146)
    state.presetEntry:setWidth(math.max(120, rightW - valueX - rightActionsW - 28))
    state.btnExport:setX(rightW - innerPad - rightActionsW)
    state.btnExport:setY(144)
    state.btnExport:setWidth(buttonW)
    state.btnImport:setX(rightW - innerPad - (buttonW * 2) - buttonGap)
    state.btnImport:setY(144)
    state.btnImport:setWidth(buttonW)
    state.btnResetAll:setX(rightW - innerPad - buttonW)
    state.btnResetAll:setY(144)
    state.btnResetAll:setWidth(buttonW)

    state.searchLabel:setX(innerPad)
    state.searchLabel:setY(8)
    state.searchEntry:setX(innerPad)
    state.searchEntry:setY(28)
    state.searchEntry:setWidth(math.max(140, rightW - 190 - (innerPad * 2)))
    state.btnSearch:setX(rightW - innerPad - 170)
    state.btnSearch:setY(26)
    state.btnSearch:setWidth(buttonW)
    state.btnClearSearch:setX(rightW - innerPad - buttonW)
    state.btnClearSearch:setY(26)
    state.btnClearSearch:setWidth(buttonW)
    state.searchInfoLabel:setX(innerPad)
    state.searchInfoLabel:setY(52)
    if state.searchInfoLabel.setWidth then
        state.searchInfoLabel:setWidth(rightInnerW)
    end

    state.resultList:setX(6)
    state.resultList:setY(6)
    state.resultList:setWidth(rightW - 12)
    state.resultList:setHeight(resultH - 12)
    relayoutScrollWidget(state.resultList)

    state.details:setX(6)
    state.details:setY(6)
    state.details:setWidth(rightW - 12)
    state.details:setHeight(detailH - 12)
    relayoutRichText(state.details)

    state.statusLabel:setX(0)
    state.statusLabel:setY(paneH - statusH - 2)
    if state.statusLabel.setWidth then
        state.statusLabel:setWidth(rightW)
    end

    refreshSearchResults(state)
    refreshDetailPanel(state)
end

function DT_PricingOptionsTab.Create(owner, panel)
    local state = {
        owner = owner,
        panel = panel,
        collapsed = {},
        selectedTag = DT_ConfigManager and DT_ConfigManager.getPriceEditorSelection and DT_ConfigManager.getPriceEditorSelection() or nil,
        selectedItemKey = nil,
        nodeMap = {},
        rootTags = {},
        displayNameCache = {},
        resultRows = {},
        searchOverflowCount = 0
    }

    local storedCollapsed = DT_ConfigManager and DT_ConfigManager.getPriceCollapsedTags and DT_ConfigManager.getPriceCollapsedTags() or {}
    for _, tag in ipairs(storedCollapsed) do
        state.collapsed[tag] = true
    end

    local function newBox(x, y, width, height, alpha)
        local box = ISPanel:new(x, y, width, height)
        box:initialise()
        box:instantiate()
        box.backgroundColor = { r = 0, g = 0, b = 0, a = alpha or 0.18 }
        box.borderColor = { r = 1, g = 1, b = 1, a = 0.12 }
        panel:addChild(box)
        return box
    end

    state.leftPane = newBox(0, 0, 100, 100, 0.14)
    state.leftPane:setAnchorLeft(true)
    state.leftPane:setAnchorTop(true)
    state.leftPane:setAnchorBottom(true)
    state.rightPane = newBox(0, 0, 100, 100, 0)
    state.rightPane:setAnchorLeft(true)
    state.rightPane:setAnchorRight(true)
    state.rightPane:setAnchorTop(true)
    state.rightPane:setAnchorBottom(true)
    state.headerPanel = ISPanel:new(0, 0, 100, 100)
    state.headerPanel:initialise()
    state.headerPanel:instantiate()
    state.headerPanel.backgroundColor = { r = 0, g = 0, b = 0, a = 0.12 }
    state.headerPanel.borderColor = { r = 1, g = 1, b = 1, a = 0.10 }
    state.rightPane:addChild(state.headerPanel)
    state.searchPanel = ISPanel:new(0, 0, 100, 100)
    state.searchPanel:initialise()
    state.searchPanel:instantiate()
    state.searchPanel.backgroundColor = { r = 0, g = 0, b = 0, a = 0.12 }
    state.searchPanel.borderColor = { r = 1, g = 1, b = 1, a = 0.10 }
    state.rightPane:addChild(state.searchPanel)
    state.resultPanel = ISPanel:new(0, 0, 100, 100)
    state.resultPanel:initialise()
    state.resultPanel:instantiate()
    state.resultPanel.backgroundColor = { r = 0, g = 0, b = 0, a = 0.18 }
    state.resultPanel.borderColor = { r = 1, g = 1, b = 1, a = 0.10 }
    state.rightPane:addChild(state.resultPanel)
    state.detailPanel = ISPanel:new(0, 0, 100, 100)
    state.detailPanel:initialise()
    state.detailPanel:instantiate()
    state.detailPanel.backgroundColor = { r = 0, g = 0, b = 0, a = 0.18 }
    state.detailPanel.borderColor = { r = 1, g = 1, b = 1, a = 0.10 }
    state.rightPane:addChild(state.detailPanel)

    state.treeList = ISScrollingListBox:new(0, 0, 100, 100)
    state.treeList:initialise()
    state.treeList:instantiate()
    state.treeList.itemheight = 24
    state.treeList.backgroundColor = { r = 0, g = 0, b = 0, a = 0.45 }
    state.treeList.borderColor = { r = 1, g = 1, b = 1, a = 0.12 }
    state.treeList.drawBorder = true
    state.treeList.doDrawItem = drawTreeItem
    state.treeList.onMouseDown = onTreeMouseDown
    state.treeList.onmousedown = function(target, item)
        if not target or not target.items then
            return false
        end
        for index, row in ipairs(target.items) do
            if row and row.item == item then
                onTreeMouseDown(target, 0, (index - 1) * (target.itemheight or 24))
                return true
            end
        end
        return false
    end
    state.treeList.parentState = state
    state.treeList:setAnchorRight(true)
    state.treeList:setAnchorBottom(true)
    state.leftPane:addChild(state.treeList)

    state.btnRefresh = ISButton:new(0, 0, 90, 24, "Refresh", panel, function()
        DynamicTrading.PriceConfig.RequestSync()
        refreshAll(state)
        setStatus(state, "Requested latest price config from the server.", false)
    end)
    state.btnRefresh:initialise()
    state.btnRefresh:instantiate()
    state.leftPane:addChild(state.btnRefresh)

    state.btnCollapseAll = ISButton:new(0, 0, 110, 24, "Collapse All", panel, function()
        for tag in pairs(state.nodeMap or {}) do
            local node = state.nodeMap[tag]
            if node and node.childKeys and #node.childKeys > 0 then
                state.collapsed[tag] = true
            end
        end
        persistTreeState(state)
        refreshAll(state)
        setStatus(state, "Collapsed all pricing categories.", false)
    end)
    state.btnCollapseAll:initialise()
    state.btnCollapseAll:instantiate()
    state.leftPane:addChild(state.btnCollapseAll)

    state.selectedTagLabel = ISLabel:new(0, 0, 18, "Selected Tag: none", 1, 1, 1, 1, UIFont.Medium, true)
    state.selectedTagLabel:initialise()
    state.selectedTagLabel:instantiate()
    state.headerPanel:addChild(state.selectedTagLabel)

    state.exportHintLabel = ISLabel:new(0, 0, 18, "Preset exports save to Zomboid/Lua/ as DynamicTrading_PricingPreset_<preset>.txt", 0.72, 0.72, 0.72, 1, UIFont.Small, true)
    state.exportHintLabel:initialise()
    state.exportHintLabel:instantiate()
    state.headerPanel:addChild(state.exportHintLabel)

    state.presetLibraryLabel = ISLabel:new(0, 0, 18, "Saved Presets", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    state.presetLibraryLabel:initialise()
    state.presetLibraryLabel:instantiate()
    state.headerPanel:addChild(state.presetLibraryLabel)

    state.presetCombo = ISComboBox:new(0, 0, 140, 24, panel, nil)
    state.presetCombo:initialise()
    state.presetCombo:instantiate()
    state.headerPanel:addChild(state.presetCombo)

    state.btnApplyPreset = ISButton:new(0, 0, 78, 24, "Apply", panel, function()
        local presetName = getSelectedPresetName(state)
        if presetName == "" then
            setStatus(state, "No saved preset selected.", true)
            return
        end

        state.presetEntry:setText(presetName)
        local success, payload, warnings = DT_PricePresetIO.importPreset(presetName)
        if not success then
            setStatus(state, tostring(payload or "Preset import failed."), true)
            return
        end
        if not sendPriceCommand("ImportPricePreset", {
            tagMultipliers = payload.tagMultipliers,
            itemOverrides = payload.itemOverrides
        }) then
            setStatus(state, "Unable to apply preset.", true)
            return
        end
        if warnings and #warnings > 0 then
            setStatus(state, "Preset applied with " .. tostring(#warnings) .. " warnings.", false)
        else
            setStatus(state, "Preset applied: " .. presetName, false)
        end
        refreshPresetSelector(state, presetName)
    end)
    state.btnApplyPreset:initialise()
    state.btnApplyPreset:instantiate()
    state.headerPanel:addChild(state.btnApplyPreset)

    state.btnRefreshPresets = ISButton:new(0, 0, 78, 24, "Refresh", panel, function()
        refreshPresetSelector(state)
        setStatus(state, "Saved preset list refreshed.", false)
    end)
    state.btnRefreshPresets:initialise()
    state.btnRefreshPresets:instantiate()
    state.headerPanel:addChild(state.btnRefreshPresets)

    state.multiplierLabel = ISLabel:new(0, 0, 18, "Tag Multiplier", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    state.multiplierLabel:initialise()
    state.multiplierLabel:instantiate()
    state.headerPanel:addChild(state.multiplierLabel)

    state.multiplierEntry = ISTextEntryBox:new("1.0", 0, 0, 80, 24)
    state.multiplierEntry:initialise()
    state.multiplierEntry:instantiate()
    state.headerPanel:addChild(state.multiplierEntry)

    state.btnApplyTag = ISButton:new(0, 0, 80, 24, "Apply Tag", panel, function()
        local tag = state.selectedTag
        local multiplier = tonumber(state.multiplierEntry:getText() or "")
        if not tag then
            setStatus(state, "Select a tag branch first.", true)
            return
        end
        if multiplier == nil then
            setStatus(state, "Enter a valid tag multiplier.", true)
            return
        end
        if not sendPriceCommand("ApplyPriceTagMultiplier", { tag = tag, multiplier = multiplier }) then
            setStatus(state, "Unable to send tag update.", true)
        end
    end)
    state.btnApplyTag:initialise()
    state.btnApplyTag:instantiate()
    state.headerPanel:addChild(state.btnApplyTag)

    state.btnResetTag = ISButton:new(0, 0, 80, 24, "Reset Tag", panel, function()
        if not state.selectedTag then
            setStatus(state, "Select a tag branch to reset.", true)
            return
        end
        state.multiplierEntry:setText("1.0")
        if not sendPriceCommand("ApplyPriceTagMultiplier", { tag = state.selectedTag, multiplier = 1.0 }) then
            setStatus(state, "Unable to send tag reset.", true)
        end
    end)
    state.btnResetTag:initialise()
    state.btnResetTag:instantiate()
    state.headerPanel:addChild(state.btnResetTag)

    state.itemOverrideLabel = ISLabel:new(0, 0, 18, "Item Base Price", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    state.itemOverrideLabel:initialise()
    state.itemOverrideLabel:instantiate()
    state.headerPanel:addChild(state.itemOverrideLabel)

    state.itemOverrideEntry = ISTextEntryBox:new("", 0, 0, 80, 24)
    state.itemOverrideEntry:initialise()
    state.itemOverrideEntry:instantiate()
    state.itemOverrideEntry:setOnlyNumbers(true)
    state.headerPanel:addChild(state.itemOverrideEntry)

    state.btnApplyItem = ISButton:new(0, 0, 80, 24, "Apply Item", panel, function()
        if not state.selectedItemKey then
            setStatus(state, "Select an item override target first.", true)
            return
        end
        local basePrice = tonumber(state.itemOverrideEntry:getText() or "")
        if basePrice == nil then
            setStatus(state, "Enter a valid item base price.", true)
            return
        end
        if not sendPriceCommand("ApplyItemBasePriceOverride", { itemKey = state.selectedItemKey, basePrice = basePrice }) then
            setStatus(state, "Unable to send item override.", true)
        end
    end)
    state.btnApplyItem:initialise()
    state.btnApplyItem:instantiate()
    state.headerPanel:addChild(state.btnApplyItem)

    state.btnResetItem = ISButton:new(0, 0, 80, 24, "Reset Item", panel, function()
        if not state.selectedItemKey then
            setStatus(state, "Select an item override target first.", true)
            return
        end
        if not sendPriceCommand("ResetItemBasePriceOverride", { itemKey = state.selectedItemKey }) then
            setStatus(state, "Unable to send item reset.", true)
        end
    end)
    state.btnResetItem:initialise()
    state.btnResetItem:instantiate()
    state.headerPanel:addChild(state.btnResetItem)

    state.presetLabel = ISLabel:new(0, 0, 18, "Preset Name", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    state.presetLabel:initialise()
    state.presetLabel:instantiate()
    state.headerPanel:addChild(state.presetLabel)

    state.presetEntry = ISTextEntryBox:new(DT_ConfigManager and DT_ConfigManager.getLastPricePresetName and DT_ConfigManager.getLastPricePresetName() or "default", 0, 0, 140, 24)
    state.presetEntry:initialise()
    state.presetEntry:instantiate()
    state.headerPanel:addChild(state.presetEntry)

    state.btnExport = ISButton:new(0, 0, 75, 24, "Export", panel, function()
        local success, result = DT_PricePresetIO.exportPreset(state.presetEntry:getText(), DynamicTrading.PriceConfig.GetData())
        if success then
            refreshPresetSelector(state, state.presetEntry:getText())
            setStatus(state, "Preset exported to " .. tostring(DT_PricePresetIO.getExportPathHint(state.presetEntry:getText())), false)
        else
            setStatus(state, tostring(result or "Preset export failed."), true)
        end
    end)
    state.btnExport:initialise()
    state.btnExport:instantiate()
    state.headerPanel:addChild(state.btnExport)

    state.btnImport = ISButton:new(0, 0, 75, 24, "Import", panel, function()
        local success, payload, warnings = DT_PricePresetIO.importPreset(state.presetEntry:getText())
        if not success then
            setStatus(state, tostring(payload or "Preset import failed."), true)
            return
        end
        if not sendPriceCommand("ImportPricePreset", {
            tagMultipliers = payload.tagMultipliers,
            itemOverrides = payload.itemOverrides
        }) then
            setStatus(state, "Unable to send preset import.", true)
            return
        end
        if warnings and #warnings > 0 then
            setStatus(state, "Preset parsed with " .. tostring(#warnings) .. " local warnings. Server validation in progress.", false)
        else
            setStatus(state, "Preset import requested.", false)
        end
        refreshPresetSelector(state, payload.name or state.presetEntry:getText())
    end)
    state.btnImport:initialise()
    state.btnImport:instantiate()
    state.headerPanel:addChild(state.btnImport)

    state.btnResetAll = ISButton:new(0, 0, 80, 24, "Reset All", panel, function()
        if not sendPriceCommand("ResetAllPriceOverrides", {}) then
            setStatus(state, "Unable to send reset-all command.", true)
        end
    end)
    state.btnResetAll:initialise()
    state.btnResetAll:instantiate()
    state.headerPanel:addChild(state.btnResetAll)

    state.searchLabel = ISLabel:new(0, 0, 18, "Branch Item Search", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    state.searchLabel:initialise()
    state.searchLabel:instantiate()
    state.searchPanel:addChild(state.searchLabel)

    state.searchEntry = ISTextEntryBox:new("", 0, 0, 120, 24)
    state.searchEntry:initialise()
    state.searchEntry:instantiate()
    state.searchPanel:addChild(state.searchEntry)

    state.btnSearch = ISButton:new(0, 0, 80, 24, "Find", panel, function()
        requestSearchRefresh(state)
    end)
    state.btnSearch:initialise()
    state.btnSearch:instantiate()
    state.searchPanel:addChild(state.btnSearch)

    state.btnClearSearch = ISButton:new(0, 0, 80, 24, "Clear", panel, function()
        state.searchEntry:setText("")
        requestSearchRefresh(state)
    end)
    state.btnClearSearch:initialise()
    state.btnClearSearch:instantiate()
    state.searchPanel:addChild(state.btnClearSearch)

    state.searchInfoLabel = ISLabel:new(0, 0, 18, "", 0.7, 0.7, 0.7, 1, UIFont.Small, true)
    state.searchInfoLabel:initialise()
    state.searchInfoLabel:instantiate()
    state.searchPanel:addChild(state.searchInfoLabel)

    state.resultList = ISScrollingListBox:new(0, 0, 100, 100)
    state.resultList:initialise()
    state.resultList:instantiate()
    state.resultList.itemheight = 36
    state.resultList.backgroundColor = { r = 0, g = 0, b = 0, a = 0.45 }
    state.resultList.borderColor = { r = 1, g = 1, b = 1, a = 0.12 }
    state.resultList.drawBorder = true
    state.resultList.doDrawItem = drawResultItem
    state.resultList.onMouseDown = onResultMouseDown
    state.resultList.onmousedown = function(target, item)
        if not target or not target.items then
            return false
        end
        for index, row in ipairs(target.items) do
            if row and row.item == item then
                onResultMouseDown(target, 0, (index - 1) * (target.itemheight or 36))
                return true
            end
        end
        return false
    end
    state.resultList.parentState = state
    state.resultList:setAnchorRight(true)
    state.resultList:setAnchorBottom(true)
    state.resultPanel:addChild(state.resultList)

    state.details = ISRichTextPanel:new(0, 0, 100, 100)
    state.details:initialise()
    state.details.backgroundColor = { r = 0, g = 0, b = 0, a = 0.4 }
    state.details.borderColor = { r = 1, g = 1, b = 1, a = 0.15 }
    state.details.autosetheight = false
    state.details.clip = true
    state.details:setMargins(10, 10, 10, 10)
    state.details:setAnchorRight(true)
    state.details:setAnchorBottom(true)
    state.details:addScrollBars()
    state.detailPanel:addChild(state.details)

    state.statusLabel = ISLabel:new(0, 0, 18, "Pricing editor ready.", 0.75, 0.85, 0.75, 1, UIFont.Small, true)
    state.statusLabel:initialise()
    state.statusLabel:instantiate()
    state.rightPane:addChild(state.statusLabel)

    state.onConfigUpdated = function()
        refreshAll(state)
    end
    state.onActionResult = function(args)
        local message = args and args.message or "Pricing action completed."
        local warnings = args and args.warnings or nil
        if warnings and #warnings > 0 then
            message = message .. " (" .. tostring(#warnings) .. " warnings)"
        end
        setStatus(state, message, not (args and args.success))
        refreshPresetSelector(state)
        refreshAll(state)
    end

    Events.OnDynamicTradingPriceConfigUpdated.Add(state.onConfigUpdated)
    Events.OnDynamicTradingPriceConfigActionResult.Add(state.onActionResult)

    local previousPrerender = panel.prerender
    state.previousPanelPrerender = previousPrerender
    panel.prerender = function(self)
        if previousPrerender then
            previousPrerender(self)
        else
            ISPanel.prerender(self)
        end

        local liveW = self.getWidth and self:getWidth() or self.width or 0
        local liveH = self.getHeight and self:getHeight() or self.height or 0
        if liveW ~= state.lastPanelW or liveH ~= state.lastPanelH then
            state.lastPanelW = liveW
            state.lastPanelH = liveH
            DT_PricingOptionsTab.OnResize(owner)
        end
    end

    owner.pricingState = state
    refreshPresetSelector(state, DT_ConfigManager and DT_ConfigManager.getLastPricePresetName and DT_ConfigManager.getLastPricePresetName() or "default")
    DT_PricingOptionsTab.OnResize(owner)
    DynamicTrading.PriceConfig.RequestSync()
    refreshAll(state)
end

return DT_PricingOptionsTab

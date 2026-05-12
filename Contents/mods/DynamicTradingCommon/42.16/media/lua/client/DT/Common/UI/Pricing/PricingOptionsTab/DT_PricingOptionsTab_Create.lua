local Internal = DT_PricingOptionsTabInternal

local function getKnownPresetNames(state)
    local names = {}
    local seen = {}

    local function add(name)
        local text = Internal.trim(name)
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

    table.sort(names, Internal.sortStrings)
    return names
end

local function refreshPresetSelector(state, preferredName)
    local names
    local desired
    local selectedIndex
    local index
    local name

    if not state or not state.presetCombo then
        return
    end

    names = getKnownPresetNames(state)
    state.presetCombo:clear()
    for _, name in ipairs(names) do
        state.presetCombo:addOption(name)
    end

    desired = Internal.trim(preferredName or (state.presetEntry and state.presetEntry:getText()) or "")
    selectedIndex = 1
    for index, name in ipairs(names) do
        if name == desired then
            selectedIndex = index
            break
        end
    end
    state.presetCombo.selected = selectedIndex
end

local function getSelectedPresetName(state)
    local selected

    if not state or not state.presetCombo then
        return ""
    end

    selected = state.presetCombo.selected or 1
    if state.presetCombo.getOptionText then
        return Internal.trim(state.presetCombo:getOptionText(selected) or "")
    end
    return ""
end

function DT_PricingOptionsTab.Create(owner, panel)
    local state
    local storedCollapsed
    local previousPrerender

    local function newBox(x, y, width, height, alpha)
        local box = ISPanel:new(x, y, width, height)
        box:initialise()
        box:instantiate()
        box.backgroundColor = { r = 0, g = 0, b = 0, a = alpha or 0.18 }
        box.borderColor = { r = 1, g = 1, b = 1, a = 0.12 }
        panel:addChild(box)
        return box
    end

    state = {
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

    storedCollapsed = DT_ConfigManager and DT_ConfigManager.getPriceCollapsedTags and DT_ConfigManager.getPriceCollapsedTags() or {}
    for _, tag in ipairs(storedCollapsed) do
        state.collapsed[tag] = true
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
    state.treeList.doDrawItem = Internal.drawTreeItem
    state.treeList.onMouseDown = Internal.onTreeMouseDown
    state.treeList.onmousedown = function(target, item)
        local index
        local row

        if not target or not target.items then
            return false
        end
        for index, row in ipairs(target.items) do
            if row and row.item == item then
                Internal.onTreeMouseDown(target, 0, (index - 1) * (target.itemheight or 24))
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
        Internal.refreshAll(state)
        Internal.setStatus(state, "Requested latest price config from the server.", false)
    end)
    state.btnRefresh:initialise()
    state.btnRefresh:instantiate()
    state.leftPane:addChild(state.btnRefresh)

    state.btnCollapseAll = ISButton:new(0, 0, 110, 24, "Collapse All", panel, function()
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
        refreshPresetSelector(state, presetName)
    end)
    state.btnApplyPreset:initialise()
    state.btnApplyPreset:instantiate()
    state.headerPanel:addChild(state.btnApplyPreset)

    state.btnRefreshPresets = ISButton:new(0, 0, 78, 24, "Refresh", panel, function()
        refreshPresetSelector(state)
        Internal.setStatus(state, "Saved preset list refreshed.", false)
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
    end)
    state.btnApplyTag:initialise()
    state.btnApplyTag:instantiate()
    state.headerPanel:addChild(state.btnApplyTag)

    state.btnResetTag = ISButton:new(0, 0, 80, 24, "Reset Tag", panel, function()
        if not state.selectedTag then
            Internal.setStatus(state, "Select a tag branch to reset.", true)
            return
        end
        state.multiplierEntry:setText("1.0")
        if not Internal.sendPriceCommand("ApplyPriceTagMultiplier", { tag = state.selectedTag, multiplier = 1.0 }) then
            Internal.setStatus(state, "Unable to send tag reset.", true)
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
    end)
    state.btnApplyItem:initialise()
    state.btnApplyItem:instantiate()
    state.headerPanel:addChild(state.btnApplyItem)

    state.btnResetItem = ISButton:new(0, 0, 80, 24, "Reset Item", panel, function()
        if not state.selectedItemKey then
            Internal.setStatus(state, "Select an item override target first.", true)
            return
        end
        if not Internal.sendPriceCommand("ResetItemBasePriceOverride", { itemKey = state.selectedItemKey }) then
            Internal.setStatus(state, "Unable to send item reset.", true)
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
            Internal.setStatus(state, "Preset exported to " .. tostring(DT_PricePresetIO.getExportPathHint(state.presetEntry:getText())), false)
        else
            Internal.setStatus(state, tostring(result or "Preset export failed."), true)
        end
    end)
    state.btnExport:initialise()
    state.btnExport:instantiate()
    state.headerPanel:addChild(state.btnExport)

    state.btnImport = ISButton:new(0, 0, 75, 24, "Import", panel, function()
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
        refreshPresetSelector(state, payload.name or state.presetEntry:getText())
    end)
    state.btnImport:initialise()
    state.btnImport:instantiate()
    state.headerPanel:addChild(state.btnImport)

    state.btnResetAll = ISButton:new(0, 0, 80, 24, "Reset All", panel, function()
        if not Internal.sendPriceCommand("ResetAllPriceOverrides", {}) then
            Internal.setStatus(state, "Unable to send reset-all command.", true)
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
        Internal.requestSearchRefresh(state)
    end)
    state.btnSearch:initialise()
    state.btnSearch:instantiate()
    state.searchPanel:addChild(state.btnSearch)

    state.btnClearSearch = ISButton:new(0, 0, 80, 24, "Clear", panel, function()
        state.searchEntry:setText("")
        Internal.requestSearchRefresh(state)
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
    state.resultList.doDrawItem = Internal.drawResultItem
    state.resultList.onMouseDown = Internal.onResultMouseDown
    state.resultList.onmousedown = function(target, item)
        local index
        local row

        if not target or not target.items then
            return false
        end
        for index, row in ipairs(target.items) do
            if row and row.item == item then
                Internal.onResultMouseDown(target, 0, (index - 1) * (target.itemheight or 36))
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
        Internal.refreshAll(state)
    end
    state.onActionResult = function(args)
        local message = args and args.message or "Pricing action completed."
        local warnings = args and args.warnings or nil

        if warnings and #warnings > 0 then
            message = message .. " (" .. tostring(#warnings) .. " warnings)"
        end
        Internal.setStatus(state, message, not (args and args.success))
        refreshPresetSelector(state)
        Internal.refreshAll(state)
    end

    Events.OnDynamicTradingPriceConfigUpdated.Add(state.onConfigUpdated)
    Events.OnDynamicTradingPriceConfigActionResult.Add(state.onActionResult)

    previousPrerender = panel.prerender
    state.previousPanelPrerender = previousPrerender
    panel.prerender = function(self)
        local liveW
        local liveH

        if previousPrerender then
            previousPrerender(self)
        else
            ISPanel.prerender(self)
        end

        liveW = self.getWidth and self:getWidth() or self.width or 0
        liveH = self.getHeight and self:getHeight() or self.height or 0
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
    Internal.refreshAll(state)
end

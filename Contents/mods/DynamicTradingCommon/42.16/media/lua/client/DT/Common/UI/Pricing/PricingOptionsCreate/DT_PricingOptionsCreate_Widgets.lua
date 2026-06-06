local Internal = DT_PricingOptionsTabInternal
local CreateInternal = DT_PricingOptionsCreateInternal

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

local function forwardListMouseDown(mouseHandler, defaultItemHeight)
    return function(target, item)
        local index
        local row

        if not target or not target.items then
            return false
        end
        for index, row in ipairs(target.items) do
            if row and row.item == item then
                mouseHandler(target, 0, (index - 1) * (target.itemheight or defaultItemHeight))
                return true
            end
        end
        return false
    end
end

function CreateInternal.BuildWidgets(state)
    local panel = state.panel

    state.leftPane = CreateInternal.NewBox(panel, 0, 0, 100, 100, 0.14)
    state.leftPane:setAnchorLeft(true)
    state.leftPane:setAnchorTop(true)
    state.leftPane:setAnchorBottom(true)

    state.rightPane = CreateInternal.NewBox(panel, 0, 0, 100, 100, 0)
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
    state.treeList.onmousedown = forwardListMouseDown(Internal.onTreeMouseDown, 24)
    state.treeList.parentState = state
    state.treeList:setAnchorRight(true)
    state.treeList:setAnchorBottom(true)
    state.leftPane:addChild(state.treeList)

    state.btnRefresh = ISButton:new(0, 0, 90, 24, T("DTCommon_UI_Pricing_Refresh", nil, "Refresh"), panel, function()
        CreateInternal.OnRefreshPrices(state)
    end)
    state.btnRefresh:initialise()
    state.btnRefresh:instantiate()
    state.leftPane:addChild(state.btnRefresh)

    state.btnCollapseAll = ISButton:new(0, 0, 110, 24, T("DTCommon_UI_Pricing_CollapseAll", nil, "Collapse All"), panel, function()
        CreateInternal.OnCollapseAll(state)
    end)
    state.btnCollapseAll:initialise()
    state.btnCollapseAll:instantiate()
    state.leftPane:addChild(state.btnCollapseAll)

    state.selectedTagLabel = ISLabel:new(0, 0, 18, T("DTCommon_UI_Pricing_SelectedTagNone", nil, "Selected Tag: none"), 1, 1, 1, 1, UIFont.Medium, true)
    state.selectedTagLabel:initialise()
    state.selectedTagLabel:instantiate()
    state.headerPanel:addChild(state.selectedTagLabel)

    state.exportHintLabel = ISLabel:new(0, 0, 18, T("DTCommon_UI_Pricing_PresetExportHint", nil, "Preset exports save to Zomboid/Lua/ as DynamicTrading_PricingPreset_<preset>.txt"), 0.72, 0.72, 0.72, 1, UIFont.Small, true)
    state.exportHintLabel:initialise()
    state.exportHintLabel:instantiate()
    state.headerPanel:addChild(state.exportHintLabel)

    state.presetLibraryLabel = ISLabel:new(0, 0, 18, T("DTCommon_UI_Pricing_SavedPresets", nil, "Saved Presets"), 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    state.presetLibraryLabel:initialise()
    state.presetLibraryLabel:instantiate()
    state.headerPanel:addChild(state.presetLibraryLabel)

    state.presetCombo = ISComboBox:new(0, 0, 140, 24, panel, nil)
    state.presetCombo:initialise()
    state.presetCombo:instantiate()
    state.headerPanel:addChild(state.presetCombo)

    state.btnApplyPreset = ISButton:new(0, 0, 78, 24, T("DTCommon_UI_Pricing_Apply", nil, "Apply"), panel, function()
        CreateInternal.OnApplyPreset(state)
    end)
    state.btnApplyPreset:initialise()
    state.btnApplyPreset:instantiate()
    state.headerPanel:addChild(state.btnApplyPreset)

    state.btnRefreshPresets = ISButton:new(0, 0, 78, 24, T("DTCommon_UI_Pricing_Refresh", nil, "Refresh"), panel, function()
        CreateInternal.OnRefreshPresetList(state)
    end)
    state.btnRefreshPresets:initialise()
    state.btnRefreshPresets:instantiate()
    state.headerPanel:addChild(state.btnRefreshPresets)

    state.multiplierLabel = ISLabel:new(0, 0, 18, T("DTCommon_UI_Pricing_TagMultiplier", nil, "Tag Multiplier"), 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    state.multiplierLabel:initialise()
    state.multiplierLabel:instantiate()
    state.headerPanel:addChild(state.multiplierLabel)

    state.multiplierEntry = ISTextEntryBox:new("1.0", 0, 0, 80, 24)
    state.multiplierEntry:initialise()
    state.multiplierEntry:instantiate()
    state.headerPanel:addChild(state.multiplierEntry)

    state.btnApplyTag = ISButton:new(0, 0, 80, 24, T("DTCommon_UI_Pricing_ApplyTag", nil, "Apply Tag"), panel, function()
        CreateInternal.OnApplyTag(state)
    end)
    state.btnApplyTag:initialise()
    state.btnApplyTag:instantiate()
    state.headerPanel:addChild(state.btnApplyTag)

    state.btnResetTag = ISButton:new(0, 0, 80, 24, T("DTCommon_UI_Pricing_ResetTag", nil, "Reset Tag"), panel, function()
        CreateInternal.OnResetTag(state)
    end)
    state.btnResetTag:initialise()
    state.btnResetTag:instantiate()
    state.headerPanel:addChild(state.btnResetTag)

    state.itemOverrideLabel = ISLabel:new(0, 0, 18, T("DTCommon_UI_Pricing_ItemBasePrice", nil, "Item Base Price"), 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    state.itemOverrideLabel:initialise()
    state.itemOverrideLabel:instantiate()
    state.headerPanel:addChild(state.itemOverrideLabel)

    state.itemOverrideEntry = ISTextEntryBox:new("", 0, 0, 80, 24)
    state.itemOverrideEntry:initialise()
    state.itemOverrideEntry:instantiate()
    state.itemOverrideEntry:setOnlyNumbers(true)
    state.headerPanel:addChild(state.itemOverrideEntry)

    state.btnApplyItem = ISButton:new(0, 0, 80, 24, T("DTCommon_UI_Pricing_ApplyItem", nil, "Apply Item"), panel, function()
        CreateInternal.OnApplyItem(state)
    end)
    state.btnApplyItem:initialise()
    state.btnApplyItem:instantiate()
    state.headerPanel:addChild(state.btnApplyItem)

    state.btnResetItem = ISButton:new(0, 0, 80, 24, T("DTCommon_UI_Pricing_ResetItem", nil, "Reset Item"), panel, function()
        CreateInternal.OnResetItem(state)
    end)
    state.btnResetItem:initialise()
    state.btnResetItem:instantiate()
    state.headerPanel:addChild(state.btnResetItem)

    state.presetLabel = ISLabel:new(0, 0, 18, T("DTCommon_UI_Pricing_PresetName", nil, "Preset Name"), 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    state.presetLabel:initialise()
    state.presetLabel:instantiate()
    state.headerPanel:addChild(state.presetLabel)

    state.presetEntry = ISTextEntryBox:new(DT_ConfigManager and DT_ConfigManager.getLastPricePresetName and DT_ConfigManager.getLastPricePresetName() or "default", 0, 0, 140, 24)
    state.presetEntry:initialise()
    state.presetEntry:instantiate()
    state.headerPanel:addChild(state.presetEntry)

    state.btnExport = ISButton:new(0, 0, 75, 24, T("DTCommon_UI_Pricing_Export", nil, "Export"), panel, function()
        CreateInternal.OnExportPreset(state)
    end)
    state.btnExport:initialise()
    state.btnExport:instantiate()
    state.headerPanel:addChild(state.btnExport)

    state.btnImport = ISButton:new(0, 0, 75, 24, T("DTCommon_UI_Pricing_Import", nil, "Import"), panel, function()
        CreateInternal.OnImportPreset(state)
    end)
    state.btnImport:initialise()
    state.btnImport:instantiate()
    state.headerPanel:addChild(state.btnImport)

    state.btnResetAll = ISButton:new(0, 0, 80, 24, T("DTCommon_UI_Pricing_ResetAll", nil, "Reset All"), panel, function()
        CreateInternal.OnResetAll(state)
    end)
    state.btnResetAll:initialise()
    state.btnResetAll:instantiate()
    state.headerPanel:addChild(state.btnResetAll)

    state.searchLabel = ISLabel:new(0, 0, 18, T("DTCommon_UI_Pricing_BranchItemSearch", nil, "Branch Item Search"), 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    state.searchLabel:initialise()
    state.searchLabel:instantiate()
    state.searchPanel:addChild(state.searchLabel)

    state.searchEntry = ISTextEntryBox:new("", 0, 0, 120, 24)
    state.searchEntry:initialise()
    state.searchEntry:instantiate()
    state.searchPanel:addChild(state.searchEntry)

    state.btnSearch = ISButton:new(0, 0, 80, 24, T("DTCommon_UI_Pricing_Find", nil, "Find"), panel, function()
        CreateInternal.OnSearch(state)
    end)
    state.btnSearch:initialise()
    state.btnSearch:instantiate()
    state.searchPanel:addChild(state.btnSearch)

    state.btnClearSearch = ISButton:new(0, 0, 80, 24, T("DTCommon_UI_Pricing_Clear", nil, "Clear"), panel, function()
        CreateInternal.OnClearSearch(state)
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
    state.resultList.onmousedown = forwardListMouseDown(Internal.onResultMouseDown, 36)
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

    state.statusLabel = ISLabel:new(0, 0, 18, T("DTCommon_UI_Pricing_EditorReady", nil, "Pricing editor ready."), 0.75, 0.85, 0.75, 1, UIFont.Small, true)
    state.statusLabel:initialise()
    state.statusLabel:instantiate()
    state.rightPane:addChild(state.statusLabel)
end

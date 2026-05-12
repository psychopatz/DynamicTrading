local Internal = DT_PricingOptionsTabInternal

function DT_PricingOptionsTab.OnResize(owner)
    local state = owner and owner.pricingState or nil
    local panel
    local pad
    local panelW
    local panelH
    local resizeGripPad
    local footerPad
    local leftW
    local rightX
    local rightW
    local paneH
    local statusH
    local innerPad
    local leftInnerW
    local rightInnerW
    local headerH
    local searchH
    local resultH
    local detailY
    local detailH
    local leftFooterY
    local treeH
    local labelX
    local valueX
    local fieldW
    local buttonW
    local buttonGap
    local rightActionsW

    if not state or not state.panel then
        return
    end

    panel = state.panel
    pad = 10
    panelW = panel.getWidth and panel:getWidth() or panel.width or 0
    panelH = panel.getHeight and panel:getHeight() or panel.height or 0
    resizeGripPad = 18
    footerPad = 18
    leftW = math.max(240, math.min(320, math.floor(panelW * 0.30)))
    rightX = leftW + (pad * 2)
    rightW = math.max(320, panelW - rightX - pad - resizeGripPad)
    paneH = panelH - (pad * 2) - footerPad
    statusH = 20
    innerPad = 10
    leftInnerW = leftW - (innerPad * 2)
    rightInnerW = rightW - (innerPad * 2)
    headerH = 176
    searchH = 70
    resultH = math.max(120, math.floor((paneH - headerH - searchH - statusH - (pad * 4)) * 0.32))
    detailY = headerH + searchH + resultH + (pad * 3)
    detailH = math.max(120, paneH - detailY - statusH - pad)
    leftFooterY = paneH - 34
    treeH = math.max(150, leftFooterY - innerPad - 8)

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
    Internal.relayoutScrollWidget(state.treeList)

    state.btnRefresh:setX(innerPad)
    state.btnRefresh:setY(leftFooterY)
    state.btnCollapseAll:setX(innerPad + 95)
    state.btnCollapseAll:setY(leftFooterY)

    labelX = innerPad
    valueX = 122
    fieldW = 80
    buttonW = 78
    buttonGap = 8
    rightActionsW = (buttonW * 3) + (buttonGap * 2)

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
    Internal.relayoutScrollWidget(state.resultList)

    state.details:setX(6)
    state.details:setY(6)
    state.details:setWidth(rightW - 12)
    state.details:setHeight(detailH - 12)
    Internal.relayoutRichText(state.details)

    state.statusLabel:setX(0)
    state.statusLabel:setY(paneH - statusH - 2)
    if state.statusLabel.setWidth then
        state.statusLabel:setWidth(rightW)
    end

    Internal.refreshSearchResults(state)
    Internal.refreshDetailPanel(state)
end

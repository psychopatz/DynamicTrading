-- ==============================================================================
-- DT_FactionDebugWindow.lua
-- Faction Debug Tool: Main UI Window
-- Dedicated UI for Managing Factions
-- Build 42 Compatible
-- ==============================================================================

require "ISUI/ISCollapsableWindow"
require "DT/Common/UI/Debug/Factions/AdminManager/DT_FactionDebugData"
require "DT/Common/UI/Debug/Factions/AdminManager/DT_FactionDebugRenderers"
require "DT/Common/UI/Debug/Factions/AdminManager/DT_FactionDebugActions"
require "DT/Common/UI/Debug/Factions/BaseLedger/DT_FactionBaseLedgerWindow"
pcall(require, "DT/Common/FactionZones/DT_FactionBaseZones")

DT_FactionDebugWindow = ISCollapsableWindow:derive("DT_FactionDebugWindow")

local CONTENT_PAD = 10
local CONTENT_GAP = 10
local CONTROL_PANEL_HEIGHT = 92
local FOOTER_HEIGHT = 32
local CONTROL_GAP = 8
local CONTENT_TOP_PADDING = 10
local DEFAULT_TITLEBAR_HEIGHT = 35
local SECTION_HEADER_HEIGHT = 18
local SECTION_INNER_PAD = 8
local SMALL_BUTTON_HEIGHT = 20
local NORMAL_BUTTON_HEIGHT = 25
local MIN_CONTENT_HEIGHT = 320

local function getFlowColumns(availableWidth, minWidth, gap)
    if availableWidth <= 0 then
        return 1
    end
    return math.max(1, math.floor((availableWidth + gap) / (minWidth + gap)))
end

local function getFlowHeight(count, availableWidth, minWidth, buttonHeight, gap)
    if count <= 0 then
        return 0
    end
    local columns = getFlowColumns(availableWidth, minWidth, gap)
    local rows = math.ceil(count / columns)
    return (rows * buttonHeight) + (math.max(0, rows - 1) * gap)
end

local function layoutButtonFlow(startX, startY, availableWidth, buttons, minWidth, buttonHeight, gap)
    local columns = getFlowColumns(availableWidth, minWidth, gap)
    local actualWidth = math.floor((availableWidth - ((columns - 1) * gap)) / columns)
    for index, button in ipairs(buttons) do
        local row = math.floor((index - 1) / columns)
        local column = (index - 1) % columns
        button:setX(startX + (column * (actualWidth + gap)))
        button:setY(startY + (row * (buttonHeight + gap)))
        button:setWidth(actualWidth)
        button:setHeight(buttonHeight)
    end
    return startY + getFlowHeight(#buttons, availableWidth, minWidth, buttonHeight, gap)
end

local function setSelectedItemIndex(listbox, item)
    if not listbox or not listbox.items then
        return
    end
    for index, row in ipairs(listbox.items) do
        if row and row.item == item then
            listbox.selected = index
            return
        end
    end
end

local function rowYForIndex(listbox, index)
    local topIndex = tonumber(listbox.topItem or 1) or 1
    local itemHeight = tonumber(listbox.itemheight or 1) or 1
    return (index - topIndex) * itemHeight
end

local function measureTextWidth(font, text)
    return getTextManager():MeasureStringX(font, tostring(text or ""))
end

local function getColumnWidths(totalWidth)
    local contentWidth = totalWidth - (CONTENT_PAD * 2)
    local listWidth = math.max(220, math.min(280, math.floor(contentWidth * 0.25)))
    local detailsWidth = math.max(260, math.min(340, math.floor(contentWidth * 0.31)))
    local rosterWidth = contentWidth - listWidth - detailsWidth - (CONTENT_GAP * 2)

    if rosterWidth < 280 then
        local deficit = 280 - rosterWidth
        local detailsShrink = math.min(deficit, math.max(0, detailsWidth - 240))
        detailsWidth = detailsWidth - detailsShrink
        deficit = deficit - detailsShrink
        if deficit > 0 then
            local listShrink = math.min(deficit, math.max(0, listWidth - 200))
            listWidth = listWidth - listShrink
        end
        rosterWidth = contentWidth - listWidth - detailsWidth - (CONTENT_GAP * 2)
    end

    return contentWidth, listWidth, detailsWidth, rosterWidth
end

local function getControlPanelMetrics(totalWidth)
    local contentWidth = totalWidth - (CONTENT_PAD * 2)
    local controlWidth = math.floor((contentWidth - CONTENT_GAP) / 2)
    local rosterControlWidth = contentWidth - controlWidth - CONTENT_GAP

    local factionInnerW = controlWidth - (CONTROL_GAP * 2)
    local factionTopHeight = getFlowHeight(4, factionInnerW, 110, SMALL_BUTTON_HEIGHT, CONTROL_GAP)
    local factionBottomHeight = getFlowHeight(4, factionInnerW, 150, SMALL_BUTTON_HEIGHT, CONTROL_GAP)
    local factionControlHeight = SECTION_INNER_PAD + SECTION_HEADER_HEIGHT + 6 + factionTopHeight + CONTROL_GAP + factionBottomHeight + SECTION_INNER_PAD

    local rosterInnerW = rosterControlWidth - (CONTROL_GAP * 2)
    local rosterTopHeight = getFlowHeight(3, rosterInnerW, 150, NORMAL_BUTTON_HEIGHT, CONTROL_GAP)
    local stackedRosterBottom = rosterInnerW < 360
    local rosterBottomHeight = stackedRosterBottom and ((NORMAL_BUTTON_HEIGHT * 2) + CONTROL_GAP) or NORMAL_BUTTON_HEIGHT
    local rosterControlHeight = SECTION_INNER_PAD + SECTION_HEADER_HEIGHT + 6 + rosterTopHeight + CONTROL_GAP + rosterBottomHeight + SECTION_INNER_PAD

    return controlWidth, rosterControlWidth, factionInnerW, rosterInnerW, stackedRosterBottom, math.max(factionControlHeight, rosterControlHeight)
end

local function getPreferredWindowHeight(totalWidth, screenHeight)
    local _, _, _, _, _, controlPanelHeight = getControlPanelMetrics(totalWidth)
    local contentTop = DEFAULT_TITLEBAR_HEIGHT + CONTENT_TOP_PADDING
    local preferred = contentTop + MIN_CONTENT_HEIGHT + CONTENT_GAP + controlPanelHeight + CONTENT_GAP + FOOTER_HEIGHT + CONTENT_PAD
    return math.min(preferred, math.max(420, screenHeight - 60))
end

local function relayoutEmbeddedScrollbars(widget)
    if not widget then
        return
    end

    if widget.vscroll then
        local widgetWidth = widget.getWidth and widget:getWidth() or widget.width or 0
        local widgetHeight = widget.getHeight and widget:getHeight() or widget.height or 0
        local vscrollWidth = widget.vscroll.getWidth and widget.vscroll:getWidth() or widget.vscroll.width or 12
        local vscrollHeight = widgetHeight
        if widget.hscroll and (widget.hscroll.isVisible and widget.hscroll:isVisible() or widget.hscroll.visible) then
            local hscrollHeight = widget.hscroll.getHeight and widget.hscroll:getHeight() or widget.hscroll.height or 12
            vscrollHeight = math.max(0, vscrollHeight - hscrollHeight)
        end
        widget.vscroll:setX(math.max(0, widgetWidth - vscrollWidth))
        widget.vscroll:setY(0)
        widget.vscroll:setHeight(vscrollHeight)
        widget.vscroll:bringToTop()
    end

    if widget.hscroll then
        local widgetWidth = widget.getWidth and widget:getWidth() or widget.width or 0
        local widgetHeight = widget.getHeight and widget:getHeight() or widget.height or 0
        local hscrollHeight = widget.hscroll.getHeight and widget.hscroll:getHeight() or widget.hscroll.height or 12
        local hscrollWidth = widgetWidth
        if widget.vscroll and (widget.vscroll.isVisible and widget.vscroll:isVisible() or widget.vscroll.visible) then
            local vscrollWidth = widget.vscroll.getWidth and widget.vscroll:getWidth() or widget.vscroll.width or 12
            hscrollWidth = math.max(0, hscrollWidth - vscrollWidth)
        end
        widget.hscroll:setX(0)
        widget.hscroll:setY(math.max(0, widgetHeight - hscrollHeight))
        widget.hscroll:setWidth(hscrollWidth)
        widget.hscroll:bringToTop()
    end
end

local function refreshRichTextPanel(widget)
    if not widget then
        return
    end

    if widget.onResize then
        pcall(function()
            widget:onResize()
        end)
    end

    if widget.text ~= nil and tostring(widget.text) ~= "" then
        widget:paginate()
    end

    if widget.vscroll then
        widget.vscroll:bringToTop()
    end
    if widget.hscroll then
        widget.hscroll:bringToTop()
    end
end

function DT_FactionDebugWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Faction Management")
    self:setResizable(true)
    self.minimumWidth = 980
    self.minimumHeight = 520
    self:createChildren()
end

function DT_FactionDebugWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    if self._dtChildrenCreated then
        return
    end
    self._dtChildrenCreated = true

    self.factionListPanel = ISPanel:new(0, 0, 100, 100)
    self.factionListPanel:initialise()
    self.factionListPanel.backgroundColor = {r=0.04, g=0.04, b=0.04, a=0.94}
    self.factionListPanel.borderColor = {r=0.24, g=0.24, b=0.24, a=1}
    self:addChild(self.factionListPanel)

    self.detailsPanel = ISPanel:new(0, 0, 100, 100)
    self.detailsPanel:initialise()
    self.detailsPanel.backgroundColor = {r=0.04, g=0.04, b=0.04, a=0.94}
    self.detailsPanel.borderColor = {r=0.24, g=0.24, b=0.24, a=1}
    self:addChild(self.detailsPanel)

    self.rosterListPanel = ISPanel:new(0, 0, 100, 100)
    self.rosterListPanel:initialise()
    self.rosterListPanel.backgroundColor = {r=0.04, g=0.04, b=0.04, a=0.94}
    self.rosterListPanel.borderColor = {r=0.24, g=0.24, b=0.24, a=1}
    self:addChild(self.rosterListPanel)

    self.factionListLabel = ISLabel:new(0, 0, 18, "FACTIONS", 0.92, 0.92, 0.92, 1, UIFont.Small, true)
    self.factionListLabel:initialise()
    self.factionListPanel:addChild(self.factionListLabel)

    self.detailsLabel = ISLabel:new(0, 0, 18, "DETAILS", 0.92, 0.92, 0.92, 1, UIFont.Small, true)
    self.detailsLabel:initialise()
    self.detailsPanel:addChild(self.detailsLabel)

    self.rosterListLabel = ISLabel:new(0, 0, 18, "ROSTER", 0.92, 0.92, 0.92, 1, UIFont.Small, true)
    self.rosterListLabel:initialise()
    self.rosterListPanel:addChild(self.rosterListLabel)

    -- 2. LIST BOX (Left Side)
    self.listbox = ISScrollingListBox:new(0, 0, 100, 100)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.itemheight = 40
    self.listbox.doDrawItem = DT_FactionDebugRenderers.drawFactionItem
    self.listbox.onMouseDown = function(target, x, y)
        local row = target:rowAt(x, y)
        if type(row) ~= "number" or row <= 0 then
            return false
        end

        local entry = target.items and target.items[row] or nil
        if not entry or not entry.item then
            return false
        end

        target.selected = row
        if DT_FactionDebugWindow.instance then
            DT_FactionDebugWindow.instance:onFactionSelected(entry.item)
        end
        return true
    end
    self.listbox.onmousedown = function(target, item)
        if not target or not target.items then
            return false
        end
        for index, row in ipairs(target.items) do
            if row and row.item == item then
                return target:onMouseDown(0, rowYForIndex(target, index) + 1)
            end
        end
        return false
    end
    self.listbox.backgroundColor = {r=0, g=0, b=0, a=0.78}
    self.factionListPanel:addChild(self.listbox)

    -- 3. DETAIL PANEL (Middle)
    self.details = ISRichTextPanel:new(0, 0, 100, 100)
    self.details:initialise()
    self.details.backgroundColor = {r=0, g=0, b=0, a=0.82}
    self.details:addScrollBars()
    self.detailsPanel:addChild(self.details)
    self.details:setText("Select a faction.")

    -- 4. ROSTER LIST (Right Side)
    self.rosterlist = ISScrollingListBox:new(0, 0, 100, 100)
    self.rosterlist:initialise()
    self.rosterlist:instantiate()
    self.rosterlist.itemheight = 45
    self.rosterlist.doDrawItem = DT_FactionDebugRenderers.drawRosterItem
    self.rosterlist.onMouseDown = function(target, x, y)
        local row = target:rowAt(x, y)
        if type(row) ~= "number" or row <= 0 then
            return false
        end

        local entry = target.items and target.items[row] or nil
        if not entry or not entry.item then
            return false
        end

        target.selected = row
        if DT_FactionDebugWindow.instance then
            DT_FactionDebugWindow.instance:onRosterSelected(entry.item)
        end
        return true
    end
    self.rosterlist.onmousedown = function(target, item)
        if not target or not target.items then
            return false
        end
        for index, row in ipairs(target.items) do
            if row and row.item == item then
                return target:onMouseDown(0, rowYForIndex(target, index) + 1)
            end
        end
        return false
    end
    self.rosterlist.backgroundColor = {r=0, g=0, b=0, a=0.78}
    self.rosterListPanel:addChild(self.rosterlist)

    -- 5. CONTROL PANELS
    self.factionControlPanel = ISPanel:new(0, 0, 100, 100)
    self.factionControlPanel:initialise()
    self.factionControlPanel.backgroundColor = {r=0.04, g=0.04, b=0.04, a=0.94}
    self.factionControlPanel.borderColor = {r=0.24, g=0.24, b=0.24, a=1}
    self:addChild(self.factionControlPanel)

    self.rosterControlPanel = ISPanel:new(0, 0, 100, 100)
    self.rosterControlPanel:initialise()
    self.rosterControlPanel.backgroundColor = {r=0.04, g=0.04, b=0.04, a=0.94}
    self.rosterControlPanel.borderColor = {r=0.24, g=0.24, b=0.24, a=1}
    self:addChild(self.rosterControlPanel)

    self.footerPanel = ISPanel:new(0, 0, 100, FOOTER_HEIGHT)
    self.footerPanel:initialise()
    self.footerPanel.backgroundColor = {r=0.03, g=0.03, b=0.03, a=0.96}
    self.footerPanel.borderColor = {r=0.2, g=0.2, b=0.2, a=1}
    self:addChild(self.footerPanel)

    self.factionActionsLabel = ISLabel:new(0, 0, 18, "FACTION ACTIONS", 0.92, 0.92, 0.92, 1, UIFont.Small, true)
    self.factionActionsLabel:initialise()
    self.factionControlPanel:addChild(self.factionActionsLabel)

    self.rosterActionsLabel = ISLabel:new(0, 0, 18, "ROSTER ACTIONS", 0.92, 0.92, 0.92, 1, UIFont.Small, true)
    self.rosterActionsLabel:initialise()
    self.rosterControlPanel:addChild(self.rosterActionsLabel)

    -- 6. FOOTER BUTTONS
    self.btnRefresh = ISButton:new(0, 0, 120, 25, "REFRESH", self, DT_FactionDebugWindow.onRefreshClick)
    self.btnRefresh:initialise()
    self.btnRefresh.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1}
    self.footerPanel:addChild(self.btnRefresh)

    self.btnSim = ISButton:new(0, 0, 120, 25, "SIMULATE DAY", self, function()
        DT_FactionDebugActions.simulateDay()
    end)
    self.btnSim:initialise()
    self.btnSim.backgroundColor = {r=0.2, g=0.2, b=0.5, a=1}
    self.footerPanel:addChild(self.btnSim)

    self.btnWipe = ISButton:new(0, 0, 120, 25, "WIPE ALL", self, function()
        DT_FactionDebugActions.wipeFactions()
    end)
    self.btnWipe:initialise()
    self.btnWipe.backgroundColor = {r=0.5, g=0.2, b=0.2, a=1}
    self.footerPanel:addChild(self.btnWipe)

    self.btnClose = ISButton:new(0, 0, 120, 25, "CLOSE", self, DT_FactionDebugWindow.close)
    self.btnClose:initialise()
    self.footerPanel:addChild(self.btnClose)

    self.btnDebugHub = ISButton:new(0, 0, 140, 25, "DEBUG HUB", self, DT_FactionDebugWindow.onDebugHubClick)
    self.btnDebugHub:initialise()
    self.btnDebugHub.backgroundColor = {r=0.28, g=0.18, b=0.46, a=1}
    self.footerPanel:addChild(self.btnDebugHub)


    -- 7. SELECTED FACTION CONTROLS
    self.btnWealthAdd = ISButton:new(0, 0, 100, 20, "+ COLONY$", self, function()
        local f = self.listbox.items[self.listbox.selected]
        if f then
            DT_FactionDebugActions.modifyWealth(f.item.id, 1000)
        end
    end)
    self.btnWealthAdd:initialise()
    self.factionControlPanel:addChild(self.btnWealthAdd)

    self.btnWealthSub = ISButton:new(0, 0, 100, 20, "- COLONY$", self, function()
        local f = self.listbox.items[self.listbox.selected]
        if f then
            DT_FactionDebugActions.modifyWealth(f.item.id, -1000)
        end
    end)
    self.btnWealthSub:initialise()
    self.factionControlPanel:addChild(self.btnWealthSub)

    self.btnRepAdd = ISButton:new(0, 0, 100, 20, "+ REP", self, function()
        local f = self.listbox.items[self.listbox.selected]
        if f then
            if self.selectedMemberUUID then
                DT_FactionDebugActions.modifyPersonalReputation(self.selectedMemberUUID, f.item.id, 10)
            else
                DT_FactionDebugActions.modifyFactionBias(f.item.id, 10)
            end
        end
    end)
    self.btnRepAdd:initialise()
    self.factionControlPanel:addChild(self.btnRepAdd)

    self.btnRepSub = ISButton:new(0, 0, 100, 20, "- REP", self, function()
        local f = self.listbox.items[self.listbox.selected]
        if f then
            if self.selectedMemberUUID then
                DT_FactionDebugActions.modifyPersonalReputation(self.selectedMemberUUID, f.item.id, -10)
            else
                DT_FactionDebugActions.modifyFactionBias(f.item.id, -10)
            end
        end
    end)
    self.btnRepSub:initialise()
    self.factionControlPanel:addChild(self.btnRepSub)

    self.btnForceEvent = ISButton:new(0, 0, 100, 20, "FORCE EVENT", self, DT_FactionDebugWindow.onForceEventClick)
    self.btnForceEvent:initialise()
    self.btnForceEvent.backgroundColor = {r=0.7, g=0.5, b=0, a=1}
    self.factionControlPanel:addChild(self.btnForceEvent)

    self.btnMerchant = ISButton:new(0, 0, 100, 20, "MERCHANTS", self, function()
        if DT_MerchantDebugWindow and DT_MerchantDebugWindow.Open then
            DT_MerchantDebugWindow.Open()
        end
    end)
    self.btnMerchant:initialise()
    self.btnMerchant.backgroundColor = {r=0, g=0.5, b=0.5, a=1}
    self.factionControlPanel:addChild(self.btnMerchant)

    self.btnBaseOverlay = ISButton:new(0, 0, 100, 20, "BASE OVERLAY: OFF", self, DT_FactionDebugWindow.onBaseOverlayClick)
    self.btnBaseOverlay:initialise()
    self.btnBaseOverlay.backgroundColor = {r=0.18, g=0.30, b=0.36, a=1}
    self.factionControlPanel:addChild(self.btnBaseOverlay)

    self.btnBaseLedger = ISButton:new(0, 0, 100, 20, "BASE LEDGER", self, DT_FactionDebugWindow.onBaseLedgerClick)
    self.btnBaseLedger:initialise()
    self.btnBaseLedger.backgroundColor = {r=0.36, g=0.26, b=0.12, a=1}
    self.factionControlPanel:addChild(self.btnBaseLedger)

    -- 8. ROSTER ACTIONS
    self.btnLocate = ISButton:new(0, 0, 150, 25, "LOCATE NPC", self, DT_FactionDebugWindow.onLocateClick)
    self.btnLocate:initialise()
    self.btnLocate.backgroundColor = {r=0.2, g=0.2, b=0.7, a=1}
    self.btnLocate.enable = false
    self.rosterControlPanel:addChild(self.btnLocate)

    self.btnForceTrade = ISButton:new(0, 0, 150, 25, "FORCE TRADE", self, DT_FactionDebugWindow.onForceTradeClick)
    self.btnForceTrade:initialise()
    self.btnForceTrade.backgroundColor = {r=0.7, g=0.2, b=0.2, a=1}
    self.btnForceTrade.enable = false
    self.rosterControlPanel:addChild(self.btnForceTrade)

    self.btnGrantContact = ISButton:new(0, 0, 170, 25, "ADD CONTACT +100 REP", self, DT_FactionDebugWindow.onGrantContactClick)
    self.btnGrantContact:initialise()
    self.btnGrantContact.backgroundColor = {r=0.22, g=0.42, b=0.18, a=1}
    self.btnGrantContact.enable = false
    self.rosterControlPanel:addChild(self.btnGrantContact)

    self.archCombo = ISComboBox:new(0, 0, 220, 25, self, nil)
    self.archCombo:initialise()
    self.archCombo:instantiate()
    self.rosterControlPanel:addChild(self.archCombo)

    self.btnSpawnTrader = ISButton:new(0, 0, 170, 25, "SPAWN TRADER", self, DT_FactionDebugWindow.onSpawnTraderClick)
    self.btnSpawnTrader:initialise()
    self.btnSpawnTrader.backgroundColor = {r=0.5, g=0.35, b=0.1, a=1}
    self.rosterControlPanel:addChild(self.btnSpawnTrader)

    self:refreshList()
    self:refreshArchetypeOptions()
    self:layoutChildren()

    if self.resizeWidget then
        self.resizeWidget:bringToTop()
        self.resizeWidget:setVisible(true)
    end
end

function DT_FactionDebugWindow:onResize()
    ISCollapsableWindow.onResize(self)
    self:layoutChildren()
end

function DT_FactionDebugWindow:layoutChildren()
    local contentTop = self:titleBarHeight() + CONTENT_TOP_PADDING
    local contentWidth, listWidth, detailsWidth, rosterWidth = getColumnWidths(self.width)

    local listX = CONTENT_PAD
    local detailsX = listX + listWidth + CONTENT_GAP
    local rosterX = detailsX + detailsWidth + CONTENT_GAP

    local controlWidth, rosterControlWidth, factionInnerW, rosterInnerW, stackedRosterBottom, controlPanelHeight = getControlPanelMetrics(self.width)
    local footerY = self.height - CONTENT_PAD - FOOTER_HEIGHT
    local controlY = footerY - CONTENT_GAP - controlPanelHeight
    local contentHeight = controlY - contentTop - CONTENT_GAP

    self.factionListPanel:setX(listX)
    self.factionListPanel:setY(contentTop)
    self.factionListPanel:setWidth(listWidth)
    self.factionListPanel:setHeight(contentHeight)

    self.detailsPanel:setX(detailsX)
    self.detailsPanel:setY(contentTop)
    self.detailsPanel:setWidth(detailsWidth)
    self.detailsPanel:setHeight(contentHeight)

    self.rosterListPanel:setX(rosterX)
    self.rosterListPanel:setY(contentTop)
    self.rosterListPanel:setWidth(rosterWidth)
    self.rosterListPanel:setHeight(contentHeight)

    local sectionContentY = SECTION_INNER_PAD + SECTION_HEADER_HEIGHT + 4
    local sectionContentHeight = math.max(60, contentHeight - sectionContentY - SECTION_INNER_PAD)

    self.factionListLabel:setX(SECTION_INNER_PAD)
    self.factionListLabel:setY(SECTION_INNER_PAD)
    self.listbox:setX(SECTION_INNER_PAD)
    self.listbox:setY(sectionContentY)
    self.listbox:setWidth(listWidth - (SECTION_INNER_PAD * 2))
    self.listbox:setHeight(sectionContentHeight)
    relayoutEmbeddedScrollbars(self.listbox)

    self.detailsLabel:setX(SECTION_INNER_PAD)
    self.detailsLabel:setY(SECTION_INNER_PAD)
    self.details:setX(SECTION_INNER_PAD)
    self.details:setY(sectionContentY)
    self.details:setWidth(detailsWidth - (SECTION_INNER_PAD * 2))
    self.details:setHeight(sectionContentHeight)
    refreshRichTextPanel(self.details)

    self.rosterListLabel:setX(SECTION_INNER_PAD)
    self.rosterListLabel:setY(SECTION_INNER_PAD)
    self.rosterlist:setX(SECTION_INNER_PAD)
    self.rosterlist:setY(sectionContentY)
    self.rosterlist:setWidth(rosterWidth - (SECTION_INNER_PAD * 2))
    self.rosterlist:setHeight(sectionContentHeight)
    relayoutEmbeddedScrollbars(self.rosterlist)

    self.factionControlPanel:setX(CONTENT_PAD)
    self.factionControlPanel:setY(controlY)
    self.factionControlPanel:setWidth(controlWidth)
    self.factionControlPanel:setHeight(controlPanelHeight)

    self.rosterControlPanel:setX(CONTENT_PAD + controlWidth + CONTENT_GAP)
    self.rosterControlPanel:setY(controlY)
    self.rosterControlPanel:setWidth(rosterControlWidth)
    self.rosterControlPanel:setHeight(controlPanelHeight)

    self.footerPanel:setX(CONTENT_PAD)
    self.footerPanel:setY(footerY)
    self.footerPanel:setWidth(contentWidth)
    self.footerPanel:setHeight(FOOTER_HEIGHT)

    self.factionActionsLabel:setX(CONTROL_GAP)
    self.factionActionsLabel:setY(SECTION_INNER_PAD)
    local factionActionsY = SECTION_INNER_PAD + SECTION_HEADER_HEIGHT + 6
    factionActionsY = layoutButtonFlow(CONTROL_GAP, factionActionsY, factionInnerW, {
        self.btnWealthAdd,
        self.btnWealthSub,
        self.btnRepAdd,
        self.btnRepSub,
    }, 110, SMALL_BUTTON_HEIGHT, CONTROL_GAP)
    factionActionsY = factionActionsY + CONTROL_GAP
    layoutButtonFlow(CONTROL_GAP, factionActionsY, factionInnerW, {
        self.btnForceEvent,
        self.btnMerchant,
        self.btnBaseOverlay,
        self.btnBaseLedger,
    }, 150, SMALL_BUTTON_HEIGHT, CONTROL_GAP)

    self.rosterActionsLabel:setX(CONTROL_GAP)
    self.rosterActionsLabel:setY(SECTION_INNER_PAD)
    local rosterActionsY = SECTION_INNER_PAD + SECTION_HEADER_HEIGHT + 6
    rosterActionsY = layoutButtonFlow(CONTROL_GAP, rosterActionsY, rosterInnerW, {
        self.btnLocate,
        self.btnForceTrade,
        self.btnGrantContact,
    }, 150, NORMAL_BUTTON_HEIGHT, CONTROL_GAP)
    rosterActionsY = rosterActionsY + CONTROL_GAP

    if stackedRosterBottom then
        self.archCombo:setX(CONTROL_GAP)
        self.archCombo:setY(rosterActionsY)
        self.archCombo:setWidth(rosterInnerW)
        self.archCombo:setHeight(NORMAL_BUTTON_HEIGHT)
        self.btnSpawnTrader:setX(CONTROL_GAP)
        self.btnSpawnTrader:setY(rosterActionsY + NORMAL_BUTTON_HEIGHT + CONTROL_GAP)
        self.btnSpawnTrader:setWidth(rosterInnerW)
        self.btnSpawnTrader:setHeight(NORMAL_BUTTON_HEIGHT)
    else
        local spawnWidth = math.max(150, math.min(190, math.floor(rosterInnerW * 0.36)))
        local comboWidth = rosterInnerW - spawnWidth - CONTROL_GAP
        self.archCombo:setX(CONTROL_GAP)
        self.archCombo:setY(rosterActionsY)
        self.archCombo:setWidth(comboWidth)
        self.archCombo:setHeight(NORMAL_BUTTON_HEIGHT)
        self.btnSpawnTrader:setX(CONTROL_GAP + comboWidth + CONTROL_GAP)
        self.btnSpawnTrader:setY(rosterActionsY)
        self.btnSpawnTrader:setWidth(spawnWidth)
        self.btnSpawnTrader:setHeight(NORMAL_BUTTON_HEIGHT)
    end

    local footerButtons = { self.btnRefresh, self.btnSim, self.btnWipe, self.btnDebugHub, self.btnClose }
    local footerInnerW = self.footerPanel:getWidth() - (CONTROL_GAP * 2)
    local footerYInner = math.floor((self.footerPanel:getHeight() - NORMAL_BUTTON_HEIGHT) / 2)
    layoutButtonFlow(CONTROL_GAP, footerYInner, footerInnerW, footerButtons, 120, NORMAL_BUTTON_HEIGHT, 10)

    if self.details.text ~= nil and tostring(self.details.text) ~= "" then
        self.details:paginate()
        refreshRichTextPanel(self.details)
    end
end

function DT_FactionDebugWindow:updateBaseOverlayButton()
    if not self.btnBaseOverlay then
        return
    end

    local enabled = self.baseOverlayEnabled == true and self.selectedFaction ~= nil
    self.btnBaseOverlay:setTitle(enabled and "BASE OVERLAY: ON" or "BASE OVERLAY: OFF")
    if enabled then
        self.btnBaseOverlay.backgroundColor = {r=0.12, g=0.42, b=0.32, a=1}
    else
        self.btnBaseOverlay.backgroundColor = {r=0.18, g=0.30, b=0.36, a=1}
    end
end

local function getOverlayPlayer()
    local player = getSpecificPlayer and getSpecificPlayer(0) or nil
    if not player and getPlayer then
        player = getPlayer()
    end
    return player
end

local function highlightZoneRect(player, row)
    if not player or not addAreaHighlightForPlayer then
        return
    end

    local rect = row and row.rect or nil
    if type(rect) ~= "table" then
        return
    end

    local color = row.color or {}
    local x1 = tonumber(rect[1])
    local y1 = tonumber(rect[2])
    local x2 = tonumber(rect[3])
    local y2 = tonumber(rect[4])
    if x1 == nil or y1 == nil or x2 == nil or y2 == nil then
        return
    end

    addAreaHighlightForPlayer(
        player:getPlayerNum(),
        math.floor(math.min(x1, x2)),
        math.floor(math.min(y1, y2)),
        math.floor(math.max(x1, x2)),
        math.floor(math.max(y1, y2)),
        math.floor(tonumber(rect[5]) or 0),
        tonumber(color.r) or 1,
        tonumber(color.g) or 1,
        tonumber(color.b) or 1,
        tonumber(color.a) or 0.35
    )
end

function DT_FactionDebugWindow:renderBaseWorldOverlay()
    if self.baseOverlayEnabled ~= true or not self.selectedFaction then
        return
    end

    local zoneAPI = DynamicTrading and DynamicTrading.FactionBaseZones or nil
    local rows = zoneAPI and zoneAPI.GetDebugRows and zoneAPI.GetDebugRows(self.selectedFaction) or nil
    if type(rows) ~= "table" or #rows <= 0 then
        return
    end

    local player = getOverlayPlayer()
    for _, row in ipairs(rows) do
        highlightZoneRect(player, row)
    end
end

function DT_FactionDebugWindow:prerender()
    ISCollapsableWindow.prerender(self)
    self:renderBaseWorldOverlay()
end

-- ==========================================================
-- DATA MANAGEMENT
-- ==========================================================
function DT_FactionDebugWindow:refreshList()
    DT_FactionDebugData.refreshFactionList(function(factionData, rosterData)
        if DT_FactionDebugWindow.instance and DT_FactionDebugWindow.instance:getIsVisible() then
            DT_FactionDebugWindow.instance:populateList(factionData)
            -- Cache roster data for later use
            if rosterData then
                DT_FactionDebugData.cachedRosterData = rosterData
            end
        end
    end)
end

function DT_FactionDebugWindow:populateList(factionData)
    if not factionData then return end
    self.listbox:clear()
    self.selectedFaction = nil
    self:updateBaseOverlayButton()
    
    local sorted = DT_FactionDebugData.getSortedFactionList(factionData)
    for _, entry in ipairs(sorted) do
        self.listbox:addItem(entry.data.name or entry.id, entry.data)
    end

    self:refreshArchetypeOptions()
end

function DT_FactionDebugWindow:refreshArchetypeOptions()
    if not self.archCombo then
        return
    end

    local previousText = self.archCombo.selected and self.archCombo:getOptionText(self.archCombo.selected) or nil
    self.archCombo:clear()
    self.availableArchetypes = {}

    local archetypeIDs = {}
    for id, _ in pairs(DynamicTrading.Archetypes or {}) do
        table.insert(archetypeIDs, id)
    end
    table.sort(archetypeIDs)

    local selectedIndex = 1
    for index, archetypeID in ipairs(archetypeIDs) do
        self.archCombo:addOption(archetypeID)
        self.availableArchetypes[index] = archetypeID
        if previousText == archetypeID then
            selectedIndex = index
        end
    end

    self.archCombo.selected = #self.availableArchetypes > 0 and selectedIndex or 0
    if self.btnSpawnTrader then
        self.btnSpawnTrader.enable = #self.availableArchetypes > 0
    end
end

function DT_FactionDebugWindow:getSelectedArchetypeID()
    local selected = self.archCombo and self.archCombo.selected or 0
    return self.availableArchetypes and self.availableArchetypes[selected] or nil
end

-- ==========================================================
-- SELECTION HANDLERS
-- ==========================================================
function DT_FactionDebugWindow:onFactionSelected(item)
    local faction = item
    self.selectedFaction = faction
    self:updateBaseOverlayButton()
    
    -- Update details panel
    local text = DT_FactionDebugData.formatFactionDetails(faction)
    self.details:setText(text)
    refreshRichTextPanel(self.details)

    -- Repopulate Roster List
    self.rosterlist:clear()
    self.selectedMemberUUID = nil
    self.selectedMemberSoul = nil
    self.btnLocate.enable = false
    self.btnForceTrade.enable = false
    self.btnGrantContact.enable = false
    
    -- Use cached roster data
    local rosterData = DT_FactionDebugData.cachedRosterData
    if (not (isClient() and not isServer())) and not rosterData then
        rosterData = ModData.get("DynamicTrading_Roster")
    end
    
    if rosterData then
        local roster = DT_FactionDebugData.getRosterForFaction(faction.id, rosterData)
        for _, entry in ipairs(roster) do
            self.rosterlist:addItem(entry.soul.name or entry.uuid, entry)
        end
    end

    -- Request detailed roster in multiplayer (if not from sync)
    if isClient() and not isServer() then
        DT_FactionDebugData.refreshRosterForFaction(faction.id, function(rosterData, factionID)
            -- Refresh roster list with new data
            if DT_FactionDebugWindow.instance and DT_FactionDebugWindow.instance.listbox.selected then
                local selected = DT_FactionDebugWindow.instance.listbox.items[DT_FactionDebugWindow.instance.listbox.selected]
                if selected and selected.item.id == factionID then
                    DT_FactionDebugWindow.instance:onFactionSelected(selected.item)
                end
            end
        end, 0, DT_FactionDebugData.ROSTER_PAGE_LIMIT or 40)
    end
end

function DT_FactionDebugWindow:onRosterSelected(item)
    self.selectedMemberUUID = item.uuid
    self.selectedMemberSoul = item.soul
    self.btnLocate.enable = true
    self.btnForceTrade.enable = true
    self.btnGrantContact.enable = true
end

-- ==========================================================
-- BUTTON HANDLERS
-- ==========================================================
function DT_FactionDebugWindow:onRefreshClick()
    self:refreshList()
end

function DT_FactionDebugWindow:onLocateClick()
    local item = self.rosterlist.items[self.rosterlist.selected]
    if item and item.item then
        DT_FactionDebugActions.locateNPC(item.item.uuid, item.item.soul)
    end
end

function DT_FactionDebugWindow:onForceTradeClick()
    local item = self.rosterlist.items[self.rosterlist.selected]
    if item and item.item then
        DT_FactionDebugActions.forceTradeMission(item.item.uuid, item.item.soul)
    end
end

function DT_FactionDebugWindow:onGrantContactClick()
    local factionItem = self.listbox.items[self.listbox.selected]
    local rosterItem = self.rosterlist.items[self.rosterlist.selected]
    if factionItem and rosterItem and rosterItem.item then
        DT_FactionDebugActions.grantContactTestAccess(rosterItem.item.uuid, rosterItem.item.soul, factionItem.item.id)
    end
end

function DT_FactionDebugWindow:onDebugHubClick()
    local ok = pcall(require, "DT/Common/UI/Debug/DT_CentralDebugHubWindow")
    if ok and DT_CentralDebugHubWindow and DT_CentralDebugHubWindow.Open then
        DT_CentralDebugHubWindow.Open()
    end
end

function DT_FactionDebugWindow:onForceEventClick()
    local f = self.listbox.items[self.listbox.selected]
    if f then
        DT_FactionDebugActions.showEventSelection(f.item.id, getMouseX(), getMouseY())
    end
end

function DT_FactionDebugWindow:onBaseOverlayClick()
    self.baseOverlayEnabled = self.baseOverlayEnabled ~= true
    self:updateBaseOverlayButton()
end

function DT_FactionDebugWindow:onBaseLedgerClick()
    if DT_FactionBaseLedgerWindow and DT_FactionBaseLedgerWindow.Open then
        DT_FactionBaseLedgerWindow.Open()
    end
end

function DT_FactionDebugWindow:onSpawnTraderClick()
    local archetypeID = self:getSelectedArchetypeID()
    if not archetypeID then
        return
    end

    DT_FactionDebugActions.forceTraderByArchetype(archetypeID)
end

-- ==========================================================
-- REACTIVE REFRESH (Multiplayer)
-- ==========================================================
if not DT_FactionDebugWindow.EventsAdded then
    Events.OnReceiveGlobalModData.Add(function(key, data)
        if (key == "DynamicTrading_Factions" or key == "DynamicTrading_Roster") and DT_FactionDebugWindow.instance then
            if DT_FactionDebugWindow.instance:getIsVisible() then
                DT_FactionDebugWindow.instance:refreshList()
            end
        end
    end)
    DT_FactionDebugWindow.EventsAdded = true
end

-- ==========================================================
-- SINGLETON ACCESS
-- ==========================================================
function DT_FactionDebugWindow.Open()
    if DT_FactionDebugWindow.instance then
        DT_FactionDebugWindow.instance:setVisible(true)
        DT_FactionDebugWindow.instance:addToUIManager()
        DT_FactionDebugWindow.instance:bringToTop()
        DT_FactionDebugWindow.instance:layoutChildren()
        DT_FactionDebugWindow.instance:refreshList()
        return
    end

    local core = getCore()
    local width = math.min(1180, core:getScreenWidth() - 40)
    local height = getPreferredWindowHeight(width, core:getScreenHeight())
    local x = math.floor((core:getScreenWidth() - width) / 2)
    local y = math.floor((core:getScreenHeight() - height) / 2)
    local window = DT_FactionDebugWindow:new(x, y, width, height)
    window:initialise()
    window:addToUIManager()
    DT_FactionDebugWindow.instance = window
    window:refreshList()
end

function DT_FactionDebugWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0.02, g=0.02, b=0.02, a=0.96}
    o.borderColor = {r=1, g=1, b=1, a=1}
    o.moveWithMouse = true
    o.resizable = true
    o.baseOverlayEnabled = false
    return o
end

function DT_FactionDebugWindow:close()
    self.baseOverlayEnabled = false
    self:updateBaseOverlayButton()
    self:setVisible(false)
    self:removeFromUIManager()
    DT_FactionDebugWindow.instance = nil
end

DynamicTrading.Log("DTCommons", "Debug", "UI", "Faction Debug Window Loaded")

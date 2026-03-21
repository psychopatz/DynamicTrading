DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

local function getLayoutMetrics(window)
    local th = window:titleBarHeight()
    local pad = 12
    local gap = 12
    local controlWidth = 88
    local headerTextH = 34
    local tabH = 22
    local tabGap = 6
    local searchH = 24
    local detailH = math.max(120, math.min(184, math.floor(window.height * 0.24)))

    local headerY = th + pad
    local tabsY = headerY + headerTextH
    local searchY = tabsY + tabH + 6
    local contentY = searchY + searchH + 10
    local footerY = window.height - pad - detailH
    local listH = math.max(180, footerY - contentY - 10)
    local listAreaWidth = window.width - (pad * 2) - controlWidth - (gap * 2)
    local leftWidth = math.floor(listAreaWidth / 2)
    local rightWidth = listAreaWidth - leftWidth
    local leftX = pad
    local controlX = leftX + leftWidth + gap
    local rightX = controlX + controlWidth + gap
    local centerButtonsY = contentY + math.floor(math.max(0, listH - 108) / 2)
    local detailY = contentY + listH + 10

    return {
        pad = pad,
        gap = gap,
        headerY = headerY,
        tabsY = tabsY,
        searchY = searchY,
        contentY = contentY,
        detailY = detailY,
        leftX = leftX,
        leftWidth = leftWidth,
        rightX = rightX,
        rightWidth = rightWidth,
        controlX = controlX,
        controlWidth = controlWidth,
        tabH = tabH,
        tabGap = tabGap,
        searchH = searchH,
        detailH = detailH,
        listH = listH,
        centerButtonsY = centerButtonsY,
    }
end

function DT_SupplyWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 920
    self.minimumHeight = 560
end

function DT_SupplyWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    local layout = getLayoutMetrics(self)

    self.playerSearch = ISTextEntryBox:new("", layout.leftX, layout.searchY, layout.leftWidth, layout.searchH)
    self.playerSearch:initialise()
    self:addChild(self.playerSearch)

    self.workerSearch = ISTextEntryBox:new("", layout.rightX, layout.searchY, layout.rightWidth, layout.searchH)
    self.workerSearch:initialise()
    self:addChild(self.workerSearch)

    self.btnTabProvisions = ISButton:new(layout.rightX, layout.tabsY, 80, layout.tabH, "Provisions", self, self.onSelectProvisionsTab)
    self.btnTabProvisions:initialise()
    self:addChild(self.btnTabProvisions)

    self.btnTabOutput = ISButton:new(layout.rightX, layout.tabsY, 80, layout.tabH, "Merchandise", self, self.onSelectOutputTab)
    self.btnTabOutput:initialise()
    self:addChild(self.btnTabOutput)

    self.btnTabEquipment = ISButton:new(layout.rightX, layout.tabsY, 80, layout.tabH, "Equipment", self, self.onSelectEquipmentTab)
    self.btnTabEquipment:initialise()
    self:addChild(self.btnTabEquipment)

    self.btnRefresh = ISButton:new(layout.controlX, layout.searchY, layout.controlWidth, layout.searchH, "Sync", self, self.onRefresh)
    self.btnRefresh:initialise()
    self:addChild(self.btnRefresh)

    self.btnDepositSelected = ISButton:new(layout.controlX, layout.centerButtonsY, layout.controlWidth, 32, ">", self, self.onDepositSelected)
    self.btnDepositSelected:initialise()
    self:addChild(self.btnDepositSelected)

    self.btnDepositVisible = ISButton:new(layout.controlX, layout.centerButtonsY + 40, layout.controlWidth, 32, ">>", self, self.onDepositVisible)
    self.btnDepositVisible:initialise()
    self:addChild(self.btnDepositVisible)

    self.playerList = Internal.LabourSupplyList:new(layout.leftX, layout.contentY, layout.leftWidth, layout.listH, "player")
    self.playerList:initialise()
    self.playerList:instantiate()
    self.playerList.target = self
    self.playerList.onmousedown = DT_SupplyWindow.onPlayerListMouseDown
    self.playerList.drawBorder = true
    self:addChild(self.playerList)

    self.workerList = Internal.LabourSupplyList:new(layout.rightX, layout.contentY, layout.rightWidth, layout.listH, "worker")
    self.workerList:initialise()
    self.workerList:instantiate()
    self.workerList.target = self
    self.workerList.onmousedown = DT_SupplyWindow.onWorkerListMouseDown
    self.workerList.drawBorder = true
    self:addChild(self.workerList)

    self.detailText = ISRichTextPanel:new(layout.pad, layout.detailY, self.width - (layout.pad * 2), layout.detailH)
    self.detailText:initialise()
    self.detailText.backgroundColor = { r = 0, g = 0, b = 0, a = 0.26 }
    self.detailText.borderColor = { r = 1, g = 1, b = 1, a = 0.12 }
    self.detailText:addScrollBars()
    self:addChild(self.detailText)

    self:relayout()
    self:refreshTabButtons()
    self:updateTransferControls()
    self:updateItemDetail(nil, nil)
end

function DT_SupplyWindow:refreshTabButtons()
    if not self.btnTabProvisions then
        return
    end

    local outputTitle = Internal.getOutputTabLabel(self.workerData)
    self.btnTabProvisions:setTitle("Provisions")
    self.btnTabOutput:setTitle(outputTitle)
    self.btnTabEquipment:setTitle("Equipment")

    local buttonEntries = {
        { id = Internal.Tabs.Provisions, button = self.btnTabProvisions },
        { id = Internal.Tabs.Output, button = self.btnTabOutput },
        { id = Internal.Tabs.Equipment, button = self.btnTabEquipment },
    }

    for _, entry in ipairs(buttonEntries) do
        local isActive = (self.activeTab or Internal.Tabs.Provisions) == entry.id
        entry.button.backgroundColor = isActive
            and { r = 0.18, g = 0.28, b = 0.46, a = 0.9 }
            or { r = 0.08, g = 0.08, b = 0.08, a = 0.75 }
        entry.button.borderColor = isActive
            and { r = 1, g = 1, b = 1, a = 0.3 }
            or { r = 1, g = 1, b = 1, a = 0.1 }
    end
end

function DT_SupplyWindow:onSelectProvisionsTab()
    self:setActiveTab(Internal.Tabs.Provisions)
end

function DT_SupplyWindow:onSelectOutputTab()
    self:setActiveTab(Internal.Tabs.Output)
end

function DT_SupplyWindow:onSelectEquipmentTab()
    self:setActiveTab(Internal.Tabs.Equipment)
end

function DT_SupplyWindow:relayout()
    local layout = getLayoutMetrics(self)
    self.layout = layout

    self.playerSearch:setX(layout.leftX)
    self.playerSearch:setY(layout.searchY)
    self.playerSearch:setWidth(layout.leftWidth)
    self.playerSearch:setHeight(layout.searchH)

    self.workerSearch:setX(layout.rightX)
    self.workerSearch:setY(layout.searchY)
    self.workerSearch:setWidth(layout.rightWidth)
    self.workerSearch:setHeight(layout.searchH)

    local tabWidth = math.floor((layout.rightWidth - (layout.tabGap * 2)) / 3)
    self.btnTabProvisions:setX(layout.rightX)
    self.btnTabProvisions:setY(layout.tabsY)
    self.btnTabProvisions:setWidth(tabWidth)
    self.btnTabProvisions:setHeight(layout.tabH)

    self.btnTabOutput:setX(layout.rightX + tabWidth + layout.tabGap)
    self.btnTabOutput:setY(layout.tabsY)
    self.btnTabOutput:setWidth(tabWidth)
    self.btnTabOutput:setHeight(layout.tabH)

    self.btnTabEquipment:setX(layout.rightX + ((tabWidth + layout.tabGap) * 2))
    self.btnTabEquipment:setY(layout.tabsY)
    self.btnTabEquipment:setWidth(layout.rightWidth - ((tabWidth + layout.tabGap) * 2))
    self.btnTabEquipment:setHeight(layout.tabH)

    self.btnRefresh:setX(layout.controlX)
    self.btnRefresh:setY(layout.searchY)
    self.btnRefresh:setWidth(layout.controlWidth)
    self.btnRefresh:setHeight(layout.searchH)

    self.btnDepositSelected:setX(layout.controlX)
    self.btnDepositSelected:setY(layout.centerButtonsY)
    self.btnDepositSelected:setWidth(layout.controlWidth)

    self.btnDepositVisible:setX(layout.controlX)
    self.btnDepositVisible:setY(layout.centerButtonsY + 40)
    self.btnDepositVisible:setWidth(layout.controlWidth)

    self.playerList:setX(layout.leftX)
    self.playerList:setY(layout.contentY)
    self.playerList:setWidth(layout.leftWidth)
    self.playerList:setHeight(layout.listH)
    self.playerList.width = layout.leftWidth
    self.playerList.height = layout.listH

    self.workerList:setX(layout.rightX)
    self.workerList:setY(layout.contentY)
    self.workerList:setWidth(layout.rightWidth)
    self.workerList:setHeight(layout.listH)
    self.workerList.width = layout.rightWidth
    self.workerList.height = layout.listH

    self.detailText:setX(layout.pad)
    self.detailText:setY(layout.detailY)
    self.detailText:setWidth(self.width - (layout.pad * 2))
    self.detailText:setHeight(layout.detailH)

    if self.detailText.vscroll then
        self.detailText.vscroll:setHeight(self.detailText:getHeight())
    end
    if self.refreshDetailSelection then
        self:refreshDetailSelection()
    end
    self:refreshTabButtons()
    self:updateTransferControls()
end

function DT_SupplyWindow:onResize()
    ISCollapsableWindow.onResize(self)
    self:relayout()
end

function DT_SupplyWindow:render()
    ISCollapsableWindow.render(self)

    local layout = self.layout or {}
    local playerVisible = self.playerList and self.playerList.items and #self.playerList.items or 0
    local playerTotal = #(self.playerEntries or {})
    local workerTotals = Internal.getWorkerSupplyTotals(self.workerEntries)

    self:drawRectBorder(layout.leftX, layout.contentY, layout.leftWidth, layout.listH, 0.25, 1, 1, 1)
    self:drawRectBorder(layout.rightX, layout.contentY, layout.rightWidth, layout.listH, 0.25, 1, 1, 1)
    self:drawRectBorder(layout.pad, layout.detailY, self.width - (layout.pad * 2), layout.detailH, 0.22, 1, 1, 1)

    self:drawText("Player Inventory", layout.leftX or 12, layout.headerY or 36, 0.94, 0.96, 1, 1, UIFont.Medium)
    self:drawText(
        self.scanning and ("Scanning " .. tostring(self.scanProcessed or 0) .. " items...")
            or (tostring(playerVisible) .. " visible / " .. tostring(playerTotal) .. " cached"),
        layout.leftX or 12,
        (layout.headerY or 36) + 18,
        0.7,
        0.7,
        0.7,
        1,
        UIFont.Small
    )

    self:drawText("Transfer", (layout.controlX or 0) + 16, layout.headerY or 36, 0.9, 0.9, 0.9, 1, UIFont.Small)

    self:drawText(tostring(self.workerName or "Worker") .. " Inventory", layout.rightX or 12, layout.headerY or 36, 0.94, 0.96, 1, 1, UIFont.Medium)
    self:drawText(
        Internal.getActiveWorkerTabLabel(self) .. " | " .. Internal.getWorkerTabSummary(self, self.workerEntries),
        layout.rightX or 12,
        (layout.headerY or 36) + 18,
        0.7,
        0.7,
        0.7,
        1,
        UIFont.Small
    )
end

function DT_SupplyWindow:updateStatus(text)
    self.lastStatusMessage = tostring(text or "")
end

function DT_SupplyWindow:updateItemDetail(entry, side)
    if not self.detailText then
        return
    end

    if not entry then
        local workerTabLabel = Internal.getActiveWorkerTabLabel(self)
        self.detailText:setText(
            " <RGB:0.78,0.78,0.78> Left side shows your inventory cache, right side shows what "
                .. tostring(self.workerName or "the worker")
                .. " currently has stored in "
                .. workerTabLabel
                .. ". "
                .. "<LINE> <RGB:0.62,0.62,0.62> Use "
                .. "<RGB:1,1,1> > <RGB:0.62,0.62,0.62> for one selected item or "
                .. "<RGB:1,1,1> >> <RGB:0.62,0.62,0.62> to send every visible filtered item when the active tab supports transfers. "
                .. "<LINE> <RGB:0.62,0.62,0.62> Active worker tab: <RGB:1,1,1> "
                .. workerTabLabel
                .. " <RGB:0.62,0.62,0.62> | "
                .. Internal.getWorkerTabSummary(self, self.workerEntries)
        )
        self.detailText:paginate()
        return
    end

    local text = ""
    if side == "worker" then
        text = text .. " <RGB:1,1,1> <SIZE:Large> " .. Internal.getActiveWorkerTabLabel(self) .. " <LINE> <LINE> "
        text = text .. " <RGB:0.82,0.82,0.82> Item: <RGB:1,1,1> " .. tostring(Internal.formatEntryLabel(entry)) .. " <LINE> "
        text = text .. " <RGB:0.82,0.82,0.82> Full Type: <RGB:1,1,1> " .. tostring(entry.fullType or "Unknown") .. " <LINE> "
        if self.activeTab == Internal.Tabs.Equipment then
            local tags = entry.tags or {}
            text = text .. " <RGB:0.82,0.82,0.82> Tool Tags: <RGB:1,1,1> "
                .. ((#tags > 0 and table.concat(tags, ", ")) or "None")
                .. " <LINE> "
        elseif self.activeTab == Internal.Tabs.Output then
            text = text .. " <RGB:0.82,0.82,0.82> Quantity: <RGB:1,1,1> " .. tostring(entry.qty or 1) .. " <LINE> "
        else
            text = text .. " <RGB:0.82,0.82,0.82> Remaining Calories: <RGB:1,1,1> " .. string.format("%.0f", entry.calories or 0) .. " <LINE> "
            text = text .. " <RGB:0.82,0.82,0.82> Remaining Hydration: <RGB:1,1,1> " .. string.format("%.0f", entry.hydration or 0) .. " <LINE> "
        end
    else
        text = text .. " <RGB:1,1,1> <SIZE:Large> Player Item <LINE> <LINE> "
        text = text .. " <RGB:0.82,0.82,0.82> Item: <RGB:1,1,1> " .. tostring(Internal.formatEntryLabel(entry)) .. " <LINE> "
        text = text .. " <RGB:0.82,0.82,0.82> Full Type: <RGB:1,1,1> " .. tostring(entry.fullType or "Unknown") .. " <LINE> "
        if self.activeTab == Internal.Tabs.Equipment then
            local tags = entry.tags or {}
            text = text .. " <RGB:0.82,0.82,0.82> Tool Tags: <RGB:1,1,1> "
                .. ((#tags > 0 and table.concat(tags, ", ")) or "None")
                .. " <LINE> "
            text = text .. " <RGB:0.82,0.82,0.82> Required For Worker: <RGB:1,1,1> " .. Internal.getRequiredToolSummary(self.workerData) .. " <LINE> "
        else
            text = text .. " <RGB:0.82,0.82,0.82> Adds Calories: <RGB:1,1,1> " .. string.format("%.0f", entry.calories or 0) .. " <LINE> "
            text = text .. " <RGB:0.82,0.82,0.82> Adds Hydration: <RGB:1,1,1> " .. string.format("%.0f", entry.hydration or 0) .. " <LINE> "
        end
    end

    self.detailText:setText(text)
    self.detailText:paginate()
end

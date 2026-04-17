local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

function DT_RadioScannerWindow:relayout()
    local titleBarHeight = self:titleBarHeight()
    local width = self:getWidth()
    local height = self:getHeight()
    local headerHeight = 85
    local footerHeight = 42
    local outerPadding = 10
    local columnGap = 10
    local statusHeight = 54

    if self.headerPanel then
        self.headerPanel:setX(0)
        self.headerPanel:setY(titleBarHeight)
        self.headerPanel:setWidth(width)
        self.headerPanel:setHeight(headerHeight)
    end

    local bodyY = titleBarHeight + headerHeight
    local footerY = height - footerHeight
    local bodyHeight = math.max(150, footerY - bodyY)
    local bodyWidth = math.max(320, width - (outerPadding * 2))
    local leftColumnWidth = clamp(math.floor(bodyWidth * 0.28), 180, 260)
    local minListWidth = 320
    if bodyWidth - leftColumnWidth - columnGap < minListWidth then
        leftColumnWidth = math.max(150, bodyWidth - columnGap - minListWidth)
    end

    local logHeight = clamp(math.floor(bodyHeight * 0.27), 110, 170)
    local topRowHeight = math.max(150, bodyHeight - logHeight - statusHeight - (columnGap * 2))
    local rightColumnX = outerPadding + leftColumnWidth + columnGap
    local rightColumnWidth = math.max(220, width - rightColumnX - outerPadding)

    if self.signalDisplayPanel then
        self.signalDisplayPanel:setX(outerPadding)
        self.signalDisplayPanel:setY(bodyY)
        self.signalDisplayPanel:setWidth(leftColumnWidth)
        self.signalDisplayPanel:setHeight(topRowHeight)
    end

    if self.logPanel then
        self.logPanel:setX(outerPadding)
        self.logPanel:setY(bodyY + topRowHeight + statusHeight + (columnGap * 2))
        self.logPanel:setWidth(bodyWidth)
        self.logPanel:setHeight(logHeight)
        self.logPanel:onResize()
    end

    if self.listPanel then
        self.listPanel:setX(rightColumnX)
        self.listPanel:setY(bodyY)
        self.listPanel:setWidth(rightColumnWidth)
        self.listPanel:setHeight(topRowHeight)
        if self.listPanel.onResize then
            self.listPanel:onResize()
        end
    end

    if self.statusPanel then
        self.statusPanel:setX(outerPadding)
        self.statusPanel:setY(bodyY + topRowHeight + columnGap)
        self.statusPanel:setWidth(bodyWidth)
        self.statusPanel:setHeight(statusHeight)
    end

    if self.actionPanel then
        self.actionPanel:setX(0)
        self.actionPanel:setY(footerY)
        self.actionPanel:setWidth(width)
        self.actionPanel:setHeight(footerHeight)
        self.actionPanel:onResize()
    end
end

function DT_RadioScannerWindow:onResize()
    ISCollapsableWindow.onResize(self)
    self:relayout()
end

function DT_RadioScannerWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    self.headerPanel = DT_RadioScannerHeaderPanel:new(0, 0, self.width, 85)
    self.headerPanel:initialise()
    self.headerPanel:instantiate()
    self.headerPanel:setAnchorRight(true)
    self:addChild(self.headerPanel)

    self.signalDisplayPanel = DT_RadioSignalDisplayPanel:new(0, 0, 220, 220)
    self.signalDisplayPanel:initialise()
    self.signalDisplayPanel:instantiate()
    self:addChild(self.signalDisplayPanel)

    self.statusPanel = DT_RadioScannerStatusPanel:new(0, 0, self.width, 54)
    self.statusPanel:initialise()
    self.statusPanel:instantiate()
    self.statusPanel:setAnchorRight(true)
    self:addChild(self.statusPanel)

    self.logPanel = DT_RadioNetworkLogPanel:new(0, 0, 220, 140, "DynamicTrading_Logs_v1.0")
    self.logPanel:initialise()
    self.logPanel:instantiate()
    self:addChild(self.logPanel)

    self.listPanel = DT_RadioScannerListPanel:new(0, 0, 320, 300)
    self.listPanel:initialise()
    self.listPanel:instantiate()
    self.listPanel:setAnchorRight(true)
    self.listPanel:setAnchorBottom(true)
    self:addChild(self.listPanel)
    self.listPanel:setLayoutMode(self.currentCategory == "Location" and "Location" or "Standard")

    self.actionPanel = DT_RadioScannerActionPanel:new(0, 0, self.width, 30)
    self.actionPanel:initialise()
    self.actionPanel:instantiate()
    self.actionPanel:setAnchorRight(true)
    self.actionPanel:setAnchorTop(false)
    self.actionPanel:setAnchorBottom(true)
    self:addChild(self.actionPanel)

    self:relayout()
    self:refresh()

    if isClient() and DT_RadioScannerManager and DT_RadioScannerManager.RequestRoster then
        DT_RadioScannerManager.RequestRoster()
    end
end
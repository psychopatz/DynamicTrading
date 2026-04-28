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
    local headerHeight = 112
    local outerPadding = 5
    local columnGap = 5
    local statusHeight = 62
    local actionHeight = 62

    if self.headerPanel then
        self.headerPanel:setX(0)
        self.headerPanel:setY(titleBarHeight)
        self.headerPanel:setWidth(width)
        self.headerPanel:setHeight(headerHeight)
    end

    local bodyY = titleBarHeight + headerHeight
    local bodyHeight = math.max(220, height - bodyY - outerPadding)
    local bodyWidth = math.max(320, width - (outerPadding * 2))
    
    local minLeftWidth = 200
    local leftColumnWidth = clamp(math.floor(bodyWidth * 0.26), minLeftWidth, 300)
    local minListWidth = 220
    if bodyWidth - leftColumnWidth - columnGap < minListWidth then
        leftColumnWidth = math.max(minLeftWidth, bodyWidth - columnGap - minListWidth)
    end

    local rightColumnWidth = math.max(180, bodyWidth - leftColumnWidth - columnGap)
    local logHeight = clamp(math.floor(bodyHeight * 0.23), 110, 180)
    local availableTopHeight = math.max(170, bodyHeight - logHeight - statusHeight - (columnGap * 2))
    local conversationWidth = clamp(math.floor(bodyWidth * 0.42), 220, 360)
    if bodyWidth - conversationWidth - columnGap < 220 then
        conversationWidth = math.max(220, bodyWidth - columnGap - 220)
    end
    local networkLogWidth = math.max(220, bodyWidth - conversationWidth - columnGap)
    
    -- Ensure squareSize is exactly the same as leftColumnWidth so they match as requested.
    local squareSize = leftColumnWidth
    
    local rightColumnX = outerPadding + leftColumnWidth + columnGap
    local imageBlockHeight = squareSize + columnGap + actionHeight
    local imageBlockTop = bodyY + math.max(0, math.floor((availableTopHeight - imageBlockHeight) / 2))
    local actionY = imageBlockTop + squareSize + columnGap
    local statusY = bodyY + availableTopHeight + columnGap
    local logY = statusY + statusHeight + columnGap

    self._leftColumnWidth = leftColumnWidth

    if self.signalDisplayPanel then
        self.signalDisplayPanel:setX(outerPadding)
        self.signalDisplayPanel:setY(imageBlockTop)
        self.signalDisplayPanel:setWidth(squareSize)
        self.signalDisplayPanel:setHeight(squareSize)
    end

    if self.trackedPortraitPanel then
        self.trackedPortraitPanel:setX(outerPadding)
        self.trackedPortraitPanel:setY(imageBlockTop)
        self.trackedPortraitPanel:setWidth(squareSize)
        self.trackedPortraitPanel:setHeight(squareSize)
        if self.trackedPortraitPanel.onResize then
            self.trackedPortraitPanel:onResize()
        end
    end

    if self.logPanel then
        self.logPanel:setX(outerPadding + conversationWidth + columnGap)
        self.logPanel:setY(logY)
        self.logPanel:setWidth(networkLogWidth)
        self.logPanel:setHeight(logHeight)
        self.logPanel:onResize()
    end

    if self.trackingDialoguePanel then
        self.trackingDialoguePanel:setX(outerPadding)
        self.trackingDialoguePanel:setY(logY)
        self.trackingDialoguePanel:setWidth(conversationWidth)
        self.trackingDialoguePanel:setHeight(logHeight)
        self.trackingDialoguePanel:onResize()
    end

    if self.listContainer then
        self.listContainer:setX(rightColumnX)
        self.listContainer:setY(bodyY)
        self.listContainer:setWidth(rightColumnWidth)
        self.listContainer:setHeight(availableTopHeight)
        
        if self.listPanel then
            self.listPanel:setX(0)
            self.listPanel:setY(0)
            self.listPanel:setWidth(self.listContainer:getWidth())
            self.listPanel:setHeight(self.listContainer:getHeight())
            if self.listPanel.onResize then
                self.listPanel:onResize()
            end
        end
    end

    if self.statusPanel then
        self.statusPanel:setX(outerPadding)
        self.statusPanel:setY(statusY)
        self.statusPanel:setWidth(bodyWidth)
        self.statusPanel:setHeight(statusHeight)
    end

    if self.actionPanel then
        self.actionPanel:setX(outerPadding)
        self.actionPanel:setY(actionY)
        self.actionPanel:setWidth(leftColumnWidth)
        self.actionPanel:setHeight(actionHeight)
        self.actionPanel:onResize()
    end
end

function DT_RadioScannerWindow:onResize()
    ISCollapsableWindow.onResize(self)
    self:relayout()
end

function DT_RadioScannerWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    self.headerPanel = DT_RadioScannerHeaderPanel:new(0, 0, self.width, 112)
    self.headerPanel:initialise()
    self.headerPanel:instantiate()
    self.headerPanel:setAnchorRight(true)
    self:addChild(self.headerPanel)

    self.signalDisplayPanel = DT_RadioSignalDisplayPanel:new(0, 0, 220, 220, { stretchToBounds = true, padding = 10 })
    self.signalDisplayPanel:initialise()
    self.signalDisplayPanel:instantiate()
    self:addChild(self.signalDisplayPanel)

    self.trackedPortraitPanel = DT_RadioScannerTrackedPortraitPanel:new(0, 0, 220, 220)
    self.trackedPortraitPanel:initialise()
    self.trackedPortraitPanel:instantiate()
    self.trackedPortraitPanel:setVisible(false)
    self:addChild(self.trackedPortraitPanel)

    self.statusPanel = DT_RadioScannerStatusPanel:new(0, 0, self.width, 54)
    self.statusPanel:initialise()
    self.statusPanel:instantiate()
    self.statusPanel:setAnchorRight(true)
    self:addChild(self.statusPanel)

    self.trackingDialoguePanel = DT_RadioScannerConversationPanel:new(0, 0, 280, 140, "Tracked Channel:")
    self.trackingDialoguePanel:initialise()
    self.trackingDialoguePanel:instantiate()
    self:addChild(self.trackingDialoguePanel)

    local radioLogKey = DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.GetStorageKey and DynamicTrading.GameplayLogs.GetStorageKey("Radio") or "DynamicTrading_GameplayLogs_Radio"
    self.logPanel = DT_RadioNetworkLogPanel:new(0, 0, 220, 140, radioLogKey)
    self.logPanel:initialise()
    self.logPanel:instantiate()
    self:addChild(self.logPanel)

    self.listContainer = ISPanel:new(0, 0, 320, 300)
    self.listContainer:initialise()
    self.listContainer:instantiate()
    self.listContainer.clip = true
    self.listContainer.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.listContainer.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.listContainer:setAnchorRight(true)
    self.listContainer:setAnchorBottom(true)
    self:addChild(self.listContainer)

    self.listPanel = DT_RadioScannerListPanel:new(0, 0, self.listContainer.width, self.listContainer.height)
    self.listPanel:initialise()
    self.listPanel:instantiate()
    self.listPanel:setAnchorRight(true)
    self.listPanel:setAnchorBottom(true)
    self.listContainer:addChild(self.listPanel)
    self.listPanel:setLayoutMode(self.currentCategory == "Location" and "Location" or "Standard")

    self.actionPanel = DT_RadioScannerActionPanel:new(0, 0, self.width, 38)
    self.actionPanel:initialise()
    self.actionPanel:instantiate()
    self.actionPanel:setAnchorRight(true)
    self.actionPanel:setAnchorBottom(false)
    self:addChild(self.actionPanel)

    self:relayout()
    self:refresh()

    if isClient() and DT_RadioScannerManager and DT_RadioScannerManager.RequestRoster then
        DT_RadioScannerManager.RequestRoster()
    end
end

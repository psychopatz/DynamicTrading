DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal
local MainWindowLayout = Internal.MainWindowLayout or {}

function DT_MainWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 980
    self.minimumHeight = 620
end

function DT_MainWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local pad = 10
    local headerY = th + pad
    local buttonY = headerY
    local listY = headerY + 38
    local footerH = 38
    local listWidth = 280
    local reserveH = 206
    local contentHeight = self.height - listY - footerH - pad
    local rightX = listWidth + (pad * 2)
    local rightWidth = self.width - rightX - pad
    local detailY = listY + reserveH + pad
    local detailHeight = math.max(
        MainWindowLayout.DETAIL_PANEL_MIN_HEIGHT,
        math.floor((self.height - detailY - footerH - pad - 8) * 0.38)
    )
    local activityY = detailY + detailHeight + 8
    local activityHeight = math.max(MainWindowLayout.ACTIVITY_PANEL_MIN_HEIGHT, self.height - activityY - footerH - pad)

    self.btnRefresh = ISButton:new(10, buttonY, 90, 28, "Refresh", self, self.onRefresh)
    self.btnRefresh:initialise()
    self:addChild(self.btnRefresh)

    self.btnCollect = ISButton:new(110, buttonY, 120, 28, "Collect Output", self, self.onCollectOutput)
    self.btnCollect:initialise()
    self:addChild(self.btnCollect)

    self.btnToggleJob = ISButton:new(240, buttonY, 100, 28, "Start Job", self, self.onToggleJob)
    self.btnToggleJob:initialise()
    self:addChild(self.btnToggleJob)

    self.btnCycleJob = ISButton:new(350, buttonY, 100, 28, "Change Job", self, self.onCycleJob)
    self.btnCycleJob:initialise()
    self:addChild(self.btnCycleJob)

    self.btnAssignHeldTool = ISButton:new(460, buttonY, 140, 28, "Assign Held Tool", self, self.onAssignHeldTool)
    self.btnAssignHeldTool:initialise()
    self:addChild(self.btnAssignHeldTool)

    self.btnGiveMoney = ISButton:new(610, buttonY, 110, 28, "Give Money", self, self.onGiveMoney)
    self.btnGiveMoney:initialise()
    self:addChild(self.btnGiveMoney)

    self.btnManageSupplies = ISButton:new(730, buttonY, 150, 28, "Manage Supplies", self, self.onManageSupplies)
    self.btnManageSupplies:initialise()
    self:addChild(self.btnManageSupplies)

    self.workerList = Internal.LabourWorkerList:new(10, listY, listWidth, contentHeight)
    self.workerList:initialise()
    self.workerList:instantiate()
    self.workerList.target = self
    self.workerList.onmousedown = DT_MainWindow.onWorkerListMouseDown
    self.workerList:setAnchorLeft(true)
    self.workerList:setAnchorTop(true)
    self.workerList:setAnchorBottom(true)
    self:addChild(self.workerList)

    self.reservePanel = Internal.LabourReservePanel:new(rightX, listY, rightWidth, reserveH)
    self.reservePanel:initialise()
    self.reservePanel:setAnchorRight(true)
    self:addChild(self.reservePanel)

    self.detailPanel = ISPanel:new(rightX, detailY, rightWidth, detailHeight)
    self.detailPanel:initialise()
    self.detailPanel.backgroundColor = { r = 0, g = 0, b = 0, a = 0.2 }
    self.detailPanel.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    self.detailPanel:setAnchorRight(true)
    self.detailPanel.prerender = function(panel)
        ISPanel.prerender(panel)
        panel:drawText("Details", 8, 6, 1, 1, 1, 1, UIFont.Medium)
    end
    self:addChild(self.detailPanel)

    self.detailText = ISRichTextPanel:new(
        MainWindowLayout.PANEL_INNER_PAD,
        MainWindowLayout.PANEL_HEADER_HEIGHT,
        rightWidth - (MainWindowLayout.PANEL_INNER_PAD * 2),
        detailHeight - MainWindowLayout.PANEL_HEADER_HEIGHT - MainWindowLayout.PANEL_INNER_PAD
    )
    self.detailText:initialise()
    self.detailText.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.detailText.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.detailText.autosetheight = false
    self.detailText.clip = true
    self.detailText:setMargins(0, 0, 0, 0)
    self.detailText:addScrollBars()
    if self.detailText.vscroll then
        self.detailText.vscroll:setHeight(self.detailText:getHeight())
    end
    self.detailPanel:addChild(self.detailText)

    self.activityLogPanel = ISPanel:new(rightX, activityY, rightWidth, activityHeight)
    self.activityLogPanel:initialise()
    self.activityLogPanel.backgroundColor = { r = 0, g = 0, b = 0, a = 0.2 }
    self.activityLogPanel.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    self.activityLogPanel:setAnchorRight(true)
    self.activityLogPanel:setAnchorBottom(true)
    self.activityLogPanel.prerender = function(panel)
        ISPanel.prerender(panel)
        panel:drawText("Activity Log", 8, 6, 1, 1, 1, 1, UIFont.Medium)
    end
    self:addChild(self.activityLogPanel)

    self.activityLogText = ISRichTextPanel:new(
        MainWindowLayout.PANEL_INNER_PAD,
        MainWindowLayout.PANEL_HEADER_HEIGHT,
        rightWidth - (MainWindowLayout.PANEL_INNER_PAD * 2),
        activityHeight - MainWindowLayout.PANEL_HEADER_HEIGHT - MainWindowLayout.PANEL_INNER_PAD
    )
    self.activityLogText:initialise()
    self.activityLogText.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.activityLogText.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.activityLogText.autosetheight = false
    self.activityLogText.clip = true
    self.activityLogText:setMargins(0, 0, 0, 0)
    self.activityLogText:addScrollBars()
    if self.activityLogText.vscroll then
        self.activityLogText.vscroll:setHeight(self.activityLogText:getHeight())
    end
    self.activityLogPanel:addChild(self.activityLogText)

    self.statusText = ISRichTextPanel:new(rightX, self.height - footerH - 4, rightWidth, 28)
    self.statusText:initialise()
    self.statusText.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.statusText.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.statusText:setAnchorRight(true)
    self.statusText:setAnchorBottom(true)
    self:addChild(self.statusText)

    MainWindowLayout.applyWindowLayout(self)
    self:updateStatus("Labour Management ready. Jobs are tool-gated, workplaces are deferred, and food/water remain upkeep.")
    self:populateWorkerList(DT_MainWindow.cachedWorkers or {})
end


DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal
local AUTO_REFRESH_FRAMES = 60

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
    local detailHeight = self.height - detailY - footerH - pad

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

    self.detailText = ISRichTextPanel:new(rightX, detailY, rightWidth, detailHeight)
    self.detailText:initialise()
    self.detailText.backgroundColor = { r = 0, g = 0, b = 0, a = 0.2 }
    self.detailText.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    self.detailText:setAnchorRight(true)
    self.detailText:setAnchorBottom(true)
    self.detailText:addScrollBars()
    if self.detailText.vscroll then
        self.detailText.vscroll:setHeight(self.detailText:getHeight())
    end
    self:addChild(self.detailText)

    self.statusText = ISRichTextPanel:new(rightX, self.height - footerH - 4, rightWidth, 28)
    self.statusText:initialise()
    self.statusText.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.statusText.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.statusText:setAnchorRight(true)
    self.statusText:setAnchorBottom(true)
    self:addChild(self.statusText)

    self:updateStatus("Labour Management ready. Jobs are tool-gated, workplaces are deferred, and food/water remain upkeep.")
    self:populateWorkerList(DT_MainWindow.cachedWorkers or {})
end

local function autoRefreshWindow(window)
    if not window or not window:getIsVisible() then
        return
    end

    if isClient() and not isServer() then
        window.syncStatusMutedFrames = 120
        window:sendLabourCommand("RequestPlayerWorkers", {})
        if window.selectedWorkerSummary and window.selectedWorkerSummary.workerID then
            window:sendLabourCommand("RequestWorkerDetails", {
                workerID = window.selectedWorkerSummary.workerID
            })
        end
        return
    end

    window:populateWorkerList(Internal.resolveWorkerSummaries())
    if window.selectedWorkerSummary and window.selectedWorkerSummary.workerID then
        local detail = Internal.resolveWorkerDetail(window.selectedWorkerSummary.workerID)
        if detail then
            window:updateWorkerDetail(detail)
        end
    end
end

function DT_MainWindow:prerender()
    ISCollapsableWindow.prerender(self)
    self.syncStatusMutedFrames = math.max(0, tonumber(self.syncStatusMutedFrames) or 0)
    if self.syncStatusMutedFrames > 0 then
        self.syncStatusMutedFrames = self.syncStatusMutedFrames - 1
    end
    self.autoRefreshFrames = (tonumber(self.autoRefreshFrames) or 0) + 1
    if self.autoRefreshFrames >= AUTO_REFRESH_FRAMES then
        self.autoRefreshFrames = 0
        autoRefreshWindow(self)
    end

    local th = self:titleBarHeight()
    local pad = 10
    local listY = th + pad + 38
    local contentHeight = self.height - listY - 38 - pad
    self:drawRectBorder(10, listY, 280, contentHeight, 0.4, 1, 1, 1)
    self:drawTextCentre("LABOUR MANAGEMENT", self.width / 2, th + 6, 1, 1, 1, 1, UIFont.Large)
end

function DT_MainWindow:updateStatus(text)
    if not self.statusText then
        return
    end

    self.statusText:setText(" <RGB:0.75,0.75,0.75> " .. tostring(text or "") .. " ")
    self.statusText:paginate()
end

function DT_MainWindow:onResize()
    ISCollapsableWindow.onResize(self)

    if self.detailText and self.detailText.vscroll then
        self.detailText.vscroll:setHeight(self.detailText:getHeight())
    end
end

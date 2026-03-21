DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal
local AUTO_REFRESH_FRAMES = 60
local DETAIL_PANEL_MIN_HEIGHT = 120
local ACTIVITY_PANEL_MIN_HEIGHT = 150
local PANEL_INNER_PAD = 6
local PANEL_HEADER_HEIGHT = 24

local function refreshRichTextPanel(panel)
    if not panel then
        return
    end

    panel:paginate()
    if panel.vscroll then
        panel.vscroll:setHeight(panel:getHeight())
    end
end

local function getRichTextContentHeight(panel)
    if not panel then
        return 0
    end

    local directHeight = tonumber(panel.textHeight) or tonumber(panel.contentHeight)
    if directHeight and directHeight > 0 then
        return directHeight
    end

    local getter = panel.getScrollHeight or panel.getTextHeight
    if getter then
        local ok, value = pcall(getter, panel)
        if ok and tonumber(value) and tonumber(value) > 0 then
            return tonumber(value)
        end
    end

    return 0
end

local function applyWindowLayout(window)
    if not window then
        return
    end

    local th = window:titleBarHeight()
    local pad = 10
    local headerY = th + pad
    local buttonY = headerY
    local listY = headerY + 38
    local footerH = 38
    local listWidth = 280
    local reserveH = 206
    local contentHeight = window.height - listY - footerH - pad
    local rightX = listWidth + (pad * 2)
    local rightWidth = window.width - rightX - pad
    local detailY = listY + reserveH + pad
    local detailsAreaHeight = window.height - detailY - footerH - pad
    local splitGap = 8
    local maxDetailHeight = math.max(DETAIL_PANEL_MIN_HEIGHT, detailsAreaHeight - ACTIVITY_PANEL_MIN_HEIGHT - splitGap)
    local detailHeight = math.max(DETAIL_PANEL_MIN_HEIGHT, math.min(maxDetailHeight, math.floor((detailsAreaHeight - splitGap) * 0.38)))

    if window.detailText then
        window.detailText:setWidth(math.max(0, rightWidth - (PANEL_INNER_PAD * 2)))
        refreshRichTextPanel(window.detailText)
        local contentHeight = getRichTextContentHeight(window.detailText)
        if contentHeight > 0 then
            local desiredHeight = contentHeight + (PANEL_INNER_PAD * 2) + 4
            detailHeight = math.max(DETAIL_PANEL_MIN_HEIGHT, math.min(maxDetailHeight, math.ceil(desiredHeight)))
        end
    end

    local activityY = detailY + detailHeight + splitGap
    local activityHeight = math.max(ACTIVITY_PANEL_MIN_HEIGHT, window.height - activityY - footerH - pad)

    if window.workerList then
        window.workerList:setX(10)
        window.workerList:setY(listY)
        window.workerList:setWidth(listWidth)
        window.workerList:setHeight(contentHeight)
    end

    if window.reservePanel then
        window.reservePanel:setX(rightX)
        window.reservePanel:setY(listY)
        window.reservePanel:setWidth(rightWidth)
        window.reservePanel:setHeight(reserveH)
    end

    if window.detailPanel then
        window.detailPanel:setX(rightX)
        window.detailPanel:setY(detailY)
        window.detailPanel:setWidth(rightWidth)
        window.detailPanel:setHeight(detailHeight)
    end

    if window.detailText then
        window.detailText:setX(PANEL_INNER_PAD)
        window.detailText:setY(PANEL_HEADER_HEIGHT)
        window.detailText:setWidth(math.max(0, rightWidth - (PANEL_INNER_PAD * 2)))
        window.detailText:setHeight(math.max(0, detailHeight - PANEL_HEADER_HEIGHT - PANEL_INNER_PAD))
        refreshRichTextPanel(window.detailText)
        if window.detailText.vscroll then
            window.detailText.vscroll:setHeight(window.detailText:getHeight())
        end
    end

    if window.activityLogPanel then
        window.activityLogPanel:setX(rightX)
        window.activityLogPanel:setY(activityY)
        window.activityLogPanel:setWidth(rightWidth)
        window.activityLogPanel:setHeight(activityHeight)
    end

    if window.activityLogText then
        window.activityLogText:setX(PANEL_INNER_PAD)
        window.activityLogText:setY(PANEL_HEADER_HEIGHT)
        window.activityLogText:setWidth(math.max(0, rightWidth - (PANEL_INNER_PAD * 2)))
        window.activityLogText:setHeight(math.max(0, activityHeight - PANEL_HEADER_HEIGHT - PANEL_INNER_PAD))
        refreshRichTextPanel(window.activityLogText)
        if window.activityLogText.vscroll then
            window.activityLogText.vscroll:setHeight(window.activityLogText:getHeight())
        end
    end

    if window.statusText then
        window.statusText:setX(rightX)
        window.statusText:setY(window.height - footerH - 4)
        window.statusText:setWidth(rightWidth)
        window.statusText:setHeight(28)
        refreshRichTextPanel(window.statusText)
    end
end

DT_MainWindow.applyDynamicLayout = applyWindowLayout

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
    local detailHeight = math.max(DETAIL_PANEL_MIN_HEIGHT, math.floor((self.height - detailY - footerH - pad - 8) * 0.38))
    local activityY = detailY + detailHeight + 8
    local activityHeight = math.max(ACTIVITY_PANEL_MIN_HEIGHT, self.height - activityY - footerH - pad)

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

    self.detailText = ISRichTextPanel:new(PANEL_INNER_PAD, PANEL_HEADER_HEIGHT, rightWidth - (PANEL_INNER_PAD * 2), detailHeight - PANEL_HEADER_HEIGHT - PANEL_INNER_PAD)
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

    self.activityLogText = ISRichTextPanel:new(PANEL_INNER_PAD, PANEL_HEADER_HEIGHT, rightWidth - (PANEL_INNER_PAD * 2), activityHeight - PANEL_HEADER_HEIGHT - PANEL_INNER_PAD)
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

    applyWindowLayout(self)
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
    refreshRichTextPanel(self.statusText)
end

function DT_MainWindow:onResize()
    ISCollapsableWindow.onResize(self)
    applyWindowLayout(self)
end

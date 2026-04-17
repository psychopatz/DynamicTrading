function DT_RadioScannerWindow:update()
    ISCollapsableWindow.update(self)

    if self:getIsVisible() then
        if self.trackingUUID then
            self:updateTrackingMarker()
        end

        self.updateTimer = self.updateTimer + getGameTime():getRealworldSecondsSinceLastUpdate()
        if self.updateTimer >= 2.0 then
            self.updateTimer = 0
            self:refresh()
        end

        if isClient() and DT_RadioScannerManager and DT_RadioScannerManager.RequestRoster then
            self.syncTimer = self.syncTimer + getGameTime():getRealworldSecondsSinceLastUpdate()
            if self.syncTimer >= 10.0 then
                self.syncTimer = 0
                DT_RadioScannerManager.RequestRoster()
            end
        end
    end
end

function DT_RadioScannerWindow.ToggleWindow(device)
    if DT_RadioScannerWindow.instance then
        if DT_RadioScannerWindow.instance:getIsVisible() then
            DT_RadioScannerWindow.instance:close()
        else
            DT_RadioScannerWindow.instance.device = device
            DT_RadioScannerWindow.instance:setVisible(true)
            DT_RadioScannerWindow.instance:addToUIManager()
            DT_RadioScannerWindow.instance:refresh()
        end
        return
    end

    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local width = math.min(820, screenW * 0.62)
    local height = math.min(720, screenH * 0.76)
    width = math.max(650, width)
    height = math.max(650, height)

    local window = DT_RadioScannerWindow:new(screenW / 2 - width / 2, screenH / 2 - height / 2, width, height)
    window.device = device
    window:initialise()
    window:addToUIManager()
    DT_RadioScannerWindow.instance = window
end

function DT_RadioScannerWindow:close()
    self:stopTracking()
    self:setVisible(false)
    self:removeFromUIManager()
end
function DT_RadioScannerWindow:update()
    ISCollapsableWindow.update(self)

    if self:getIsVisible() then
        local player = getSpecificPlayer(0)
        if not player then return end

        -- Radio Requirement Check
        if DT_RadioScannerManager and DT_RadioScannerManager.HasActiveRadio then
            local activeDevice = DT_RadioScannerManager.HasActiveRadio(player, self.device)
            if not activeDevice then
                self:close()
                if HaloTextHelper then
                    HaloTextHelper.addTextWithArrow(player, "Signal Lost (Radio Off/Missing)", true, HaloTextHelper.getColorRed())
                end
            else
                self.device = activeDevice
            end
        end

        if self.trackingUUID then
            self:updateTrackingMarker()
        end

        local dt = getGameTime():getRealworldSecondsSinceLastUpdate()
        -- The visual timer should use absolute UI time so it ticks down even when the game is paused.
        local uiDt = UIManager.getMillisSinceLastRender() / 1000.0
        if self.foundVisualTimer and self.foundVisualTimer > 0 then
            self.foundVisualTimer = math.max(0, self.foundVisualTimer - uiDt)
            if self.foundVisualTimer == 0 then
                self:refresh()
            end
        end

        self.updateTimer = self.updateTimer + uiDt
        if self.processTrackingDialogueQueue then
            self:processTrackingDialogueQueue(uiDt)
        end
        if self.updateTimer >= 2.0 then
            self.updateTimer = 0
            self:refresh()
        end

        if isClient() and DT_RadioScannerManager and DT_RadioScannerManager.RequestRoster then
            self.syncTimer = self.syncTimer + uiDt
            if self.syncTimer >= 10.0 then
                self.syncTimer = 0
                DT_RadioScannerManager.RequestRoster()
            end
        end
    end
end

function DT_RadioScannerWindow.ToggleWindow(device)
    if DT_FactionInfoWindow and DT_FactionInfoWindow.instance and DT_FactionInfoWindow.instance:getIsVisible() then
        DT_FactionInfoWindow.instance:close()
    end
    if DC_SupplyWindow and DC_SupplyWindow.instance and DC_SupplyWindow.instance:getIsVisible() then
        DC_SupplyWindow.instance:close()
    end

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

-- ==============================================================================
-- DT_V2_RadarWindow_Lifecycle.lua
-- Update loop and window open/close lifecycle for the Trader Radar window.
-- ==============================================================================

function DT_V2_RadarWindow:update()
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

        if isClient() then
            self.syncTimer = self.syncTimer + getGameTime():getRealworldSecondsSinceLastUpdate()
            if self.syncTimer >= 10.0 then
                self.syncTimer = 0
                DT_V2_RadarManager.RequestRoster()
            end
        end
    end
end

function DT_V2_RadarWindow.ToggleWindow(device)
    if DT_V2_RadarWindow.instance then
        if DT_V2_RadarWindow.instance:getIsVisible() then
            DT_V2_RadarWindow.instance:close()
        else
            DT_V2_RadarWindow.instance.device = device
            DT_V2_RadarWindow.instance:setVisible(true)
            DT_V2_RadarWindow.instance:addToUIManager()
            DT_V2_RadarWindow.instance:refresh()
        end
        return
    end

    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local width = math.min(500, screenW * 0.4)
    local height = math.min(600, screenH * 0.6)

    width = math.max(450, width)
    height = math.max(450, height)

    local window = DT_V2_RadarWindow:new(screenW / 2 - width / 2, screenH / 2 - height / 2, width, height)
    window.device = device
    window:initialise()
    window:addToUIManager()
    DT_V2_RadarWindow.instance = window
end

function DT_V2_RadarWindow:close()
    self:stopTracking()
    self:setVisible(false)
    self:removeFromUIManager()
end

-- ==============================================================================
-- DT_V2_RadarWindow_Core.lua
-- Core class definition and initialization for the Trader Radar window.
-- ==============================================================================

DT_V2_RadarWindow = ISCollapsableWindow:derive("DT_V2_RadarWindow")
DT_V2_RadarWindow.instance = nil

DT_V2_RadarWindow.MARKER_ID = "DT_Radar_Active_Target"

function DT_V2_RadarWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 450
    self.minimumHeight = 450

    self.currentCategory = "Stationary"

    self.updateTimer = 0
    self.syncTimer = 0

    self.trackingUUID = nil
    self.trackingName = nil
end

function DT_V2_RadarWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "Trader Radar"
    o.resizable = true
    return o
end

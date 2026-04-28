DT_RadioScannerWindow = ISCollapsableWindow:derive("DT_RadioScannerWindow")
DT_RadioScannerWindow.instance = nil

DT_RadioScannerWindow.MARKER_ID = "DT_Radar_Active_Target"

function DT_RadioScannerWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 650
    self.minimumHeight = 650

    self.currentCategory = "Discovered"
    self.updateTimer = 0
    self.syncTimer = 0
    self.trackingUUID = nil
    self.trackingName = nil
    self.trackingData = nil
    self.trackingContext = nil
    self.trackingMessageQueue = {}
    self.trackingMilestones = nil
end

function DT_RadioScannerWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "Trader Radar"
    o.resizable = true
    return o
end
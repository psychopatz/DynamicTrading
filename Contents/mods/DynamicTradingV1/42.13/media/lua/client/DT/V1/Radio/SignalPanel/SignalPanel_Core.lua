-- =============================================================================
-- DYNAMIC TRADING V1: SIGNAL PANEL - CORE
-- =============================================================================

V1_SignalPanel_Core_logic = {}

function DT_SignalPanel:initialise()
    ISPanel.initialise(self)
    self.signalState = "search"
    self.signalFrame = 1
    self.signalAnimTimer = 0
    self.signalFrameDuration = 200
    self.signalFoundPersist = false
    self.clickAnimTimer = 0

    self.signalFrameCounts = { search = 5, found = 3, none = 3 }
    self.signalTextures = { search = {}, found = {}, none = {} }

    for i = 1, 5 do
        self.signalTextures.search[i] = getTexture("media/ui/Radio/Signal_search/" .. i .. ".png")
    end

    for i = 1, 3 do
        self.signalTextures.found[i] = getTexture("media/ui/Radio/Signal_found/" .. i .. ".png")
        self.signalTextures.none[i] = getTexture("media/ui/Radio/Signal_none/" .. i .. ".png")
    end

    self.imgSize = 130
    self.imgX = 10
    self.imgY = 10
end

function DT_SignalPanel:getRadioTypeID()
    if not self.parent or not self.parent.radioObj then
        return nil
    end

    local typeID = nil
    if DT_RadioInteraction and DT_RadioInteraction.GetDeviceType then
        typeID = DT_RadioInteraction.GetDeviceType(self.parent.radioObj)
    end

    if not typeID and self.parent.radioObj.getFullType then
        typeID = self.parent.radioObj:getFullType()
    end

    return typeID
end

function DT_SignalPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    return o
end

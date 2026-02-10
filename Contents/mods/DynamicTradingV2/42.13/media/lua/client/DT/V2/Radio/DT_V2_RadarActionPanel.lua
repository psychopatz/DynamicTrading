-- ==============================================================================
-- DT_V2_RadarActionPanel.lua
-- Manages buttons and interaction logic (Locate, Refresh, Close).
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISButton"

DT_V2_RadarActionPanel = ISPanel:derive("DT_V2_RadarActionPanel")

function DT_V2_RadarActionPanel:initialise()
    ISPanel.initialise(self)
end

function DT_V2_RadarActionPanel:createChildren()
    ISPanel.createChildren(self)

    local btnWidth = 100
    local btnHeight = 25
    local spacing = 10
    
    -- Refresh Button (Left)
    self.btnRefresh = ISButton:new(spacing, 0, btnWidth, btnHeight, "REFRESH", self, self.onRefresh)
    self.btnRefresh:initialise()
    self.btnRefresh:setAnchorLeft(true)
    self.btnRefresh:setAnchorTop(false)
    self.btnRefresh:setAnchorBottom(true)
    self:addChild(self.btnRefresh)

    -- Locate Button (Right)
    self.btnLocate = ISButton:new(self.width - btnWidth - spacing, 0, btnWidth, btnHeight, "LOCATE", self, self.onLocate)
    self.btnLocate:initialise()
    self.btnLocate.backgroundColor = {r=0, g=0.5, b=0, a=1}
    self.btnLocate.enable = false
    self.btnLocate:setAnchorLeft(false)
    self.btnLocate:setAnchorRight(true)
    self.btnLocate:setAnchorTop(false)
    self.btnLocate:setAnchorBottom(true)
    self:addChild(self.btnLocate)
end

function DT_V2_RadarActionPanel:updateButtonState(selectedUUID)
    if not self.parent then return end
    
    -- Check if the selected item is the one currently being tracked
    if self.parent.trackingUUID and self.parent.trackingUUID == selectedUUID then
        self.btnLocate.title = "STOP"
        self.btnLocate.backgroundColor = {r=0.6, g=0.1, b=0.1, a=1} -- Red
    else
        self.btnLocate.title = "LOCATE"
        self.btnLocate.backgroundColor = {r=0, g=0.5, b=0, a=1} -- Green
    end
end

function DT_V2_RadarActionPanel:onRefresh()
    if self.parent and self.parent.refresh then
        self.parent:refresh()
    end
end

function DT_V2_RadarActionPanel:onLocate()
    if not self.parent or not self.parent.listPanel then return end
    
    local listbox = self.parent.listPanel.listbox
    local item = listbox.items[listbox.selected]
    if not item or not item.item then return end
    
    local data = item.item
    local uuid = data.uuid
    
    -- Toggle Logic
    if self.parent.trackingUUID == uuid then
        -- Stop Tracking
        self.parent:stopTracking()
    else
        -- Start Tracking (Overwrites previous due to window logic)
        self.parent:startTracking(uuid, data.name)
    end
    
    -- Update UI immediately
    self:updateButtonState(uuid)
end

function DT_V2_RadarActionPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    return o
end

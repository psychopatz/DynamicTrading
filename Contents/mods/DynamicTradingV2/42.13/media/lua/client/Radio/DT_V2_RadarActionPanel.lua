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
    
    self.btnLocate = ISButton:new(spacing, 0, btnWidth, btnHeight, "LOCATE", self, self.onLocate)
    self.btnLocate:initialise()
    self.btnLocate.backgroundColor = {r=0, g=0.5, b=0, a=1}
    self.btnLocate.enable = false
    self.btnLocate:setAnchorLeft(true)
    self.btnLocate:setAnchorTop(false)
    self.btnLocate:setAnchorBottom(true)
    self:addChild(self.btnLocate)

    self.btnRefresh = ISButton:new(spacing + btnWidth + spacing, 0, btnWidth, btnHeight, "REFRESH", self, self.onRefresh)
    self.btnRefresh:initialise()
    self.btnRefresh:setAnchorLeft(true)
    self.btnRefresh:setAnchorTop(false)
    self.btnRefresh:setAnchorBottom(true)
    self:addChild(self.btnRefresh)

    self.btnClose = ISButton:new(self.width - btnWidth - spacing, 0, btnWidth, btnHeight, "CLOSE", self, self.onClose)
    self.btnClose:initialise()
    self.btnClose:setAnchorLeft(false)
    self.btnClose:setAnchorRight(true)
    self.btnClose:setAnchorTop(false)
    self.btnClose:setAnchorBottom(true)
    self:addChild(self.btnClose)
end

function DT_V2_RadarActionPanel:onRefresh()
    if self.parent and self.parent.refresh then
        self.parent:refresh()
    end
end

function DT_V2_RadarActionPanel:onClose()
    if self.parent and self.parent.setVisible then
        self.parent:setVisible(false)
        self.parent:removeFromUIManager()
    end
end

function DT_V2_RadarActionPanel:onLocate()
    if not self.parent or not self.parent.listPanel then return end
    
    local listbox = self.parent.listPanel.listbox
    local item = listbox.items[listbox.selected]
    if not item or not item.item then return end
    
    local data = item.item
    if not data.x or not data.y then
        getSpecificPlayer(0):Say("Signal too weak to pinpoint.")
        return
    end

    if EventMarkerHandler then
        local color = {r=0, g=1, b=1}
        local description = "Trader: " .. tostring(data.name)
        
        EventMarkerHandler.set(
            "radar_" .. data.uuid,
            "friend.png",
            600, 
            data.x,
            data.y,
            color,
            description
        )
        getSpecificPlayer(0):Say("Location marked on map.")
    else
        getSpecificPlayer(0):Say("GPS System Error.")
    end
end

function DT_V2_RadarActionPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    return o
end

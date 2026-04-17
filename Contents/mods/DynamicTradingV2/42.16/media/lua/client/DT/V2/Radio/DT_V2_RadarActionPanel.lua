-- ==============================================================================
-- DT_V2_RadarActionPanel.lua
-- Manages buttons and interaction logic (Locate, Refresh, Close).
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISButton"
require "DT/Common/UI/Contacts/DT_ContactsWindow"

DT_V2_RadarActionPanel = ISPanel:derive("DT_V2_RadarActionPanel")

local BUTTON_WIDTH = 100
local BUTTON_HEIGHT = 25
local BUTTON_SPACING = 10

local function layoutButtons(self)
    if self.btnRefresh then
        self.btnRefresh:setX(BUTTON_SPACING)
        self.btnRefresh:setY(0)
        self.btnRefresh:setWidth(BUTTON_WIDTH)
        self.btnRefresh:setHeight(BUTTON_HEIGHT)
    end

    if self.btnContacts then
        self.btnContacts:setX(math.floor((self.width - BUTTON_WIDTH) / 2))
        self.btnContacts:setY(0)
        self.btnContacts:setWidth(BUTTON_WIDTH)
        self.btnContacts:setHeight(BUTTON_HEIGHT)
    end

    if self.btnLocate then
        self.btnLocate:setX(self.width - BUTTON_WIDTH - BUTTON_SPACING)
        self.btnLocate:setY(0)
        self.btnLocate:setWidth(BUTTON_WIDTH)
        self.btnLocate:setHeight(BUTTON_HEIGHT)
    end
end

function DT_V2_RadarActionPanel:initialise()
    ISPanel.initialise(self)
end

function DT_V2_RadarActionPanel:createChildren()
    ISPanel.createChildren(self)
    
    -- Refresh Button (Left)
    self.btnRefresh = ISButton:new(BUTTON_SPACING, 0, BUTTON_WIDTH, BUTTON_HEIGHT, "REFRESH", self, self.onRefresh)
    self.btnRefresh:initialise()
    self.btnRefresh:setAnchorLeft(true)
    self.btnRefresh:setAnchorTop(false)
    self.btnRefresh:setAnchorBottom(true)
    self:addChild(self.btnRefresh)

    -- Contacts Button (Center)
    self.btnContacts = ISButton:new(math.floor((self.width - BUTTON_WIDTH) / 2), 0, BUTTON_WIDTH, BUTTON_HEIGHT, "CONTACTS", self, self.onContacts)
    self.btnContacts:initialise()
    self.btnContacts.backgroundColor = {r=0.12, g=0.24, b=0.45, a=1}
    self.btnContacts:setAnchorLeft(false)
    self.btnContacts:setAnchorRight(false)
    self.btnContacts:setAnchorTop(false)
    self.btnContacts:setAnchorBottom(true)
    self:addChild(self.btnContacts)

    -- Locate Button (Right)
    self.btnLocate = ISButton:new(self.width - BUTTON_WIDTH - BUTTON_SPACING, 0, BUTTON_WIDTH, BUTTON_HEIGHT, "LOCATE", self, self.onLocate)
    self.btnLocate:initialise()
    self.btnLocate.backgroundColor = {r=0, g=0.5, b=0, a=1}
    self.btnLocate.enable = false
    self.btnLocate:setAnchorLeft(false)
    self.btnLocate:setAnchorRight(true)
    self.btnLocate:setAnchorTop(false)
    self.btnLocate:setAnchorBottom(true)
    self:addChild(self.btnLocate)

    layoutButtons(self)
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

function DT_V2_RadarActionPanel:onContacts()
    local selectedUUID = nil
    if self.parent and self.parent.listPanel and self.parent.listPanel.listbox then
        local listbox = self.parent.listPanel.listbox
        local item = listbox.items[listbox.selected]
        if item and item.item then
            selectedUUID = item.item.uuid
        end
    end

    DT_ContactsWindow.Open({ selectTraderID = selectedUUID })
end

function DT_V2_RadarActionPanel:onResize()
    ISPanel.onResize(self)
    layoutButtons(self)
end

function DT_V2_RadarActionPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    return o
end

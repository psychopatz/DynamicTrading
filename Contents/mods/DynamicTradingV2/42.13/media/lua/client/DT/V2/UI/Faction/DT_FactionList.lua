-- ==============================================================================
-- media/lua/client/DT/V2/UI/DT_FactionList.lua
-- Dedicated List Component for Faction Info UI
-- Handles rendering of faction items with status colors
-- ==============================================================================

require "ISUI/ISScrollingListBox"

DT_FactionList = ISScrollingListBox:derive("DT_FactionList")

function DT_FactionList:new(x, y, width, height)
    local o = ISScrollingListBox:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.itemheight = 55
    o.selected = 1
    o.joypadParent = nil
    o.drawBorder = true
    return o
end

function DT_FactionList:onResizeFont(scale)
    if scale == "Large" then
        self.font = UIFont.Large
        self.itemheight = 75
    elseif scale == "Medium" then
        self.font = UIFont.Medium
        self.itemheight = 55
    else
        self.font = UIFont.Small
        self.itemheight = 45
    end
end

function DT_FactionList:doDrawItem(y, item, alt)
    local f = item.item
    if not f then return y end

    -- Selection / Background
    if item.selected then
        self:drawRect(0, y, self.width, self.itemheight, 0.3, 0.7, 0.7, 0.7)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 1, 1, 1)
    else
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 0, 0, 0)
    end

    -- Color Coding based on Status
    local r, g, b = 0.8, 0.8, 0.8 -- Default gray-ish
    if f.state == "Starving" then 
        r, g, b = 1, 0.2, 0.2 -- Red
    elseif f.state == "Vulnerable" then 
        r, g, b = 1, 0.6, 0.2 -- Orange
    elseif f.state == "Prospering" then
        r, g, b = 0.2, 1, 0.2 -- Green
    elseif f.state == "Stable" then
        r, g, b = 0.4, 0.8, 1 -- Light Blue
    end

    -- Event Indicator
    local eventStr = f.ActiveFlashEvent and f.ActiveFlashEvent.id or ""
    local hasEvent = eventStr ~= "" and eventStr ~= "None"

    -- Text Rendering
    -- Name
    local nameFont = UIFont.Medium
    local statusFont = UIFont.Small
    local statusY = 22
    
    if self.font == UIFont.Large then
        nameFont = UIFont.Large
        statusFont = UIFont.Medium
        statusY = 35
    elseif self.font == UIFont.Medium then
        nameFont = UIFont.Large
        statusFont = UIFont.Medium
        statusY = 30
    end

    self:drawText(item.text, 10, y + 5, r, g, b, 1, nameFont)
    
    -- Status Line (State | Pop)
    local statusText = "State: " .. tostring(f.state) .. " | Pop: " .. tostring(f.memberCount)
    self:drawText(statusText, 10, y + statusY, 0.6, 0.6, 0.6, 0.8, statusFont)

    -- Borders between items
    self:drawRectBorder(0, y, self.width, self.itemheight, 0.1, 1, 1, 1)

    return y + self.itemheight
end

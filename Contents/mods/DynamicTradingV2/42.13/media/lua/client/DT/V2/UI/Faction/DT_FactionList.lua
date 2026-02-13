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
    o.itemheight = 40
    o.selected = 1
    o.joypadParent = nil
    o.font = UIFont.NewSmall
    o.doDrawItem = self.doDrawItem
    o.drawBorder = true
    return o
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
    self:drawText(item.text, 10, y + 5, r, g, b, 1, UIFont.Medium)
    
    -- Status Line (State | Pop)
    local statusText = "State: " .. tostring(f.state) .. " | Pop: " .. tostring(f.memberCount)
    self:drawText(statusText, 10, y + 22, 0.6, 0.6, 0.6, 0.8, UIFont.Small)

    -- Borders between items
    self:drawRectBorder(0, y, self.width, self.itemheight, 0.1, 1, 1, 1)

    return y + self.itemheight
end

-- ==============================================================================
-- media/lua/client/DT/V2/UI/DT_FactionList.lua
-- Dedicated List Component for Faction Info UI
-- Handles rendering of faction items with status colors
-- ==============================================================================

require "ISUI/ISScrollingListBox"
require "DT/UI/Shared/DT_UIUtils"

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

    -- Selection / Background (Unified Utility)
    DT_UIUtils.drawSelectionHighlight(self, y, item, alt)

    local state = f.state or "Stable"
    local rosterData = DT_FactionInfoWindow and DT_FactionInfoWindow.cachedRosterData or nil
    local nameColor = DT_UIUtils.GetFactionReputationColor and DT_UIUtils.GetFactionReputationColor(f, rosterData, { alpha = 1 })
        or { r = 0.8, g = 0.8, b = 0.8, a = 1 }
    local statusColor = DT_UIUtils.ScaleColor and DT_UIUtils.ScaleColor(nameColor, 0.82, 0.9)
        or { r = 0.6, g = 0.6, b = 0.6, a = 0.9 }

    -- Event Indicator (multi-flash aware with legacy fallback)
    local flashEvents = f.ActiveFlashEvents or {}
    if #flashEvents == 0 and f.ActiveFlashEvent and f.ActiveFlashEvent.id then
        flashEvents = { { id = f.ActiveFlashEvent.id } }
    end
    local eventCount = #flashEvents

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

    self:drawText(item.text, 10, y + 5, nameColor.r, nameColor.g, nameColor.b, nameColor.a or 1, nameFont)
    
    -- Status Line (State | Pop)
    local popCount = f.memberCount or "0"
    if f.isV1 and DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.GetDiscoveredCount then
        popCount = DynamicTrading.Manager.GetDiscoveredCount(getSpecificPlayer(0))
    end
    local statusText = "State: " .. tostring(state) .. " | Pop: " .. tostring(popCount) .. " | Flash: " .. tostring(eventCount)
    if f.playerOwned then
        statusText = "Leader: " .. tostring(f.leaderUsername or "Admin Review") .. " | Pop: " .. tostring(popCount) .. " | " .. tostring(f.leadershipState or state)
    end
    self:drawText(statusText, 10, y + statusY, statusColor.r, statusColor.g, statusColor.b, statusColor.a or 0.9, statusFont)

    -- Borders between items
    self:drawRectBorder(0, y, self.width, self.itemheight, 0.1, 1, 1, 1)

    return y + self.itemheight
end

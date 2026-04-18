-- ==============================================================================
-- media/lua/client/DT/UI/Faction/Tabs/DT_FactionEventLogPanel.lua
-- Component: Reusable Event Log Panel for Factions
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"

DT_FactionEventLogPanel = ISPanel:derive("DT_FactionEventLogPanel")

function DT_FactionEventLogPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0.2}
    o.borderColor = {r=0.3, g=0.3, b=0.3, a=0.5}
    o.lastNewsCount = -1
    o.lastFactionID = ""
    return o
end

function DT_FactionEventLogPanel:initialise()
    ISPanel.initialise(self)
end

function DT_FactionEventLogPanel:createChildren()
    -- Title for the log section
    self.lblTitle = ISLabel:new(0, 0, 20, " RECENT EVENTS ", 0.4, 0.8, 1, 1, UIFont.Small, true)
    self:addChild(self.lblTitle)

    self.richText = ISRichTextPanel:new(0, 22, self.width, self.height - 22)
    self.richText:initialise()
    self.richText.backgroundColor = {r=0, g=0, b=0, a=0.4}
    self.richText.borderColor = {r=0, g=0, b=0, a=0}
    self.richText:addScrollBars()
    self.richText:setAnchorRight(true)
    self.richText:setAnchorBottom(true)
    self:addChild(self.richText)
end

function DT_FactionEventLogPanel:onResize()
    ISPanel.onResize(self)
    if self.richText then
        self.richText:setWidth(self.width)
        self.richText:setHeight(self.height - 22)
        -- Delayed paginate to ensure width is applied
        self.richText:paginate()
    end
end

function DT_FactionEventLogPanel:updateData(f)
    if not f then 
        self.richText:setText("")
        self.lastFactionID = ""
        self.lastNewsCount = -1
        return 
    end

    local news = f.news or {}
    local newsCount = #news
    
    -- Optimization: Only update if faction changed or new entries arrived
    if f.id == self.lastFactionID and newsCount == self.lastNewsCount then
        return
    end

    self.lastFactionID = f.id
    self.lastNewsCount = newsCount

    if newsCount == 0 then
        self.richText:setText(" <RGB:0.5,0.5,0.5> No recent records for this faction.")
        self.richText:paginate()
        return
    end

    local text = ""
    for i, entry in ipairs(news) do
        -- Date formatting from network log style
        local dateStr = " <RGB:0.5,0.5,0.5> [" .. tostring(entry.time or "??/??") .. "]"
        
        -- Color coding by category
        local colorTag = " <RGB:0.8,0.8,0.8> " -- info/default
        if entry.cat == "good" then
            colorTag = " <RGB:0.4,1,0.4> "
        elseif entry.cat == "bad" then
            colorTag = " <RGB:1,0.4,0.4> "
        elseif entry.cat == "event" then
            colorTag = " <RGB:1,1,0.4> "
        end
        
        text = text .. dateStr .. colorTag .. " " .. tostring(entry.text or "") .. " <LINE> "
    end

    self.richText:setText(text)
    self.richText:paginate()
end

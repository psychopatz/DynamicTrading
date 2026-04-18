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
    o.lastNewsHash = ""
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
        self.lastNewsHash = ""
        return 
    end

    local newsData = ModData.getOrCreate("DynamicTrading_Logs_Factions")
    local news = newsData[f.id] or {}
    local newsCount = #news
    
    local topEntry = news[1]
    local topNewsHash = tostring(newsCount) .. (newsCount > 0 and ((topEntry.time or topEntry.t or "") .. (topEntry.text or tostring(topEntry.e))) or "")
    
    -- Optimization: Only update if faction changed or new entries arrived
    if f.id == self.lastFactionID and topNewsHash == self.lastNewsHash then
        return
    end

    self.lastFactionID = f.id
    self.lastNewsHash = topNewsHash

    if newsCount == 0 then
        self.richText:setText(" <RGB:0.5,0.5,0.5> No recent records for this faction.")
        self.richText:paginate()
        return
    end

    local text = ""
    for i = 1, #news do
        local entry = news[i]
        
        -- Serialize text using template resolver
        local textStr, catStr = entry.text, entry.cat
        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.ResolveText then
            textStr, catStr = DynamicTrading.GameplayLogs.ResolveText(entry)
        end
        
        local color = "<RGB:0.8,0.8,0.8> "
        if catStr == "good" then
            color = "<RGB:0.4,1.0,0.4> "
        elseif catStr == "bad" then
            color = "<RGB:1.0,0.4,0.4> "
        elseif catStr == "event" then
            color = "<RGB:1.0,1.0,0.4> "
        end
        local timeStr = entry.time or entry.t or ""
        text = text .. "<RGB:0.5,0.5,0.5> [" .. timeStr .. "] " .. color .. (textStr or "Unknown event") .. " <LINE> "
    end

    self.richText:setText(text)
    self.richText:paginate()
end

-- ==============================================================================
-- media/lua/client/DT/UI/Faction/Tabs/Economics/DT_FactionEconomics_Trends.lua
-- Sub-Panel: Global Trends (Inflation/Deflation per Category)
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"

DT_FactionEconomics_Trends = ISPanel:derive("DT_FactionEconomics_Trends")

function DT_FactionEconomics_Trends:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}
    return o
end

function DT_FactionEconomics_Trends:initialise()
    ISPanel.initialise(self)
end

function DT_FactionEconomics_Trends:createChildren()
    if self.richText then return end

    self.richText = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.richText:initialise()
    self.richText.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.richText.borderColor = {r=0.4, g=0.4, b=0.4, a=0.5}
    self.richText:setAnchorRight(true)
    self.richText:setAnchorBottom(true)
    self.richText.autosetheight = false
    self.richText:setMargins(10, 10, 10, 10)
    self.richText.clip = true
    self.richText:addScrollBars()
    self:addChild(self.richText)
end

function DT_FactionEconomics_Trends:onResize()
    ISPanel.onResize(self)
    if self.richText then
        self.richText:setWidth(self.width)
        self.richText:setHeight(self.height)
        self.richText:paginate()
    end
end

function DT_FactionEconomics_Trends:updateData(f, fontScale)
    if not self.richText then return end
    
    local scale = fontScale or "Medium"
    local titleSize = (scale == "Large" and "Large") or (scale == "Medium" and "Medium") or "Small"
    local bodySize = (scale == "Large" and "Medium") or "Small"

    -- Get Global Heat (Inflation/Deflation)
    local engineData = DynamicTrading_Engine and DynamicTrading_Engine.GetEngineData()
    local globalHeat = (engineData and engineData.WorldEconomy and engineData.WorldEconomy.GlobalHeat) or {}

    local text = " <RGB:1,1,1> <SIZE:" .. titleSize .. "> GLOBAL INFLATION TRENDS <SIZE:" .. bodySize .. "> <LINE> <LINE> "
    
    local hasTrends = false
    local sortedTags = {}
    for tag, heat in pairs(globalHeat) do
        table.insert(sortedTags, tag)
    end
    table.sort(sortedTags)

    for _, tag in ipairs(sortedTags) do
        local heat = globalHeat[tag]
        if heat ~= 0 then
            hasTrends = true
            local cleanTag = tag
            if tag == "Medical" then cleanTag = "Medical Supplies" end
            
            local color = (heat > 0) and " <RGB:1,0,0> " or " <RGB:0,1,0> " -- Red for Inflation (Bad/Expensive), Green for Deflation (Good/Cheap)
            local sign = (heat > 0) and "+" or ""
            local percent = string.format("%.1f", heat * 100) .. "%"
            
            text = text .. " <RGB:1,0.8,0> • " .. cleanTag .. ": " .. color .. sign .. percent .. " <LINE> "
        end
    end

    if not hasTrends then
        text = text .. " <RGB:0.6,0.6,0.6> No significant global market trends detected. <LINE> "
    end

    self.richText:setText(text)
    self.richText:paginate()
end

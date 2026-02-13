-- ==============================================================================
-- media/lua/client/DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Info.lua
-- Tab: General Information & Economy
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"

DT_FactionInfoTab_Info = ISPanel:derive("DT_FactionInfoTab_Info")

function DT_FactionInfoTab_Info:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}
    return o
end

function DT_FactionInfoTab_Info:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_FactionInfoTab_Info:createChildren()
    self.richText = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.richText:initialise()
    self.richText.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.richText.borderColor = {r=0, g=0, b=0, a=0.0}
    self.richText:addScrollBars()
    self:addChild(self.richText)
end

function DT_FactionInfoTab_Info:updateData(f)
    if not f then 
        self.richText:setText(" <RGB:0.6,0.6,0.6> No faction selected.")
        return 
    end

    local text = " <RGB:1,0.8,0> <SIZE:Medium> " .. f.name .. " <SIZE:Small> <LINE> "
    text = text .. " <RGB:0.6,0.6,0.6> ID: " .. f.id .. " <LINE> <LINE> "
    
    -- Location
    text = text .. " <RGB:0.4,0.8,1> LOCATION DATA: <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Town: " .. tostring(f.town or "N/A") .. " <LINE> "
    if f.homeCoords then
        text = text .. " Base: " .. f.homeCoords.name .. " (" .. f.homeCoords.x .. "," .. f.homeCoords.y .. "," .. f.homeCoords.z .. ") <LINE> "
    else
        text = text .. " Base: NOMADIC (Roaming) <LINE> "
    end
    
    -- Economy
    text = text .. " <LINE> <RGB:0.4,0.8,1> ECONOMIC DATA: <LINE> "
    text = text .. " <RGB:0.2,1,0.2> Wealth: $" .. tostring(f.wealth or 0) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Value Trend: " .. (f.valueTrend or "Stable") .. " <LINE> " -- Adding placeholder for trend if exists
    
    self.richText:setText(text)
    self.richText:paginate()
end

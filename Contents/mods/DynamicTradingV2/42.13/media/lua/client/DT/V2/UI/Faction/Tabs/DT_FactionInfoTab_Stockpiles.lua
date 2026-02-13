-- ==============================================================================
-- media/lua/client/DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Stockpiles.lua
-- Tab: Stockpiles & Resource Data
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"

DT_FactionInfoTab_Stockpiles = ISPanel:derive("DT_FactionInfoTab_Stockpiles")

function DT_FactionInfoTab_Stockpiles:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}
    return o
end

function DT_FactionInfoTab_Stockpiles:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_FactionInfoTab_Stockpiles:createChildren()
    self.richText = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.richText:initialise()
    self.richText.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.richText.borderColor = {r=0, g=0, b=0, a=0.0}
    self.richText:addScrollBars()
    self:addChild(self.richText)
end

function DT_FactionInfoTab_Stockpiles:updateData(f)
    if not f then 
        self.richText:setText("")
        return 
    end

    local text = " <RGB:1,1,1> <SIZE:Medium> KNOWN STOCKPILES <SIZE:Small> <LINE> <LINE> "

    if f.stockpile then
        -- Sort keys for consistent display
        local keys = {}
        for k in pairs(f.stockpile) do table.insert(keys, k) end
        table.sort(keys)
        
        for _, k in ipairs(keys) do
            local v = f.stockpile[k]
            text = text .. " <RGB:0.8,0.8,0.8> - " .. k .. ": <RGB:0.4,0.8,1> " .. v .. " <LINE> "
        end
        
        if #keys == 0 then
             text = text .. " <RGB:0.6,0.6,0.6> Stockpile empty. <LINE> "
        end
    else
        text = text .. " <RGB:0.6,0.6,0.6> No stockpile data available. <LINE> "
    end
    
    self.richText:setText(text)
    self.richText:paginate()
end

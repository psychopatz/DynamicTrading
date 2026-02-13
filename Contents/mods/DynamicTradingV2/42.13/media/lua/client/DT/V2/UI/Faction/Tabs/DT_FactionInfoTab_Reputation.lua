-- ==============================================================================
-- media/lua/client/DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Reputation.lua
-- Tab: Reputation
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"

DT_FactionInfoTab_Reputation = ISPanel:derive("DT_FactionInfoTab_Reputation")

function DT_FactionInfoTab_Reputation:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}
    return o
end

function DT_FactionInfoTab_Reputation:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_FactionInfoTab_Reputation:createChildren()
    self.richText = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.richText:initialise()
    self.richText.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.richText.borderColor = {r=0, g=0, b=0, a=0.0}
    self.richText:addScrollBars()
    self:addChild(self.richText)
end

function DT_FactionInfoTab_Reputation:updateData(f)
    if not f then 
        self.richText:setText("")
        return 
    end

    local text = " <RGB:0.4,0.8,1> <SIZE:Medium> REPUTATION STATUS <SIZE:Small> <LINE> <LINE> "

    if f.reputation and type(f.reputation) == "table" then
        local found = false
        for user, rep in pairs(f.reputation) do
            local color = " <RGB:1,1,1> "
            local status = "Neutral"
            
            if rep >= 50 then 
                color = " <RGB:0.2,1,0.2> "
                status = "Allied"
            elseif rep > 0 then 
                color = " <RGB:0.5,1,0.5> "
                status = "Friendly"
            elseif rep <= -50 then
                color = " <RGB:1,0.2,0.2> "
                status = "Hostile"
            elseif rep < 0 then 
                color = " <RGB:1,0.5,0.5> "
                status = "Unfriendly"
            end
            
            text = text .. " <RGB:0.8,0.8,0.8> " .. user .. ": " .. color .. rep .. " (" .. status .. ") <LINE> "
            found = true
        end
        if not found then text = text .. " <RGB:0.6,0.6,0.6> No player relations recorded. <LINE> " end
    else
        text = text .. " <RGB:0.6,0.6,0.6> No reputation data available. <LINE> "
    end
    
    self.richText:setText(text)
    self.richText:paginate()
end

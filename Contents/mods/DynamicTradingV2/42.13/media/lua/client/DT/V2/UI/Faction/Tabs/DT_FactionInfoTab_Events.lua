-- ==============================================================================
-- media/lua/client/DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Events.lua
-- Tab: Active Events & History (Future)
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"

DT_FactionInfoTab_Events = ISPanel:derive("DT_FactionInfoTab_Events")

function DT_FactionInfoTab_Events:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}
    return o
end

function DT_FactionInfoTab_Events:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_FactionInfoTab_Events:createChildren()
    self.richText = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.richText:initialise()
    self.richText.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.richText.borderColor = {r=0, g=0, b=0, a=0.0}
    self.richText:addScrollBars()
    self.richText:setAnchorRight(true)
    self.richText:setAnchorBottom(true)
    self:addChild(self.richText)
end

function DT_FactionInfoTab_Events:onResize()
    ISPanel.onResize(self)
    if self.richText then
        self.richText:paginate()
    end
end

function DT_FactionInfoTab_Events:updateData(f)
    self.currentFaction = f
    if not f then 
        self.richText:setText("")
        return 
    end

    local scale = "Medium"
    if self.parent and self.parent.parent and self.parent.parent.fontScale then
        scale = self.parent.parent.fontScale
    end

    local titleTag = "Medium"
    local bodyTag = "Small"
    
    if scale == "Large" then
        titleTag = "Large"
        bodyTag = "Medium"
    elseif scale == "Medium" then
        titleTag = "Medium"
        bodyTag = "Small"
    else
        titleTag = "Small"
        bodyTag = "Small"
    end

    local text = " <RGB:1,1,1> <SIZE:" .. titleTag .. "> ACTIVE EVENTS <SIZE:" .. bodyTag .. "> <LINE> <LINE> "

    if f.ActiveFlashEvent and f.ActiveFlashEvent.id then
        local currentHours = getGameTime():getWorldAgeHours()
        local diff = math.max(0, f.ActiveFlashEvent.expires - currentHours)
        
        text = text .. " <RGB:0,1,1> EVENT: " .. f.ActiveFlashEvent.id .. " <LINE> "
        text = text .. " <RGB:0.8,0.8,0.8> Expires in: " .. string.format("%.1f", diff) .. " hours <LINE> "
        
        -- Future: Add description if available in event registry
    else
        text = text .. " <RGB:0.6,0.6,0.6> No active events underway. <LINE> "
    end
    
    self.richText:setText(text)
    self.richText:paginate()
end

-- ==============================================================================
-- media/lua/client/DT/UI/Faction/Tabs/DT_FactionInfoTab_Stockpiles.lua
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
    self.richText:setAnchorRight(true)
    self.richText:setAnchorBottom(true)
    self:addChild(self.richText)
end

function DT_FactionInfoTab_Stockpiles:onResize()
    ISPanel.onResize(self)
    if self.richText then
        self.richText:setWidth(self.width)
        self.richText:setHeight(self.height)
        self.richText:paginate()
    end
end

function DT_FactionInfoTab_Stockpiles:updateData(f)
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

    local text = " <RGB:1,1,1> <SIZE:" .. titleTag .. "> KNOWN STOCKPILES <SIZE:" .. bodyTag .. "> <LINE> <LINE> "

    if f.isV1 then
        text = text .. " <RGB:0.6,0.6,0.6> The Radio Network does not store physical stockpiles. <LINE> Resources are distributed across independent moving trade caravans. <LINE> <LINE> "
        text = text .. " <RGB:0.8,0.8,0.8> Check <RGB:0.4,0.8,1> Economics > Market <RGB:0.8,0.8,0.8> to see global supply and demand modifiers. <LINE> "
    elseif f.stockpile then
        -- 1. Penalties section for stockpiles
        local penalties = {}
        if f.penalties then
            if f.penalties.dehydrated then table.insert(penalties, "DEHYDRATED") end
            if f.penalties.sick then table.insert(penalties, "SICK") end
            if f.penalties.vulnerable then table.insert(penalties, "VULNERABLE") end
            if f.penalties.isolated then table.insert(penalties, "ISOLATED") end
            if f.penalties.decaying then table.insert(penalties, "DECAYING") end
        end
        
        if #penalties > 0 then
             text = text .. " <RGB:1,0,0> ALERT: <RGB:0.8,0.8,0.8> Resource shortages detected. <LINE> <LINE> "
        end

        -- 2. Explicit 6-resource list
        local resOrder = { "food", "water", "meds", "ammo", "fuel", "materials" }
        local resNames = { food = "Food Stock", water = "Fresh Water", meds = "Medical Supplies", ammo = "Ammunition", fuel = "Operational Fuel", materials = "Raw Materials" }
        
        for _, r in ipairs(resOrder) do
            local amt = math.floor(f.stockpile[r] or 0)
            local color = " <RGB:0.8,0.8,0.8> "
            if amt <= 0 then color = " <RGB:1,0,0> " end
            
            text = text .. color .. " - " .. (resNames[r] or r) .. ": <RGB:0.4,0.8,1> " .. amt .. " <LINE> "
        end

    else
        text = text .. " <RGB:0.6,0.6,0.6> No stockpile data available. <LINE> "
    end
    
    if self.richText then
        self.richText:setWidth(self.width)
        self.richText:setHeight(self.height)
        self.richText:setText(text)
        self.richText:paginate()
    end
end

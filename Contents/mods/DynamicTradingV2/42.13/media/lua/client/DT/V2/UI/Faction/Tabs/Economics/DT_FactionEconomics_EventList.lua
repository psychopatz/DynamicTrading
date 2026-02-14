-- ==============================================================================
-- media/lua/client/DT/V2/UI/Faction/Tabs/Economics/DT_FactionEconomics_EventList.lua
-- Sub-Panel: Generic Event List (Flash, Meta, or Seasonal)
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"

DT_FactionEconomics_EventList = ISPanel:derive("DT_FactionEconomics_EventList")

-- mode: "Flash", "Meta", "Seasonal"
function DT_FactionEconomics_EventList:new(x, y, width, height, mode)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}
    
    o.mode = mode or "Flash"
    return o
end

function DT_FactionEconomics_EventList:initialise()
    ISPanel.initialise(self)
end

function DT_FactionEconomics_EventList:createChildren()
    if self.richText then return end

    self.richText = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.richText:initialise()
    self.richText.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.richText.borderColor = {r=0.4, g=0.4, b=0.4, a=0.5}
    self.richText:setAnchorRight(true)
    self.richText:setAnchorBottom(true)
    self.richText:addScrollBars()
    self:addChild(self.richText)
end

function DT_FactionEconomics_EventList:onResize()
    ISPanel.onResize(self)
    if self.richText then
        self.richText:setWidth(self.width)
        self.richText:setHeight(self.height)
        self.richText:paginate()
    end
end

function DT_FactionEconomics_EventList:updateData(f, fontScale)
    if not self.richText then return end
    
    self.currentFaction = f
    if not f then 
        self.richText:setText("") 
        return 
    end

    local scale = fontScale or "Medium"
    local titleSize = (scale == "Large" and "Large") or (scale == "Medium" and "Medium") or "Small"
    local bodySize = (scale == "Large" and "Medium") or "Small"

    local text = ""

    if self.mode == "Flash" then
        text = " <RGB:1,1,1> <SIZE:" .. titleSize .. "> FACTION FLASH EVENTS <SIZE:" .. bodySize .. "> <LINE> <LINE> "
        if f.ActiveFlashEvent and f.ActiveFlashEvent.id then
            local def = DynamicTrading.Events.Registry[f.ActiveFlashEvent.id]
            local currentHours = getGameTime():getWorldAgeHours()
            local diff = math.max(0, f.ActiveFlashEvent.expires - currentHours)
            
            text = text .. self:formatEventDetails(def, diff, bodySize)
        else
            text = text .. " <RGB:0.6,0.6,0.6> No specific faction alerts active. <LINE> "
        end

    elseif self.mode == "Meta" then
        text = " <RGB:1,1,1> <SIZE:" .. titleSize .. "> GLOBAL MEGA-TRENDS <SIZE:" .. bodySize .. "> <LINE> <LINE> "
        local count = 0
        for _, eventDef in ipairs(DynamicTrading.Events.ActiveEvents or {}) do
            if eventDef.type == "meta" then
                text = text .. self:formatEventDetails(eventDef, -1, bodySize) .. " <LINE> "
                count = count + 1
            end
        end
        if count == 0 then
            text = text .. " <RGB:0.6,0.6,0.6> No major global trends affecting the world. <LINE> "
        end

    elseif self.mode == "Seasonal" then
        text = " <RGB:1,1,1> <SIZE:" .. titleSize .. "> SEASONAL SHIFTS <SIZE:" .. bodySize .. "> <LINE> <LINE> "
        local count = 0
        for _, eventDef in ipairs(DynamicTrading.Events.ActiveEvents or {}) do
            if eventDef.type == "seasonal" then
                text = text .. self:formatEventDetails(eventDef, -1, bodySize) .. " <LINE> "
                count = count + 1
            end
        end
        if count == 0 then
            text = text .. " <RGB:0.6,0.6,0.6> Seasonal conditions are currently stable. <LINE> "
        end
    end

    self.richText:setText(text)
    self.richText:paginate()
end

function DT_FactionEconomics_EventList:formatEventDetails(def, expires, size)
    if not def then return " <RGB:1,0,0> [ERROR: Event Definition Missing] <LINE> " end

    local text = " <RGB:0,1,1> " .. (def.name or def.id) .. " <LINE> "
    if expires and expires > 0 then
        text = text .. " <RGB:1,0.8,0> Expires in: " .. string.format("%.1f", expires) .. " hours <LINE> "
    end
    
    if def.description then
        text = text .. " <RGB:0.8,0.8,0.8> " .. def.description .. " <LINE> "
    end

    text = text .. " <LINE> "

    if def.effects then
        text = text .. " <RGB:0.8,0.8,0.8> <SIZE:" .. size .. "> MARKET EFFECTS: <LINE> "
        for tag, impact in pairs(def.effects) do
            local priceStr = ""
            if impact.price then
                local color = (impact.price < 1.0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
                if impact.price == 1.0 then color = " <RGB:1,1,1> " end
                priceStr = "  Price " .. color .. string.format("x%.2f", impact.price)
            end
            
            local volStr = ""
            if impact.vol then
                local color = (impact.vol > 1.0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
                if impact.vol == 1.0 then color = " <RGB:1,1,1> " end
                local separator = (priceStr ~= "") and " <RGB:0.5,0.5,0.5> | " or " "
                volStr = separator .. " <RGB:1,1,1> Volume " .. color .. string.format("x%.2f", impact.vol)
            end
            
            local cleanTag = tag
            if tag == "Medical" then cleanTag = "Medical Supplies" end
            
            text = text .. " <RGB:1,0.8,0> • " .. cleanTag .. ":" .. priceStr .. volStr .. " <LINE> "
        end
        text = text .. " <LINE> "
    end

    if def.factionImpact then
        text = text .. " <RGB:0.8,0.8,0.8> FACTION IMPACTS: <LINE> "
        
        if def.factionImpact.wealthAdd then
            local color = (def.factionImpact.wealthAdd > 0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
            text = text .. " <RGB:1,1,1> • Wealth: " .. color .. (def.factionImpact.wealthAdd > 0 and "+" or "") .. def.factionImpact.wealthAdd .. " <LINE> "
        end

        if def.factionImpact.stabilityAdd then
            local color = (def.factionImpact.stabilityAdd > 0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
            text = text .. " <RGB:1,1,1> • Stability: " .. color .. (def.factionImpact.stabilityAdd > 0 and "+" or "") .. def.factionImpact.stabilityAdd .. " <LINE> "
        end

        if def.factionImpact.stockpileAdd then
            for res, amt in pairs(def.factionImpact.stockpileAdd) do
                local color = (amt > 0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
                local sign = (amt > 0 and "+" or "")
                text = text .. " <RGB:1,1,1> • " .. res:gsub("^%l", string.upper) .. ": " .. color .. sign .. amt .. " <LINE> "
            end
        end
        text = text .. " <LINE> "
    end

    return text
end

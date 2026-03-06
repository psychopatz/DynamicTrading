-- ==============================================================================
-- media/lua/client/DT/UI/Faction/Tabs/Economics/DT_FactionEconomics_EventList.lua
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
    self.richText.autosetheight = false
    self.richText:setMargins(10, 10, 10, 10)
    self.richText.clip = true
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

    -- Fetch Active Events (with MP Fallback)
    local activeEventsList = {}
    local rawList = (DynamicTrading.Events and DynamicTrading.Events.ActiveEvents) or {}
    for _, v in ipairs(rawList) do table.insert(activeEventsList, v) end

    if #activeEventsList == 0 then
        local engine = DynamicTrading_Engine and DynamicTrading_Engine.GetEngineData()
        if engine and engine.EventSystem and engine.EventSystem.activeEvents then
            for id, _ in pairs(engine.EventSystem.activeEvents) do
                if DynamicTrading.Events and DynamicTrading.Events.Registry then
                    local def = DynamicTrading.Events.Registry[id]
                    if def then table.insert(activeEventsList, def) end
                end
            end
        end
    end

    local scale = fontScale or "Medium"
    local titleSize = (scale == "Large" and "Large") or (scale == "Medium" and "Medium") or "Small"
    local bodySize = (scale == "Large" and "Medium") or "Small"

    local text = ""
    local sandbox = SandboxVars and SandboxVars.DynamicTrading or {}
    local metaEnabled = sandbox.AllowMetaEvents ~= false
    local seasonalEnabled = sandbox.AllowSeasonalEvents ~= false

    if self.mode == "Flash" then
        text = " <RGB:1,1,1> <SIZE:" .. titleSize .. "> FACTION FLASH EVENTS <SIZE:" .. bodySize .. "> <LINE> <LINE> "
        local flashEvents = f.ActiveFlashEvents or {}
        if #flashEvents == 0 and f.ActiveFlashEvent and f.ActiveFlashEvent.id then
            flashEvents = {
                {
                    id = f.ActiveFlashEvent.id,
                    expires = f.ActiveFlashEvent.expires or 0
                }
            }
        end

        if #flashEvents > 0 then
            local currentHours = getGameTime():getWorldAgeHours()
            for _, entry in ipairs(flashEvents) do
                if entry and entry.id then
                    local def = DynamicTrading.Events.Registry[entry.id]
                    local diff = math.max(0, (entry.expires or 0) - currentHours)
                    text = text .. self:formatEventDetails(def, diff, bodySize)
                end
            end
        else
            text = text .. " <RGB:0.6,0.6,0.6> No specific faction alerts active. <LINE> "
        end

    elseif self.mode == "Meta" then
        text = " <RGB:1,1,1> <SIZE:" .. titleSize .. "> GLOBAL MEGA-TRENDS <SIZE:" .. bodySize .. "> <LINE> <LINE> "
        if not metaEnabled then
            text = text .. " <RGB:1,0.7,0.2> Meta events are disabled by sandbox settings. <LINE> "
        else
            local count = 0
            for _, eventDef in ipairs(activeEventsList) do
                if eventDef.type == "meta" then
                    text = text .. self:formatEventDetails(eventDef, -1, bodySize) .. " <LINE> "
                    count = count + 1
                end
            end
            if count == 0 then
                text = text .. " <RGB:0.6,0.6,0.6> No major global trends affecting the world. <LINE> "
            end
        end

    elseif self.mode == "Seasonal" then
        text = " <RGB:1,1,1> <SIZE:" .. titleSize .. "> SEASONAL SHIFTS <SIZE:" .. bodySize .. "> <LINE> <LINE> "
        if not seasonalEnabled then
            text = text .. " <RGB:1,0.7,0.2> Seasonal events are disabled by sandbox settings. <LINE> "
        else
            local count = 0
            for _, eventDef in ipairs(activeEventsList) do
                if eventDef.type == "seasonal" then
                    text = text .. self:formatEventDetails(eventDef, -1, bodySize) .. " <LINE> "
                    count = count + 1
                end
            end
            if count == 0 then
                text = text .. " <RGB:0.6,0.6,0.6> Seasonal conditions are currently stable. <LINE> "
            end
        end
    end

    self.richText:setText(text)
    self.richText:paginate()
end

function DT_FactionEconomics_EventList:formatEventDetails(def, expires, size)
    if not def then return " <RGB:1,0,0> [ERROR: Event Definition Missing] <LINE> " end

    local text = ""
    
    -- Format Header based on type
    local typeColor = " <RGB:0,0.8,1> " -- Cyan default
    
    if def.type == "flash" then 
        typeColor = " <RGB:1,0.8,0> " -- Gold
    elseif def.type == "meta" then
        typeColor = " <RGB:0.8,0.4,1> " -- Purple
    elseif def.type == "seasonal" then
        typeColor = " <RGB:0,1,0> " -- Green
    end

    -- EVENT CARD HEADER
    text = text .. " <RGB:0.3,0.3,0.3> ------------------------------------------------------------------------------------------------ <LINE> "
    text = text .. typeColor .. ">> " .. (def.name or def.id) .. " <LINE> "
    
    -- Expiry / Timing
    if expires and expires > 0 then
        local expColor = (expires < 12) and " <RGB:1,0,0> " or " <RGB:0.6,0.6,0.6> "
        text = text .. "    " .. expColor .. "Expires in: " .. string.format("%.1f", expires) .. " hours <LINE> "
    elseif expires == -1 then
         text = text .. "    <RGB:0.6,0.6,0.6> Status: Active <LINE> "
    end
    
    -- Description
    if def.description then
        text = text .. "    <RGB:0.8,0.8,0.8> " .. def.description .. " <LINE> "
    end
    text = text .. " <LINE> "

    -- SECTION 1: MARKET EFFECTS
    if def.effects then
        text = text .. "    <RGB:0.4,0.8,1> [ MARKET INFLUENCE ] <LINE> "
        for tag, impact in pairs(def.effects) do
            local priceStr = ""
            if impact.price then
                local color = (impact.price < 1.0) and " <RGB:0,1,0> " or " <RGB:1,0,0> " -- Green for cheap, Red for expensive
                local arrow = (impact.price < 1.0) and "v" or "^"
                if impact.price == 1.0 then color = " <RGB:0.6,0.6,0.6> " arrow = "-" end
                
                priceStr = "Price " .. color .. arrow .. string.format("x%.2f", impact.price)
            end
            
            local volStr = ""
            if impact.vol then
                local color = (impact.vol > 1.0) and " <RGB:0,1,0> " or " <RGB:1,0,0> " -- Green for more stock
                local arrow = (impact.vol > 1.0) and "^" or "v"
                if impact.vol == 1.0 then color = " <RGB:0.6,0.6,0.6> " arrow = "-" end
                
                local separator = (priceStr ~= "") and " <RGB:0.4,0.4,0.4> | " or " "
                volStr = separator .. " <RGB:0.8,0.8,0.8> Volume " .. color .. arrow .. string.format("x%.2f", impact.vol)
            end
            
            local cleanTag = tag
            if tag == "Medical" then cleanTag = "Medical Supplies" end
            
            text = text .. "    <RGB:0.6,0.6,0.6> * " .. cleanTag .. ":  <RGB:0.8,0.8,0.8> " .. priceStr .. volStr .. " <LINE> "
        end
        text = text .. " <LINE> "
    end

    -- SECTION 2: FACTION IMPACTS
    if def.factionImpact then
        text = text .. "    <RGB:0.8,0.4,1> [ FACTION IMPACT ] <LINE> "
        
        if def.factionImpact.wealthAdd then
            local color = (def.factionImpact.wealthAdd > 0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
            local sign = (def.factionImpact.wealthAdd > 0 and "+" or "")
            text = text .. "    <RGB:0.6,0.6,0.6> * Wealth: " .. color .. sign .. def.factionImpact.wealthAdd .. " <LINE> "
        end

        if def.factionImpact.stabilityAdd then
            local color = (def.factionImpact.stabilityAdd > 0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
            local sign = (def.factionImpact.stabilityAdd > 0 and "+" or "")
            text = text .. "    <RGB:0.6,0.6,0.6> * Stability: " .. color .. sign .. def.factionImpact.stabilityAdd .. " <LINE> "
        end

        if def.factionImpact.stockpileAdd then
            for res, amt in pairs(def.factionImpact.stockpileAdd) do
                local color = (amt > 0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
                local sign = (amt > 0 and "+" or "")
                text = text .. "    <RGB:0.6,0.6,0.6> * " .. res:gsub("^%l", string.upper) .. ": " .. color .. sign .. amt .. " <LINE> "
            end
        end
        text = text .. " <LINE> "
    end
    
    text = text .. " <RGB:0.3,0.3,0.3> ------------------------------------------------------------------------------------------------ <LINE> <LINE> "

    return text
end

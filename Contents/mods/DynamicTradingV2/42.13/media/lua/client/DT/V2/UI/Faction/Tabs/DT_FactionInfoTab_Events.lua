-- ==============================================================================
-- media/lua/client/DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Events.lua
-- Tab: Active Events & History (Detailed Sub-Tabs)
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISTabPanel"

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
end

function DT_FactionInfoTab_Events:createChildren()
    if self.tabs then return end -- Guard against double initialization (ISPanel:initialise calls this)
    
    -- 1. TAB PANEL FOR SUB-TYPES
    self.tabs = ISTabPanel:new(0, 0, self.width, self.height)
    self.tabs:initialise()
    self.tabs.backgroundColor = {r=0, g=0, b=0, a=0}
    self.tabs.borderColor = {r=0.4, g=0.4, b=0.4, a=0.5}
    self.tabs:setAnchorRight(true)
    self.tabs:setAnchorBottom(true)
    self:addChild(self.tabs)

    -- 2. CREATE SUB-PANELS (Flash, Meta, Seasonal)
    self.flashPanel = ISRichTextPanel:new(0, 0, self.tabs.width, self.tabs.height - self.tabs.tabHeight)
    self.flashPanel:initialise()
    self.flashPanel.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.flashPanel:addScrollBars()
    self.tabs:addView("Flash", self.flashPanel)

    self.metaPanel = ISRichTextPanel:new(0, 0, self.tabs.width, self.tabs.height - self.tabs.tabHeight)
    self.metaPanel:initialise()
    self.metaPanel.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.metaPanel:addScrollBars()
    self.tabs:addView("Meta", self.metaPanel)

    self.seasonalPanel = ISRichTextPanel:new(0, 0, self.tabs.width, self.tabs.height - self.tabs.tabHeight)
    self.seasonalPanel:initialise()
    self.seasonalPanel.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.seasonalPanel:addScrollBars()
    self.tabs:addView("Seasonal", self.seasonalPanel)
end

function DT_FactionInfoTab_Events:onResize()
    ISPanel.onResize(self)
    if self.flashPanel then self.flashPanel:paginate() end
    if self.metaPanel then self.metaPanel:paginate() end
    if self.seasonalPanel then self.seasonalPanel:paginate() end
end

function DT_FactionInfoTab_Events:updateData(f)
    if not self.flashPanel then return end -- Ensure children are created
    self.currentFaction = f
    if not f then 
        self.flashPanel:setText("")
        self.metaPanel:setText("")
        self.seasonalPanel:setText("")
        return 
    end

    local scale = "Medium"
    if self.parent and self.parent.parent and self.parent.parent.fontScale then
        scale = self.parent.parent.fontScale
    end

    local titleSize = (scale == "Large" and "Large") or (scale == "Medium" and "Medium") or "Small"
    local bodySize = (scale == "Large" and "Medium") or "Small"

    -- 1. PROCESS FLASH EVENTS (Faction Specific)
    local flashText = " <RGB:1,1,1> <SIZE:" .. titleSize .. "> FACTION FLASH EVENTS <SIZE:" .. bodySize .. "> <LINE> <LINE> "
    if f.ActiveFlashEvent and f.ActiveFlashEvent.id then
        local def = DynamicTrading.Events.Registry[f.ActiveFlashEvent.id]
        local currentHours = getGameTime():getWorldAgeHours()
        local diff = math.max(0, f.ActiveFlashEvent.expires - currentHours)
        
        flashText = flashText .. self:formatEventDetails(def, diff, bodySize)
    else
        flashText = flashText .. " <RGB:0.6,0.6,0.6> No specific faction alerts active. <LINE> "
    end
    self.flashPanel:setText(flashText)
    self.flashPanel:paginate()

    -- 2. PROCESS META & SEASONAL (Global)
    local metaText = " <RGB:1,1,1> <SIZE:" .. titleSize .. "> GLOBAL MEGA-TRENDS <SIZE:" .. bodySize .. "> <LINE> <LINE> "
    local seasonalText = " <RGB:1,1,1> <SIZE:" .. titleSize .. "> SEASONAL SHIFTS <SIZE:" .. bodySize .. "> <LINE> <LINE> "
    
    local metaCount = 0
    local seasonalCount = 0

    for _, eventDef in ipairs(DynamicTrading.Events.ActiveEvents or {}) do
        if eventDef.type == "meta" then
            metaText = metaText .. self:formatEventDetails(eventDef, -1, bodySize) .. " <LINE> "
            metaCount = metaCount + 1
        elseif eventDef.type == "seasonal" then
            seasonalText = seasonalText .. self:formatEventDetails(eventDef, -1, bodySize) .. " <LINE> "
            seasonalCount = seasonalCount + 1
        end
    end

    if metaCount == 0 then
        metaText = metaText .. " <RGB:0.6,0.6,0.6> No major global trends affecting the world. <LINE> "
    end
    if seasonalCount == 0 then
        seasonalText = seasonalText .. " <RGB:0.6,0.6,0.6> Seasonal conditions are currently stable. <LINE> "
    end

    self.metaPanel:setText(metaText)
    self.metaPanel:paginate()
    self.seasonalPanel:setText(seasonalText)
    self.seasonalPanel:paginate()
end

function DT_FactionInfoTab_Events:formatEventDetails(def, expires, size)
    if not def then return " <RGB:1,0,0> [ERROR: Event Definition Missing] <LINE> " end

    local text = " <RGB:0,1,1> " .. (def.name or def.id) .. " <LINE> "
    if expires and expires > 0 then
        text = text .. " <RGB:1,0.8,0> Expires in: " .. string.format("%.1f", expires) .. " hours <LINE> "
    end
    
    if def.description then
        text = text .. " <RGB:0.8,0.8,0.8> " .. def.description .. " <LINE> "
    end

    text = text .. " <LINE> "

    -- A. ECONOMY IMPACTS (Multipliers)
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

            text = text .. " <RGB:1,0.8,0> • " .. tag .. ":" .. priceStr .. volStr .. " <LINE> "
        end
        text = text .. " <LINE> "
    end

    -- B. FACTION IMPACTS (Resource changes)
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

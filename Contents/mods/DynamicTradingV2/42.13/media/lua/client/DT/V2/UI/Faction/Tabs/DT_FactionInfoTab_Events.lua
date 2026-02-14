-- ==============================================================================
-- media/lua/client/DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Events.lua
-- Tab: Active Events & History (Side-by-Side Layout)
-- Left: Event Details (Tabs) | Right: Cumulative Summary
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
    if self.tabs then return end -- Guard against double initialization

    local gap = 10
    local summaryWidth = 350 -- Fixed width for summary panel
    
    -- Calculate dimensions
    local tabWidth = self.width - summaryWidth - gap
    local panelHeight = self.height

    -- 1. LEFT SIDE: TAB PANEL FOR EVENT DETAILS
    self.tabs = ISTabPanel:new(0, 0, tabWidth, panelHeight)
    self.tabs:initialise()
    self.tabs.backgroundColor = {r=0, g=0, b=0, a=0}
    self.tabs.borderColor = {r=0.4, g=0.4, b=0.4, a=0.5}
    self.tabs:setAnchorRight(false)
    self.tabs:setAnchorLeft(true)
    self.tabs:setAnchorTop(true)
    self.tabs:setAnchorBottom(true)
    self:addChild(self.tabs)

    -- Calculate content height for sub-panels
    local contentH = panelHeight - self.tabs.tabHeight

    -- Create Sub-Panels (Flash, Meta, Seasonal)
    self.flashPanel = ISRichTextPanel:new(0, 0, tabWidth, contentH)
    self.flashPanel:initialise()
    self.flashPanel.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.flashPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=0.3}
    self.flashPanel:addScrollBars()
    self.tabs:addView("Flash", self.flashPanel)

    self.metaPanel = ISRichTextPanel:new(0, 0, tabWidth, contentH)
    self.metaPanel:initialise()
    self.metaPanel.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.metaPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=0.3}
    self.metaPanel:addScrollBars()
    self.tabs:addView("Meta", self.metaPanel)

    self.seasonalPanel = ISRichTextPanel:new(0, 0, tabWidth, contentH)
    self.seasonalPanel:initialise()
    self.seasonalPanel.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.seasonalPanel.borderColor = {r=0.4, g=0.4, b=0.4, a=0.3}
    self.seasonalPanel:addScrollBars()
    self.tabs:addView("Seasonal", self.seasonalPanel)

    -- 2. RIGHT SIDE: SUMMARY PANEL
    local summaryX = tabWidth + gap
    self.summaryPanel = ISRichTextPanel:new(summaryX, 0, summaryWidth, panelHeight)
    self.summaryPanel:initialise()
    self.summaryPanel.backgroundColor = {r=0.1, g=0.1, b=0.1, a=0.9}
    self.summaryPanel.borderColor = {r=0.5, g=0.5, b=0.5, a=1.0}
    self.summaryPanel:setAnchorRight(true)
    self.summaryPanel:setAnchorLeft(false)
    self.summaryPanel:setAnchorTop(true)
    self.summaryPanel:setAnchorBottom(true)
    self.summaryPanel:addScrollBars()
    self:addChild(self.summaryPanel)
end

function DT_FactionInfoTab_Events:onResize()
    ISPanel.onResize(self)
    
    local gap = 10
    local summaryWidth = 350
    local tabWidth = self.width - summaryWidth - gap
    local panelHeight = self.height

    -- Resize Tab Panel
    if self.tabs then
        self.tabs:setWidth(tabWidth)
        self.tabs:setHeight(panelHeight)
        
        -- Manually resize all sub-panels inside tabs
        local contentH = panelHeight - self.tabs.tabHeight
        local contentW = tabWidth
        
        local subPanels = {self.flashPanel, self.metaPanel, self.seasonalPanel}
        for _, panel in ipairs(subPanels) do
            if panel then
                panel:setWidth(contentW)
                panel:setHeight(contentH)
                panel:paginate()
            end
        end
    end

    -- Resize Summary Panel
    if self.summaryPanel then
        local summaryX = tabWidth + gap
        self.summaryPanel:setX(summaryX)
        self.summaryPanel:setWidth(summaryWidth)
        self.summaryPanel:setHeight(panelHeight)
        self.summaryPanel:paginate()
    end
end

function DT_FactionInfoTab_Events:prerender()
    ISPanel.prerender(self)
    
    -- Draw vertical separation line between panels
    if self.tabs and self.summaryPanel then
        local lineX = self.tabs:getWidth() + 5
        self:drawRect(lineX, 0, 1, self.height, 1.0, 0.5, 0.5, 0.5)
    end
end

function DT_FactionInfoTab_Events:updateData(f)
    if not self.flashPanel then return end
    self.currentFaction = f
    if not f then 
        self.flashPanel:setText("")
        self.metaPanel:setText("")
        self.seasonalPanel:setText("")
        self.summaryPanel:setText("")
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

    -- 3. CUMULATIVE SUMMARY (Right Panel)
    self:updateSummary(f, titleSize, bodySize)
end

function DT_FactionInfoTab_Events:updateSummary(f, titleSize, bodySize)
    local activeDefs = {}
    
    -- Gather all active definitions
    for _, def in ipairs(DynamicTrading.Events.ActiveEvents or {}) do
        table.insert(activeDefs, def)
    end
    if f.ActiveFlashEvent and f.ActiveFlashEvent.id then
        local def = DynamicTrading.Events.Registry[f.ActiveFlashEvent.id]
        if def then table.insert(activeDefs, def) end
    end

    if #activeDefs == 0 then
        self.summaryPanel:setText(" <RGB:0.6,0.6,0.6> <SIZE:" .. bodySize .. "> No stacked event effects at this time. <LINE> ")
        self.summaryPanel:paginate()
        return
    end

    -- Math Accumulators
    local totalMultipliers = {}
    local totalImpacts = { wealth = 0, stability = 0, stock = {} }

    for _, def in ipairs(activeDefs) do
        if def.effects then
            for tag, impact in pairs(def.effects) do
                if not totalMultipliers[tag] then totalMultipliers[tag] = { price = 1.0, vol = 1.0 } end
                if impact.price then totalMultipliers[tag].price = totalMultipliers[tag].price * impact.price end
                if impact.vol then totalMultipliers[tag].vol = totalMultipliers[tag].vol * impact.vol end
            end
        end

        if def.factionImpact then
            if def.factionImpact.wealthAdd then totalImpacts.wealth = totalImpacts.wealth + def.factionImpact.wealthAdd end
            if def.factionImpact.stabilityAdd then totalImpacts.stability = totalImpacts.stability + def.factionImpact.stabilityAdd end
            if def.factionImpact.stockpileAdd then
                for res, amt in pairs(def.factionImpact.stockpileAdd) do
                    totalImpacts.stock[res] = (totalImpacts.stock[res] or 0) + amt
                end
            end
        end
    end

    local text = " <RGB:1,1,1> <SIZE:" .. titleSize .. "> CUMULATIVE IMPACT <SIZE:" .. bodySize .. "> <LINE> <LINE> "
    
    local hasMarket = false
    local marketText = " <RGB:0.8,0.8,0.8> MARKET SHIFTS <LINE> "
    for tag, multi in pairs(totalMultipliers) do
        if multi.price ~= 1.0 or multi.vol ~= 1.0 then
            hasMarket = true
            
            local tagLine = "  <RGB:1,0.8,0> • " .. tag .. " <LINE> "
            
            if multi.price ~= 1.0 then
                local color = (multi.price < 1.0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
                tagLine = tagLine .. "    <RGB:0.7,0.7,0.7> Price:" .. color .. string.format("x%.2f", multi.price) .. " <LINE> "
            end
            
            if multi.vol ~= 1.0 then
                local color = (multi.vol > 1.0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
                tagLine = tagLine .. "    <RGB:0.7,0.7,0.7> Volume:" .. color .. string.format("x%.2f", multi.vol) .. " <LINE> "
            end
            
            marketText = marketText .. tagLine
        end
    end
    if hasMarket then text = text .. marketText .. " <LINE> " end

    local hasImpact = (totalImpacts.wealth ~= 0 or totalImpacts.stability ~= 0)
    for _, _ in pairs(totalImpacts.stock) do hasImpact = true break end

    if hasImpact then
        text = text .. " <RGB:0.8,0.8,0.8> FACTION IMPACTS <LINE> "
        if totalImpacts.wealth ~= 0 then
            local color = (totalImpacts.wealth > 0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
            text = text .. "  <RGB:1,1,1> • Wealth: " .. color .. (totalImpacts.wealth > 0 and "+" or "") .. totalImpacts.wealth .. " <LINE> "
        end
        if totalImpacts.stability ~= 0 then
            local color = (totalImpacts.stability > 0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
            text = text .. "  <RGB:1,1,1> • Stability: " .. color .. (totalImpacts.stability > 0 and "+" or "") .. totalImpacts.stability .. " <LINE> "
        end
        for res, amt in pairs(totalImpacts.stock) do
            if amt ~= 0 then
                local color = (amt > 0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
                text = text .. "  <RGB:1,1,1> • " .. res:gsub("^%l", string.upper) .. ": " .. color .. (amt > 0 and "+" or "") .. amt .. " <LINE> "
            end
        end
    end

    self.summaryPanel:setText(text)
    self.summaryPanel:paginate()
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
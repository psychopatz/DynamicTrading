-- ==============================================================================
-- media/lua/client/DT/V2/UI/Faction/Tabs/Economics/DT_FactionEconomics_Market.lua
-- Sub-Panel: Market Multipliers (Events + Inflation)
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"

DT_FactionEconomics_Market = ISPanel:derive("DT_FactionEconomics_Market")

function DT_FactionEconomics_Market:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}
    return o
end

function DT_FactionEconomics_Market:initialise()
    ISPanel.initialise(self)
end

function DT_FactionEconomics_Market:createChildren()
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

function DT_FactionEconomics_Market:onResize()
    ISPanel.onResize(self)
    if self.richText then
        self.richText:setWidth(self.width)
        self.richText:setHeight(self.height)
        self.richText:paginate()
    end
end

function DT_FactionEconomics_Market:updateData(f, fontScale)
    if not self.richText then return end
    
    local scale = fontScale or "Medium"
    local titleSize = (scale == "Large" and "Large") or (scale == "Medium" and "Medium") or "Small"
    local bodySize = (scale == "Large" and "Medium") or "Small"

    if not f then 
        self.richText:setText("") 
        return 
    end

    -- 1. Gather Data
    local activeDefs = {}
    for _, def in ipairs(DynamicTrading.Events.ActiveEvents or {}) do
        table.insert(activeDefs, def)
    end
    if f.ActiveFlashEvent and f.ActiveFlashEvent.id then
        local def = DynamicTrading.Events.Registry[f.ActiveFlashEvent.id]
        if def then table.insert(activeDefs, def) end
    end

    -- 2. Get Global Heat (Inflation/Deflation)
    local engineData = DynamicTrading_Engine and DynamicTrading_Engine.GetEngineData()
    local globalHeat = (engineData and engineData.WorldEconomy and engineData.WorldEconomy.GlobalHeat) or {}

    -- 3. Calculate Cumulative Multipliers
    local totalMultipliers = {}
    
    -- A. Apply Events
    for _, def in ipairs(activeDefs) do
         if def.effects then
            for tag, impact in pairs(def.effects) do
                if not totalMultipliers[tag] then totalMultipliers[tag] = { price = 1.0, vol = 1.0, eventPrice = 1.0, heatPrice = 1.0 } end
                
                if impact.price then 
                    totalMultipliers[tag].price = totalMultipliers[tag].price * impact.price 
                    totalMultipliers[tag].eventPrice = totalMultipliers[tag].eventPrice * impact.price
                end
                
                if impact.vol then 
                    totalMultipliers[tag].vol = totalMultipliers[tag].vol * impact.vol 
                end
            end
        end
    end

    -- B. Apply Inflation (Heat) to existing tags AND any tags with only Heat
    for tag, heat in pairs(globalHeat) do
        if heat ~= 0 then
            if not totalMultipliers[tag] then totalMultipliers[tag] = { price = 1.0, vol = 1.0, eventPrice = 1.0, heatPrice = 1.0 } end
            
            local heatMult = (1.0 + heat)
            totalMultipliers[tag].price = totalMultipliers[tag].price * heatMult
            totalMultipliers[tag].heatPrice = heatMult
        end
    end

    -- 4. Build Text
    local text = " <RGB:1,1,1> <SIZE:" .. titleSize .. "> MARKET MULTIPLIERS <SIZE:" .. bodySize .. "> <LINE> <RGB:0.7,0.7,0.7> (Events x Inflation) <LINE> <LINE> "
    
    local isEmpty = true
    for _, _ in pairs(totalMultipliers) do
        isEmpty = false
        break
    end

    if isEmpty then
         text = text .. " <RGB:0.6,0.6,0.6> No active market deviations. Market is stable. <LINE> "
    else
        for tag, multi in pairs(totalMultipliers) do
            if multi.price ~= 1.0 or multi.vol ~= 1.0 then
                
                local cleanTag = tag
                if tag == "Medical" then cleanTag = "Medical Supplies" end
                
                local tagLine = " <RGB:1,0.8,0> • " .. cleanTag .. " <LINE> "
                
                -- Price Line
                if multi.price ~= 1.0 then
                    local color = (multi.price < 1.0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
                    
                    local breakdown = ""
                    if multi.eventPrice ~= 1.0 or multi.heatPrice ~= 1.0 then
                        breakdown = " <RGB:0.5,0.5,0.5> ("
                        if multi.eventPrice ~= 1.0 then 
                            breakdown = breakdown .. "Evt:x" .. string.format("%.2f", multi.eventPrice) 
                        end
                        if multi.heatPrice ~= 1.0 then
                             if multi.eventPrice ~= 1.0 then breakdown = breakdown .. " * " end
                             breakdown = breakdown .. "Inf:x" .. string.format("%.2f", multi.heatPrice)
                        end
                         breakdown = breakdown .. ")"
                    end
                    
                    tagLine = tagLine .. "    <RGB:0.8,0.8,0.8> Price:" .. color .. string.format("x%.2f", multi.price) .. breakdown .. " <LINE> "
                end
                
                -- Volume Line
                if multi.vol ~= 1.0 then
                    local color = (multi.vol > 1.0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
                    tagLine = tagLine .. "    <RGB:0.8,0.8,0.8> Volume:" .. color .. string.format("x%.2f", multi.vol) .. " <LINE> "
                end
                
                text = text .. tagLine
            end
        end
    end
    
    text = text .. " <LINE> "
    
    -- 5. Faction Impacts (Wealth/Stability/Stock) - moved here or stay in Summary?
    -- The user requested "Market" to calculate multipliers. 
    -- The "Events" tab calculates explicit Faction Impacts. 
    -- Let's put the Faction specific impacts (Wealth diffs) here too as a summary?
    -- Actually, keep it focused on Market Pricing/Volume. 
    -- Faction Impacts are better suited for the "Info" or "Events" tab? 
    -- The prompt said: "Market(Calculates the total Multiplier of the current event + inflation/deflation)"
    -- So I will stick to multipliers here.

    self.richText:setText(text)
    self.richText:paginate()
end

-- ==============================================================================
-- media/lua/client/DT/UI/Faction/Tabs/Economics/DT_FactionEconomics_Market.lua
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
    self.richText.autosetheight = false
    self.richText:setMargins(10, 10, 10, 10)
    self.richText.clip = true
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
    -- 1. Gather Data
    local activeDefs = {}
    local sourceList = {}
    
    -- [V1 SUPPORT]
    if DynamicTrading and DynamicTrading.Events and DynamicTrading.Events.ActiveEvents then
        for _, v in ipairs(DynamicTrading.Events.ActiveEvents) do 
            table.insert(sourceList, v) 
        end
    end

    -- [V2 SUPPORT] (Fallback or combined)
    if DynamicTrading_Engine and DynamicTrading_Engine.GetEngineData then
        local engine = DynamicTrading_Engine.GetEngineData()
        if engine and engine.EventSystem and engine.EventSystem.activeEvents then
            for id, _ in pairs(engine.EventSystem.activeEvents) do
                if DynamicTrading.Events and DynamicTrading.Events.Registry then
                    local def = DynamicTrading.Events.Registry[id]
                    if def then 
                        -- Avoid duplicates if V1 and V2 are somehow both active
                        local found = false
                        for _, existing in ipairs(sourceList) do
                             if existing.id == id then found = true break end
                        end
                        if not found then table.insert(sourceList, def) end
                    end
                end
            end
        end
    end

    for _, def in ipairs(sourceList) do
        table.insert(activeDefs, def)
    end

    -- Faction Specific Events (V2)
    local flashEvents = f.ActiveFlashEvents or {}
    if #flashEvents == 0 and f.ActiveFlashEvent and f.ActiveFlashEvent.id then
        flashEvents = {
            {
                id = f.ActiveFlashEvent.id,
                expires = f.ActiveFlashEvent.expires or 0
            }
        }
    end

    for _, entry in ipairs(flashEvents) do
        if entry and entry.id and DynamicTrading.Events and DynamicTrading.Events.Registry then
            local def = DynamicTrading.Events.Registry[entry.id]
            if def then table.insert(activeDefs, def) end
        end
    end

    -- 2. Get Global Heat (Inflation/Deflation)
    local globalHeat = {}
    
    -- [V1 HEAT]
    if DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.GetData then
        local data = DynamicTrading.Manager.GetData()
        if data and data.globalHeat then
            for k, v in pairs(data.globalHeat) do globalHeat[k] = v end
        end
    end
    
    -- [V2 HEAT] (Merge/Overlay)
    if DynamicTrading_Engine and DynamicTrading_Engine.GetEngineData then
        local engine = DynamicTrading_Engine.GetEngineData()
        local v2Heat = (engine and engine.WorldEconomy and engine.WorldEconomy.GlobalHeat)
        if v2Heat then
            for k, v in pairs(v2Heat) do 
                -- If both exist, we could average or just take V2? 
                -- Usually only one system is active. V2 takes precedence for shared tags.
                globalHeat[k] = v 
            end
        end
    end
    
    -- Count affected categories
    local activeCats = 0
    for _, heat in pairs(globalHeat) do 
        if math.abs(heat) > 0.01 then activeCats = activeCats + 1 end
    end

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

    -- 4. Build Text (Dashboard Style)
    local text = " <RGB:0.9,0.9,0.9> <SIZE:" .. titleSize .. "> GLOBAL MARKET DASHBOARD <SIZE:" .. bodySize .. "> <LINE> "
    
    -- HEADER STATS
    text = text .. " <RGB:0.3,0.3,0.3> ------------------------------------------------------------------------------------------------ <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Active Events: <RGB:1,1,1> " .. #activeDefs
    text = text .. "    <RGB:0.4,0.4,0.4> | <RGB:0.8,0.8,0.8> Inflation Impact: <RGB:1,1,1> " .. activeCats .. " Categories"
    text = text .. "    <RGB:0.4,0.4,0.4> | <RGB:0.8,0.8,0.8> Status: " .. ((#activeDefs > 0 or activeCats > 0) and " <RGB:1,0.5,0> VOLATILE " or " <RGB:0,1,0> STABLE ") .. " <LINE> "
    text = text .. " <RGB:0.3,0.3,0.3> ------------------------------------------------------------------------------------------------ <LINE> <LINE> "
    
    local isEmpty = true
    for _, _ in pairs(totalMultipliers) do
        isEmpty = false
        break
    end

    if isEmpty then
        text = text .. " <RGB:0.6,0.6,0.6> <CENTER> No active market deviations. Prices and volumes are at baseline levels. <LINE> "
    else
        text = text .. " <RGB:1,0.8,0> DETAILED MARKET MULTIPLIERS (Events x Inflation) <LINE> "
        
        -- Sort keys alphabetically
        local sortedTags = {}
        for k in pairs(totalMultipliers) do table.insert(sortedTags, k) end
        table.sort(sortedTags)

        for _, tag in ipairs(sortedTags) do
            local multi = totalMultipliers[tag]
            if multi.price ~= 1.0 or multi.vol ~= 1.0 then
                
                local cleanTag = tag
                if tag == "Medical" then cleanTag = "Medical Supplies" end
                
                -- Header with Background simulation (using dark grey text asbg?) - No, just indent.
                text = text .. " <RGB:0.4,0.8,1> * " .. cleanTag .. " <LINE> "
                
                -- Price Line
                if multi.price ~= 1.0 then
                    local color = (multi.price < 1.0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
                    local arrow = (multi.price < 1.0) and "v" or "^"
                    
                    local breakdown = ""
                    if multi.eventPrice ~= 1.0 or multi.heatPrice ~= 1.0 then
                        breakdown = " <RGB:0.5,0.5,0.5>   ("
                        if multi.eventPrice ~= 1.0 then
                            local eCol = (multi.eventPrice < 1.0) and " <RGB:0,1,0> " or " <RGB:1,0.5,0.5> "
                            breakdown = breakdown .. "Event:" .. eCol .. string.format("x%.2f", multi.eventPrice) .. " <RGB:0.5,0.5,0.5> "
                        end
                        if multi.heatPrice ~= 1.0 then
                            if multi.eventPrice ~= 1.0 then breakdown = breakdown .. "| " end
                            local hCol = (multi.heatPrice < 1.0) and " <RGB:0,1,0> " or " <RGB:1,0.5,0.5> "
                            breakdown = breakdown .. "Inflation:" .. hCol .. string.format("x%.2f", multi.heatPrice)
                        end
                        
                        breakdown = breakdown .. " <RGB:0.5,0.5,0.5> )"
                    end
                    
                    text = text .. "      <RGB:0.8,0.8,0.8> Price: " .. color .. string.format("x%.2f", multi.price) .. " " .. arrow .. breakdown .. " <LINE> "
                end
                
                -- Volume Line
                if multi.vol ~= 1.0 then
                    local color = (multi.vol > 1.0) and " <RGB:0,1,0> " or " <RGB:1,0,0> "
                    local arrow = (multi.vol > 1.0) and "^" or "v"
                    text = text .. "      <RGB:0.8,0.8,0.8> Volume: " .. color .. string.format("x%.2f", multi.vol) .. " " .. arrow .. " <LINE> "
                end
                
                text = text .. " <LINE> "
            end
        end
    end
    
    self.richText:setText(text)
    self.richText:paginate()
end

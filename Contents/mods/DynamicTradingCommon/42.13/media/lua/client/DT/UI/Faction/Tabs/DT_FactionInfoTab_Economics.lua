-- ==============================================================================
-- media/lua/client/DT/UI/Faction/Tabs/DT_FactionInfoTab_Economics.lua
-- Tab: ECONOMICS (Flash, Meta, Seasonal, Market, Trends)
-- Flat layout as requested.
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISTabPanel"
require "DT/UI/Faction/Tabs/Economics/DT_FactionEconomics_EventList"
require "DT/UI/Faction/Tabs/Economics/DT_FactionEconomics_Market"
require "DT/UI/Faction/Tabs/Economics/DT_FactionEconomics_Trends"

DT_FactionInfoTab_Economics = ISPanel:derive("DT_FactionInfoTab_Economics")

function DT_FactionInfoTab_Economics:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}
    return o
end

function DT_FactionInfoTab_Economics:initialise()
    ISPanel.initialise(self)
end

function DT_FactionInfoTab_Economics:createChildren()
    if self.tabs then return end 

    -- Main Tab Panel for Sub-Sections
    self.tabs = ISTabPanel:new(0, 0, self.width, self.height)
    self.tabs:initialise()
    self.tabs.backgroundColor = {r=0, g=0, b=0, a=0}
    self.tabs.borderColor = {r=0.4, g=0.4, b=0.4, a=0.5}
    self.tabs:setAnchorRight(true)
    self.tabs:setAnchorLeft(true)
    self.tabs:setAnchorTop(true)
    self.tabs:setAnchorBottom(true)
    self:addChild(self.tabs)

    -- Calculate content height
    local contentH = self.height - self.tabs.tabHeight
    local contentW = self.width

    -- 1. Market (Default View)
    self.marketPanel = DT_FactionEconomics_Market:new(0, 0, contentW, contentH)
    self.marketPanel:initialise()
    self.tabs:addView("Market", self.marketPanel)

    -- 2. Flash
    self.flashPanel = DT_FactionEconomics_EventList:new(0, 0, contentW, contentH, "Flash")
    self.flashPanel:initialise()
    self.tabs:addView("Flash", self.flashPanel)

    -- 3. Meta
    self.metaPanel = DT_FactionEconomics_EventList:new(0, 0, contentW, contentH, "Meta")
    self.metaPanel:initialise()
    self.tabs:addView("Meta", self.metaPanel)

    -- 4. Seasonal
    self.seasonalPanel = DT_FactionEconomics_EventList:new(0, 0, contentW, contentH, "Seasonal")
    self.seasonalPanel:initialise()
    self.tabs:addView("Seasonal", self.seasonalPanel)


    -- 5. Trends
    self.trendsPanel = DT_FactionEconomics_Trends:new(0, 0, contentW, contentH)
    self.trendsPanel:initialise()
    self.tabs:addView("Trends", self.trendsPanel)
end

function DT_FactionInfoTab_Economics:onResize()
    ISPanel.onResize(self)
    
    if self.tabs then
        self.tabs:setWidth(self.width)
        self.tabs:setHeight(self.height)
        
        -- Resize Content Panels
        local activeView = self.tabs:getActiveView()
        if activeView then
            activeView:setWidth(self.width)
            activeView:setHeight(self.height - self.tabs.tabHeight)
            if activeView.onResize then activeView:onResize() end
        end
    end
end

function DT_FactionInfoTab_Economics:updateData(f)
    self.currentFaction = f
    
    if self.flashPanel then self.flashPanel:updateData(f, self:getFontScale()) end
    if self.metaPanel then self.metaPanel:updateData(f, self:getFontScale()) end
    if self.seasonalPanel then self.seasonalPanel:updateData(f, self:getFontScale()) end
    if self.marketPanel then self.marketPanel:updateData(f, self:getFontScale()) end
    if self.trendsPanel then self.trendsPanel:updateData(f, self:getFontScale()) end
end

-- Helper to get font scale from parent window
function DT_FactionInfoTab_Economics:getFontScale()
    if self.parent and self.parent.parent and self.parent.parent.fontScale then
        return self.parent.parent.fontScale
    end
    return "Medium"
end

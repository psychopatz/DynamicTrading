-- ==============================================================================
-- DT_V2_RadarHeaderPanel.lua
-- Displays title and range info for the Radar Window.
-- ==============================================================================

require "ISUI/ISPanel"

DT_V2_RadarHeaderPanel = ISPanel:derive("DT_V2_RadarHeaderPanel")

function DT_V2_RadarHeaderPanel:initialise()
    ISPanel.initialise(self)
end

function DT_V2_RadarHeaderPanel:createChildren()
    ISPanel.createChildren(self)

    -- Title
    self.labelTitle = ISLabel:new(self.width/2, 5, 25, "TRADER RADAR", 1, 1, 1, 1, UIFont.Medium, true)
    self.labelTitle:initialise()
    self:addChild(self.labelTitle)

    -- Device Name Label (New)
    self.lblDeviceName = ISLabel:new(self.width/2, 24, 18, "Device: Unknown", 1, 1, 1, 1, UIFont.Small, true)
    self.lblDeviceName:initialise()
    self:addChild(self.lblDeviceName)

    -- Broadcast Range Label
    self.lblRangeInfo = ISLabel:new(self.width/2, 43, 18, "Broadcast Range: Unknown", 0.7, 0.7, 0.7, 1, UIFont.Small, true)
    self.lblRangeInfo:initialise()
    self:addChild(self.lblRangeInfo)

    -- Category Tabs (Health Panel Style)
    local tabHeight = 20
    local tabY = self.height - tabHeight
    local tabWidth = self.width / 4 -- Changed from 3 to 4 to accommodate Location tab

    self.btnStat = ISButton:new(0, tabY, tabWidth, tabHeight, "Stationary", self, function(self) self:onCategoryClick("Stationary") end)
    self.btnStat:initialise()
    self.btnStat.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.btnStat:setAnchorTop(false)
    self.btnStat:setAnchorBottom(true)
    self:addChild(self.btnStat)

    self.btnCall = ISButton:new(tabWidth, tabY, tabWidth, tabHeight, "Callable", self, function(self) self:onCategoryClick("Callable") end)
    self.btnCall:initialise()
    self.btnCall.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.btnCall:setAnchorTop(false)
    self.btnCall:setAnchorBottom(true)
    self:addChild(self.btnCall)

    self.btnQuest = ISButton:new(tabWidth * 2, tabY, tabWidth, tabHeight, "Quest", self, function(self) self:onCategoryClick("Quest") end)
    self.btnQuest:initialise()
    self.btnQuest.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.btnQuest:setAnchorTop(false)
    self.btnQuest:setAnchorBottom(true)
    self:addChild(self.btnQuest)
    
    -- New Location Tab
    self.btnLoc = ISButton:new(tabWidth * 3, tabY, tabWidth, tabHeight, "Location", self, function(self) self:onCategoryClick("Location") end)
    self.btnLoc:initialise()
    self.btnLoc.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.btnLoc:setAnchorTop(false)
    self.btnLoc:setAnchorBottom(true)
    self:addChild(self.btnLoc)
end

function DT_V2_RadarHeaderPanel:onCategoryClick(category)
    if self.parent and self.parent.setCategory then
        self.parent:setCategory(category)
    end
end

function DT_V2_RadarHeaderPanel:prerender()
    ISPanel.prerender(self)
    
    local function centerLabel(lbl, font)
        if not lbl then return end
        local text = lbl.name or ""
        local width = getTextManager():MeasureStringX(font, text)
        lbl:setX( (self.width / 2) - (width / 2) )
    end

    -- Keep labels centered
    centerLabel(self.labelTitle, UIFont.Medium)
    centerLabel(self.lblDeviceName, UIFont.Small)
    centerLabel(self.lblRangeInfo, UIFont.Small)

    -- Update Tab Widths dynamically
    local tabWidth = self.width / 4
    if self.btnStat then self.btnStat:setWidth(tabWidth) end
    if self.btnCall then self.btnCall:setX(tabWidth); self.btnCall:setWidth(tabWidth) end
    if self.btnQuest then self.btnQuest:setX(tabWidth * 2); self.btnQuest:setWidth(tabWidth) end
    if self.btnLoc then self.btnLoc:setX(tabWidth * 3); self.btnLoc:setWidth(tabWidth) end

    -- Update Tab Visuals (Highlight Active)
    local activeCat = "Stationary"
    if self.parent and self.parent.currentCategory then
        activeCat = self.parent.currentCategory
    end

    local activeColor = {r=0.2, g=0.2, b=0.2, a=1}
    local inactiveColor = {r=0, g=0, b=0, a=0.5}

    local function updateBtn(btn, catName)
        if not btn then return end
        btn.backgroundColor = (activeCat == catName) and activeColor or inactiveColor
        btn.textColor = (activeCat == catName) and {r=1,g=1,b=1,a=1} or {r=0.7,g=0.7,b=0.7,a=1}
    end

    updateBtn(self.btnStat, "Stationary")
    updateBtn(self.btnCall, "Callable")
    updateBtn(self.btnQuest, "Quest")
    updateBtn(self.btnLoc, "Location")
end

function DT_V2_RadarHeaderPanel:updateSignalInfo(bestName, bestRange)
    if self.labelTitle then
        self.labelTitle:setName("TRADER RADAR")
    end

    if self.lblDeviceName then
        self.lblDeviceName:setName("[" .. tostring(bestName) .. "]")
        
        -- Default white, updated by tier below
        self.lblDeviceName:setColor(1, 1, 1) 
    end

    if self.lblRangeInfo then
        if bestRange > 0 then
            self.lblRangeInfo:setName("Broadcast Range: " .. tostring(bestRange) .. "m")
            
            -- Tier colors for Device Name and Range Text
            local r, g, b = 1, 1, 1
            if bestRange < 500 then r, g, b = 1, 0.3, 0.3
            elseif bestRange < 1000 then r, g, b = 1, 0.8, 0.2
            elseif bestRange < 2000 then r, g, b = 0.4, 1.0, 0.4
            else r, g, b = 0.4, 0.9, 1.0 end
            
            if self.lblDeviceName then self.lblDeviceName:setColor(r, g, b) end
            self.lblRangeInfo:setColor(0.7, 0.7, 0.7) -- Keep range info subtle
        else
            self.lblRangeInfo:setName("Broadcast Range: No Signal")
            if self.lblDeviceName then self.lblDeviceName:setColor(0.5, 0.5, 0.5) end
        end
    end
end

function DT_V2_RadarHeaderPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0} -- Transparent bg, window handles it
    return o
end

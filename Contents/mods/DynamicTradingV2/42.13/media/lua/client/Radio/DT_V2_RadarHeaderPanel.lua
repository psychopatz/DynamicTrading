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
end

function DT_V2_RadarHeaderPanel:prerender()
    ISPanel.prerender(self)
    
    local function centerLabel(lbl, font)
        if not lbl then return end
        local text = lbl.name or ""
        local width = getTextManager():MeasureStringX(font, text)
        lbl:setX( (self.width / 2) - (width / 2) )
    end

    -- Keep labels centered dynamically on resize
    centerLabel(self.labelTitle, UIFont.Medium)
    centerLabel(self.lblDeviceName, UIFont.Small)
    centerLabel(self.lblRangeInfo, UIFont.Small)
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

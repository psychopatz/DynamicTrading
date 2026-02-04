-- ==============================================================================
-- DT_V2_RadarPatch.lua
-- Hooks into ISRadioWindow to add the Trader Radar functionality.
-- ==============================================================================

require "RadioComms/ISUI/ISRadioWindow"

local original_createChildren = ISRadioWindow.createChildren

function ISRadioWindow:createChildren()
    original_createChildren(self)
    
    -- Add the "SCAN FOR TRADERS" button
    local btnWidth = 110
    local btnHeight = 22
    local x = 10
    local y = self.height - 110 -- Positioned above the Channel controls
    
    self.btnTraderScan = ISButton:new(x, y, btnWidth, btnHeight, "SCAN TRADERS", self, function(self)
        if DT_V2_RadarManager then
            DT_V2_RadarManager.Scan(getPlayer(), self.device)
        end
    end)
    self.btnTraderScan:initialise()
    self.btnTraderScan.backgroundColor = {r=0.2, g=0.5, b=0.2, a=0.8}
    self:addChild(self.btnTraderScan)

    -- Add the "OPEN RADAR LIST" button
    self.btnTraderList = ISButton:new(x + btnWidth + 10, y, btnWidth, btnHeight, "RADAR LIST", self, function(self)
        if DT_V2_RadarWindow then
            DT_V2_RadarWindow.ToggleWindow()
        end
    end)
    self.btnTraderList:initialise()
    self.btnTraderList.backgroundColor = {r=0.2, g=0.2, b=0.5, a=0.8}
    self:addChild(self.btnTraderList)
end

-- Refresh visibility/enable status based on radio state
local original_prerender = ISRadioWindow.prerender
function ISRadioWindow:prerender()
    original_prerender(self)
    
    if self.btnTraderScan then
        local operational = false
        if self.deviceData and self.deviceData:getIsTurnedOn() then
            if self.deviceData:getPower() > 0 then operational = true end
        end
        self.btnTraderScan.enable = operational
    end
end

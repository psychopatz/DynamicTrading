-- ==============================================================================
-- DT_V2_RadarPatch.lua
-- Hooks into ISRadioWindow to add the Trader Radar functionality.
-- ==============================================================================

require "RadioComms/ISUI/ISRadioWindow"

local original_createChildren = ISRadioWindow.createChildren

function ISRadioWindow:createChildren()
    original_createChildren(self)
    
    -- Increase window height to accommodate buttons
    self:setHeight(self.height + 30)

    -- Add the "SCAN FOR TRADERS" button
    local btnWidth = 110
    local btnHeight = 22
    local totalW = (btnWidth * 2) + 10
    local startX = (self.width - totalW) / 2
    local y = self:titleBarHeight() + 65 -- Initial default
    
    if self.modules then
        print("[DT_RADAR] createChildren: Finding Signal Panel among " .. #self.modules .. " modules.")
        for i, module in ipairs(self.modules) do
            local element = module.element
            local subpanel = element and element.subpanel
            local title = element and element.titleText
            print("[DT_RADAR] createChildren: Module " .. i .. ": Title=" .. tostring(title) .. ", Subpanel=" .. tostring(subpanel))
        end
    end

    self.btnTraderScan = ISButton:new(startX, y, btnWidth, btnHeight, "SCAN TRADERS", self, function(self)
        if DT_V2_RadarManager then
            DT_V2_RadarManager.Scan(getPlayer(), self.device)
        end
    end)
    self.btnTraderScan:initialise()
    self.btnTraderScan.backgroundColor = {r=0.2, g=0.5, b=0.2, a=0.8}
    self:addChild(self.btnTraderScan)

    -- Add the "OPEN RADAR LIST" button
    self.btnTraderList = ISButton:new(startX + btnWidth + 10, y, btnWidth, btnHeight, "RADAR LIST", self, function(self)
        if DT_V2_RadarWindow then
            DT_V2_RadarWindow.ToggleWindow()
        end
    end)
    self.btnTraderList:initialise()
    self.btnTraderList.backgroundColor = {r=0.2, g=0.2, b=0.5, a=0.8}
    self:addChild(self.btnTraderList)
end

-- Refresh visibility/enable status and handle Dynamic Positioning
local original_prerender = ISRadioWindow.prerender
function ISRadioWindow:prerender()
    original_prerender(self)
    
    -- 1. Operational status
    if self.btnTraderScan then
        local operational = false
        if self.deviceData and self.deviceData:getIsTurnedOn() then
            if self.deviceData:getPower() > 0 then operational = true end
        end
        self.btnTraderScan.enable = operational
    end

    -- 2. Dynamic Positioning below Signal Waveform & Centering
    if self.modules and self.btnTraderScan and self.btnTraderList then
        for i, module in ipairs(self.modules) do
            local element = module.element
            local subpanel = element and element.subpanel
            local title = element and element.titleText
            
            local isSignal = false
            if title == "Signal" then 
                isSignal = true 
            elseif subpanel and subpanel.sineWaveDisplay then
                isSignal = true
            end

            if isSignal then
                -- Expand heights if not done yet
                if not element.dtExpanded then
                    print("[DT_RADAR] Expanding Signal Module height.")
                    element:setHeight(element:getHeight() + 28)
                    if subpanel then
                        subpanel:setHeight(subpanel:getHeight() + 28)
                    end
                    element.dtExpanded = true
                end

                local newY = element:getY() + element:getHeight() - 25
                local totalW = (self.btnTraderScan.width * 2) + 10
                local startX = (self.width - totalW) / 2
                
                if self.btnTraderScan:getY() ~= newY or self.btnTraderScan:getX() ~= startX then
                    print("[DT_RADAR] Centering and Repositioning buttons to Y: " .. newY)
                    self.btnTraderScan:setX(startX)
                    self.btnTraderScan:setY(newY)
                    self.btnTraderList:setX(startX + self.btnTraderScan.width + 10)
                    self.btnTraderList:setY(newY)
                end
                break
            end
        end
    end
end

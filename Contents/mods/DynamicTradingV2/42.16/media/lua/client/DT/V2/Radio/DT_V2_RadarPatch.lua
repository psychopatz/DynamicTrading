-- DT_V2_RadarPatch.lua
-- Hooks into ISRadioWindow to add the Trader Radar functionality.
-- Version [V3.1] - UI Logic Recovery (Device Injection Support)
-- ==============================================================================

require "ISUI/ISRadioWindow"
require "DT/Common/UI/RadioScanner/DT_RadioScannerWindow"
require "DT/V2/Radio/RadarManager/DT_V2_RadarManager"

local original_createChildren = ISRadioWindow.createChildren
local original_close = ISRadioWindow.close
local original_readFromObject = ISRadioWindow.readFromObject

function ISRadioWindow:close()
    if DT_RadioScannerWindow and DT_RadioScannerWindow.instance then
        DT_RadioScannerWindow.instance:close()
    end
    original_close(self)
end

function ISRadioWindow:readFromObject(_player, _deviceObject)
    -- If device changes, close our radar list (it might have stale data/range)
    if self.device ~= _deviceObject then
        if DT_RadioScannerWindow and DT_RadioScannerWindow.instance then
            DT_RadioScannerWindow.instance:close()
        end
    end
    original_readFromObject(self, _player, _deviceObject)
end

function ISRadioWindow:createChildren()
    original_createChildren(self)
    
    local btnWidth = 110
    local btnHeight = 22
    local totalW = (btnWidth * 2) + 10
    local startX = (self.width - totalW) / 2
    local y = 100 -- Default placeholder

    -- Add the "SCAN FOR TRADERS" button
    self.btnTraderScan = ISButton:new(startX, y, btnWidth, btnHeight, "SCAN TRADERS", self, function(window)
        if DT_V2_RadarManager and DT_V2_RadarManager.Scan then
            DT_V2_RadarManager.Scan(getSpecificPlayer(0), window.device)
        end
    end)
    self.btnTraderScan:initialise()
    self.btnTraderScan.backgroundColor = {r=0.2, g=0.5, b=0.2, a=0.8}
    self.btnTraderScan:setVisible(false)
    self:addChild(self.btnTraderScan)

    -- Add the "OPEN RADAR LIST" button
    self.btnTraderList = ISButton:new(startX + btnWidth + 10, y, btnWidth, btnHeight, "RADAR LIST", self, function(window)
        if DT_RadioScannerWindow then
            DT_RadioScannerWindow.ToggleWindow(window.device)
        end
    end)
    self.btnTraderList:initialise()
    self.btnTraderList.backgroundColor = {r=0.2, g=0.2, b=0.5, a=0.8}
    self.btnTraderList:setVisible(false)
    self:addChild(self.btnTraderList)
end

-- Refresh visibility/enable status and handle Dynamic Positioning
local original_prerender = ISRadioWindow.prerender
function ISRadioWindow:prerender()
    original_prerender(self)
    
    -- 1. Device Validation (Must be Two-Way and NOT a TV)
    local isValid = false
    if self.deviceData and not self.deviceData:isTelevision() and self.deviceData:getIsTwoWay() then
        isValid = true
    end
    
    -- Fallback/Safety Check for UI state
    if self.btnTraderScan then self.btnTraderScan:setVisible(isValid) end
    if self.btnTraderList then self.btnTraderList:setVisible(isValid) end

    if not isValid then return end

    -- 2. Operational status update
    if self.btnTraderScan and self.btnTraderList then
        local operational = false
        if self.deviceData and self.deviceData:getIsTurnedOn() then
            if self.deviceData:getPower() > 0 then operational = true end
        end
        local canScan = operational
        local remainingMinutes = 0
        if operational and DT_V2_RadarManager and DT_V2_RadarManager.CanScan then
            local player = getSpecificPlayer(0)
            canScan, remainingMinutes = DT_V2_RadarManager.CanScan(player, self.device)
        end

        self.btnTraderScan.enable = canScan == true
        self.btnTraderList.enable = operational
        if canScan == true then
            self.btnTraderScan:setTitle("SCAN TRADERS")
            self.btnTraderScan.textColor = { r = 1, g = 1, b = 1, a = 1 }
        else
            self.btnTraderScan:setTitle("WAIT (" .. tostring(math.max(1, math.ceil(remainingMinutes or 0))) .. "m)")
            self.btnTraderScan.textColor = { r = 1, g = 0.65, b = 0.35, a = 1 }
        end

        -- V2.5: Auto-close Radar Window if radio loses power/is turned off
        if not operational and DT_RadioScannerWindow and DT_RadioScannerWindow.instance then
            DT_RadioScannerWindow.instance:close()
        end
    end

    -- 3. Dynamic Positioning and Expansion (V2.3 Simplified)
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
                -- Persistent Base Height Discovery
                if not element.dt_baseHeight then
                    local currentH = element:getHeight()
                    -- If we catch it already expanded, find true base
                    if currentH > 80 then currentH = currentH - 45 end
                    element.dt_baseHeight = currentH
                    local devName = self.device and self.device:getName() or "Unknown"
                    DynamicTrading.Log("DTV2", "Radio", "Debug", "Base Height captured for " .. tostring(devName) .. ": " .. tostring(element.dt_baseHeight))
                end

                -- Force persistent expanded height (Only +25 for buttons now)
                local offset = 25
                local targetH = element.dt_baseHeight + offset
                if element:getHeight() ~= targetH then
                    element:setHeight(targetH)
                    if subpanel then
                        subpanel:setHeight(subpanel:getHeight() + (targetH - element.dt_baseHeight))
                    end
                    -- Adjust window height slightly if needed
                    if self.height < element:getY() + targetH + 30 then
                        self:setHeight(self.height + 25)
                    end
                end

                -- Reposition Buttons to bottom
                local baseLineY = element:getY() + element:getHeight() - 25
                local btnW = self.btnTraderScan.width
                local totalW = (btnW * 2) + 10
                local startX = (self.width - totalW) / 2
                
                if self.btnTraderScan then
                    self.btnTraderScan:setX(startX)
                    self.btnTraderScan:setY(baseLineY)
                end
                if self.btnTraderList then
                    self.btnTraderList:setX(startX + btnW + 10)
                    self.btnTraderList:setY(baseLineY)
                end
                break
            end
        end
    end
end

-- ==============================================================================
-- DT_V2_RadarPatch.lua
-- Hooks into ISRadioWindow to add the Trader Radar functionality.
-- ==============================================================================

require "RadioComms/ISUI/ISRadioWindow"

local original_createChildren = ISRadioWindow.createChildren

function ISRadioWindow:createChildren()
    original_createChildren(self)
    
    local th = self:titleBarHeight()
    local btnWidth = 110
    local btnHeight = 22
    local totalW = (btnWidth * 2) + 10
    local startX = (self.width - totalW) / 2
    local y = th + 65 -- Initial default

    if self.modules then
        print("[DT_RADAR] createChildren: Finding Signal Panel among " .. #self.modules .. " modules.")
        for i, module in ipairs(self.modules) do
            local element = module.element
            local subpanel = element and element.subpanel
            local title = element and element.titleText
            print("[DT_RADAR] createChildren: Module " .. i .. ": Title=" .. tostring(title) .. ", Subpanel=" .. tostring(subpanel))
        end
    end

    -- Add "Broadcast Power" label (bLeft = false for centering)
    self.lblBroadcastPower = ISLabel:new(self.width / 2, y, 18, "Broadcast Power: ---", 1, 1, 1, 1, UIFont.Small, false)
    self.lblBroadcastPower:initialise()
    self.lblBroadcastPower:setVisible(false)
    self:addChild(self.lblBroadcastPower)

    -- Add the "SCAN FOR TRADERS" button
    self.btnTraderScan = ISButton:new(startX, y + 20, btnWidth, btnHeight, "SCAN TRADERS", self, function(self)
        if DT_V2_RadarManager then
            DT_V2_RadarManager.Scan(getPlayer(), self.device)
        end
    end)
    self.btnTraderScan:initialise()
    self.btnTraderScan.backgroundColor = {r=0.2, g=0.5, b=0.2, a=0.8}
    self.btnTraderScan:setVisible(false)
    self:addChild(self.btnTraderScan)

    -- Add the "OPEN RADAR LIST" button
    self.btnTraderList = ISButton:new(startX + btnWidth + 10, y + 20, btnWidth, btnHeight, "RADAR LIST", self, function(self)
        if DT_V2_RadarWindow then
            DT_V2_RadarWindow.ToggleWindow()
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
    if self.lblBroadcastPower then self.lblBroadcastPower:setVisible(isValid) end

    if not isValid then return end

    -- 2. Operational status update
    if self.btnTraderScan then
        local operational = false
        if self.deviceData and self.deviceData:getIsTurnedOn() then
            if self.deviceData:getPower() > 0 then operational = true end
        end
        self.btnTraderScan.enable = operational
    end

    -- 3. Dynamic Positioning, Expansion, and Power Label Update
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
                -- Expand heights if not done yet for THIS device
                if element.dtExpanded ~= self.deviceData then
                    local devName = "Unknown"
                    if self.device then devName = self.device:getName() end
                    print("[DT_RADAR] Expanding Signal Module for Radar UI (Device: " .. tostring(devName) .. ")")
                    
                    element:setHeight(element:getHeight() + 45) -- More space for label + buttons
                    if subpanel then
                        subpanel:setHeight(subpanel:getHeight() + 45)
                    end
                    -- Also increase main window height slightly if needed
                    if self.height < element:getY() + element:getHeight() + 50 then
                        self:setHeight(self.height + 45)
                    end
                    element.dtExpanded = self.deviceData
                end

                -- Update Broadcast Power Text & Tiered Color
                if self.lblBroadcastPower and self.device then
                    local range = 0
                    local typeID = self.device:getFullType()
                    if DT_V2_RadarManager and DT_V2_RadarManager.Ranges then
                        range = DT_V2_RadarManager.Ranges[typeID] or 500
                    end
                    self.lblBroadcastPower:setName("Broadcast Power: " .. tostring(range) .. "m")
                    
                    -- Apply Tier color based on range
                    if range < 500 then -- Tier 0: Makeshift (Red)
                        self.lblBroadcastPower.r, self.lblBroadcastPower.g, self.lblBroadcastPower.b = 1.0, 0.3, 0.3
                    elseif range < 1000 then -- Tier 1: Standard (Orange/Yellow)
                        self.lblBroadcastPower.r, self.lblBroadcastPower.g, self.lblBroadcastPower.b = 1.0, 0.8, 0.2
                    elseif range < 2000 then -- Tier 2: High Grade (Green)
                        self.lblBroadcastPower.r, self.lblBroadcastPower.g, self.lblBroadcastPower.b = 0.4, 1.0, 0.4
                    else -- Tier 3: Military/Long Range (Cyan)
                        self.lblBroadcastPower.r, self.lblBroadcastPower.g, self.lblBroadcastPower.b = 0.4, 0.9, 1.0
                    end
                end

                local baseLineY = element:getY() + element:getHeight() - 40
                local btnW = (self.btnTraderScan and self.btnTraderScan.width) or 110
                local totalW = (btnW * 2) + 10
                local startX = (self.width - totalW) / 2
                
                if self.btnTraderScan and (self.btnTraderScan:getY() ~= baseLineY + 18 or self.btnTraderScan:getX() ~= startX) then
                    print("[DT_RADAR] Centering and Repositioning buttons to Y: " .. baseLineY)
                    -- Position Label
                    if self.lblBroadcastPower then
                        self.lblBroadcastPower:setX(self.width / 2)
                        self.lblBroadcastPower:setY(baseLineY)
                    end
                    -- Position Buttons
                    if self.btnTraderScan then
                        self.btnTraderScan:setX(startX)
                        self.btnTraderScan:setY(baseLineY + 18)
                    end
                    if self.btnTraderList then
                        self.btnTraderList:setX(startX + btnW + 10)
                        self.btnTraderList:setY(baseLineY + 18)
                    end
                end
                break
            end
        end
    end
end

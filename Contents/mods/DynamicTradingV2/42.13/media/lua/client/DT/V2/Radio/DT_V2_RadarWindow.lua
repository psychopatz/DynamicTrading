-- ==============================================================================
-- DT_V2_RadarWindow.lua
-- Main Orchestrator for the Radar UI. Manages dynamic sizing and sub-panels.
-- ==============================================================================

require "ISUI/ISCollapsableWindow"
require "DT/V2/Radio/DT_V2_RadarHeaderPanel"
require "DT/V2/Radio/DT_V2_RadarListPanel"
require "DT/V2/Radio/DT_V2_RadarActionPanel"
require "DT/V2/Radio/DT_V2_RadarManager"
require "DT/V2/Radio/DT_V2_RadarLocationHandler"
require "DT/Common/Faction/TradingSys/DynamicTrading_Roster"
require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"

DT_V2_RadarWindow = ISCollapsableWindow:derive("DT_V2_RadarWindow")
DT_V2_RadarWindow.instance = nil

-- Define a constant ID for the active marker to ensure only one exists
DT_V2_RadarWindow.MARKER_ID = "DT_Radar_Active_Target"

function DT_V2_RadarWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 450
    self.minimumHeight = 450
    
    self.currentCategory = "Stationary"
    
    self.updateTimer = 0
    self.syncTimer = 0
    
    -- Tracking State
    self.trackingUUID = nil
    self.trackingName = nil
end

function DT_V2_RadarWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    
    local th = self:titleBarHeight()
    local w = self.width
    
    -- 1. Header Panel
    local headerHeight = 85
    self.headerPanel = DT_V2_RadarHeaderPanel:new(0, th, w, headerHeight)
    self.headerPanel:initialise()
    self.headerPanel:instantiate()
    self.headerPanel:setAnchorRight(true)
    self:addChild(self.headerPanel)

    -- 2. List Panel
    local listY = th + headerHeight
    local footerHeight = 40
    local listHeight = self.height - listY - footerHeight
    
    self.listPanel = DT_V2_RadarListPanel:new(10, listY, w - 20, listHeight)
    self.listPanel:initialise()
    self.listPanel:instantiate()
    self.listPanel:setAnchorRight(true)
    self.listPanel:setAnchorBottom(true)
    self:addChild(self.listPanel)
    
    -- Initialize layout
    self.listPanel:setLayoutMode(self.currentCategory == "Location" and "Location" or "Standard")

    -- 3. Action Panel
    self.actionPanel = DT_V2_RadarActionPanel:new(0, self.height - footerHeight, w, 30)
    self.actionPanel:initialise()
    self.actionPanel:instantiate()
    self.actionPanel:setAnchorRight(true)
    self.actionPanel:setAnchorTop(false)
    self.actionPanel:setAnchorBottom(true)
    self:addChild(self.actionPanel)

    self:refresh()
    
    if isClient() then
        DT_V2_RadarManager.RequestRoster()
    end
end

-- ==============================================================================
-- TRACKING LOGIC
-- ==============================================================================

function DT_V2_RadarWindow:startTracking(uuid, name)
    self.trackingUUID = uuid
    self.trackingName = name
    getSpecificPlayer(0):Say("Tracking signal: " .. tostring(name))
    -- Update will handle the marker creation/update immediately on next tick
end

function DT_V2_RadarWindow:stopTracking()
    self.trackingUUID = nil
    self.trackingName = nil
    if EventMarkerHandler then
        EventMarkerHandler.remove(self.MARKER_ID)
    end
    getSpecificPlayer(0):Say("Signal tracking stopped.")
    
    -- Update button if visible
    if self.listPanel and self.listPanel.listbox then
        local sel = self.listPanel.listbox.selected
        if sel and self.listPanel.listbox.items[sel] then
             local itemData = self.listPanel.listbox.items[sel].item
             if itemData then
                 self.actionPanel:updateButtonState(itemData.uuid)
             end
        end
    end
end

function DT_V2_RadarWindow:updateTrackingMarker()
    if not self.trackingUUID or not EventMarkerHandler then return end
    
    local tx, ty, tz, isLive = DT_V2_RadarManager.GetTraderCoords(self.trackingUUID)
    
    if not tx or not ty then
        -- Lost signal
        return 
    end

    local player = getSpecificPlayer(0)
    local dist = IsoUtils.DistanceTo(tx, ty, player:getX(), player:getY())

    -- Dynamic Background Color based on Proximity
    local color = {r=0, g=1, b=1} -- Default Cyan
    
    if dist < 300 then
        color = {r=0.1, g=1, b=0.1} -- Green (Close)
    elseif dist < 1500 then
        color = {r=1, g=0.9, b=0.2} -- Yellow (Medium)
    else
        color = {r=1, g=0.4, b=0.1} -- Orange (Far)
    end
    
    local description = "SIGNAL: " .. tostring(self.trackingName)
    
    -- Update or Set Marker (Using constant ID enforces single instance)
    -- We set duration to a small buffer (e.g. 5 seconds) so it persists briefly 
    -- but is refreshed constantly by this update loop. 
    -- This allows it to "expire" if the game crashes or window closes ungracefully.
    EventMarkerHandler.set(
        self.MARKER_ID,
        "friend.png",
        60, -- 60 ticks? No, setDuration usually takes gametime ticks or seconds depending on implementation. 
            -- EventMarkerHandler uses getGametimeTimestamp. 
            -- Safe to set a high number and rely on remove() in close().
        tx,
        ty,
        color,
        description
    )
end

-- ==============================================================================
-- UPDATE LOOP
-- ==============================================================================

function DT_V2_RadarWindow:update()
    ISCollapsableWindow.update(self)
    
    if self:getIsVisible() then
        -- 1. Track Active Marker (Every tick for smooth movement/color change)
        if self.trackingUUID then
            self:updateTrackingMarker()
        end

        -- 2. Local UI Refresh
        self.updateTimer = self.updateTimer + getGameTime():getRealworldSecondsSinceLastUpdate()
        if self.updateTimer >= 2.0 then
            self.updateTimer = 0
            self:refresh()
        end
        
        -- 3. Server Data Sync
        if isClient() then
            self.syncTimer = self.syncTimer + getGameTime():getRealworldSecondsSinceLastUpdate()
            if self.syncTimer >= 10.0 then
                self.syncTimer = 0
                DT_V2_RadarManager.RequestRoster()
            end
        end
    end
end

function DT_V2_RadarWindow:setCategory(category)
    if self.currentCategory == category then return end
    self.currentCategory = category
    
    -- Update List Panel Layout (Show/Hide Faction Button)
    if self.listPanel and self.listPanel.setLayoutMode then
        self.listPanel:setLayoutMode(category)
    end
    
    self:refresh()
end

function DT_V2_RadarWindow:refresh()
    if not self.listPanel or not self.headerPanel or not self.actionPanel then return end
    
    local listbox = self.listPanel.listbox
    
    -- Save selection
    local selectedUUID = nil
    if listbox.selected and listbox.selected ~= -1 and listbox.items[listbox.selected] then
        if listbox.items[listbox.selected].item then
            selectedUUID = listbox.items[listbox.selected].item.uuid
        end
    end

    listbox:clear()
    listbox.selected = -1
    
    -- Update Button State based on selection vs tracking
    self.actionPanel.btnLocate.enable = (selectedUUID ~= nil)
    self.actionPanel:updateButtonState(selectedUUID)

    if not DT_V2_RadarManager then return end

    local player = getSpecificPlayer(0)
    if not player then return end

    local bestRange = 0
    local bestName = "Unknown"

    if self.device then
        bestName, bestRange = DT_V2_RadarManager.GetDeviceInfo(self.device)
    end
    
    -- Fallback scan inventory if device arg missing
    if bestRange == 0 then
        local items = player:getInventory():getItems()
        for i=0, items:size()-1 do
            local item = items:get(i)
            if item:getCategory() == "Communications" and item:getIsTwoWay() then
                local name, r = DT_V2_RadarManager.GetDeviceInfo(item)
                if r > bestRange then 
                    bestRange = r 
                    bestName = name
                end
            end
        end
    end

    self.headerPanel:updateSignalInfo(bestName, bestRange)
    
    if self.currentCategory == "Location" then
        if DT_V2_RadarLocationHandler then
            DT_V2_RadarLocationHandler.PopulateList(listbox, player)
        else
            listbox:addItem("Module Missing: LocationHandler", {})
        end
        self.actionPanel.btnLocate.enable = false
        return
    end

    DT_V2_RadarManager.Cleanup()
    
    local tempList = {}
    
    if self.currentCategory == "Stationary" then
        for uuid, data in pairs(DT_V2_RadarManager.FoundTraders) do
            local tx, ty, tz, isLive = DT_V2_RadarManager.GetTraderCoords(uuid)
            local dist = 99999
            local distText = "Distance: Unknown"
            
            if tx and ty then
                local dx = tx - player:getX()
                local dy = ty - player:getY()
                dist = math.sqrt(dx*dx + dy*dy)
                distText = string.format("Distance: %.0fm", dist)
            end
            
            table.insert(tempList, {
                uuid = uuid,
                data = data,
                tx = tx, ty = ty, tz = tz,
                isLive = isLive,
                dist = dist,
                distText = distText
            })
        end
    end
    
    table.sort(tempList, function(a, b) 
        local d1 = a.dist or 999999
        local d2 = b.dist or 999999
        return d1 < d2 
    end)
    
    for _, entry in ipairs(tempList) do
        local uuid = entry.uuid
        local data = entry.data
        local soul = DT_V2_RadarManager.GetSoul(uuid)
        local archetypeID = soul and soul.archetypeID or "General"
        local gender = (soul and soul.isFemale) and "Female" or "Male"
        local portraitID = soul and soul.portraitID or 1
        
        local factionData = DT_V2_RadarManager.GetFaction(data.faction)
        local factionName = factionData and factionData.name or data.faction or "Independent"

        local expireText = ""
        if soul and soul.returnTime and soul.returnTime > 0 then
            local hours = math.ceil(soul.returnTime - getGameTime():getWorldAgeHours())
            if hours < 0 then hours = 0 end
            expireText = "Expires: " .. hours .. "h"
        end

        local item = {
            uuid = uuid,
            name = data.name,
            faction = data.faction,
            factionName = factionName,
            archetype = archetypeID,
            gender = gender,
            portraitID = portraitID,
            distText = entry.distText,
            expireText = expireText,
            isLive = entry.isLive,
            x = entry.tx,
            y = entry.ty,
            z = entry.tz
        }
        local addedItem = listbox:addItem(data.name, item)
        
        if selectedUUID == uuid and #listbox.items > 0 then
            listbox.selected = #listbox.items
        end
    end
end

function DT_V2_RadarWindow.ToggleWindow(device)
    if DT_V2_RadarWindow.instance then
        if DT_V2_RadarWindow.instance:getIsVisible() then
            DT_V2_RadarWindow.instance:close()
        else
            DT_V2_RadarWindow.instance.device = device
            DT_V2_RadarWindow.instance:setVisible(true)
            DT_V2_RadarWindow.instance:addToUIManager()
            DT_V2_RadarWindow.instance:refresh()
        end
        return
    end

    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local width = math.min(500, screenW * 0.4) 
    local height = math.min(600, screenH * 0.6) 
    
    width = math.max(450, width)
    height = math.max(450, height) 

    local window = DT_V2_RadarWindow:new(screenW/2 - width/2, screenH/2 - height/2, width, height)
    window.device = device
    window:initialise()
    window:addToUIManager()
    DT_V2_RadarWindow.instance = window
end

function DT_V2_RadarWindow:close()
    -- Stop tracking when closing window
    self:stopTracking()
    self:setVisible(false)
    self:removeFromUIManager()
end

function DT_V2_RadarWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "Trader Radar"
    o.resizable = true
    return o
end

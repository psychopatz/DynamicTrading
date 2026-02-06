-- ==============================================================================
-- DT_V2_RadarWindow.lua
-- Main Orchestrator for the Radar UI. Manages dynamic sizing and sub-panels.
-- ==============================================================================

require "ISUI/ISCollapsableWindow"
require "Radio/DT_V2_RadarHeaderPanel"
require "Radio/DT_V2_RadarListPanel"
require "Radio/DT_V2_RadarActionPanel"
require "Radio/DT_V2_RadarManager"
require "Faction/TradingSys/DynamicTrading_Roster"
require "Faction/TradingSys/DynamicTrading_Factions"

DT_V2_RadarWindow = ISCollapsableWindow:derive("DT_V2_RadarWindow")
DT_V2_RadarWindow.instance = nil

function DT_V2_RadarWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 450
    self.minimumHeight = 450 -- Increased for tabs
    
    self.currentCategory = "Stationary" -- Default category
    
    self.updateTimer = 0 -- Local UI refresh (2s)
    self.syncTimer = 0   -- Server Data Sync (10s)
end

function DT_V2_RadarWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    
    local th = self:titleBarHeight()
    local w = self.width
    
    -- 1. Header Panel (Title & Range & Tabs)
    -- Increased height to 85 to accommodate tabs
    local headerHeight = 85
    self.headerPanel = DT_V2_RadarHeaderPanel:new(0, th, w, headerHeight)
    self.headerPanel:initialise()
    self.headerPanel:instantiate()
    self.headerPanel:setAnchorRight(true)
    self:addChild(self.headerPanel)

    -- 2. List Panel (Trader entries)
    local listY = th + headerHeight
    local footerHeight = 40
    local listHeight = self.height - listY - footerHeight
    
    self.listPanel = DT_V2_RadarListPanel:new(10, listY, w - 20, listHeight)
    self.listPanel:initialise()
    self.listPanel:instantiate()
    self.listPanel:setAnchorRight(true)
    self.listPanel:setAnchorBottom(true)
    self:addChild(self.listPanel)

    -- 3. Action Panel (Buttons)
    self.actionPanel = DT_V2_RadarActionPanel:new(0, self.height - footerHeight, w, 30)
    self.actionPanel:initialise()
    self.actionPanel:instantiate()
    self.actionPanel:setAnchorRight(true)
    self.actionPanel:setAnchorTop(false)
    self.actionPanel:setAnchorBottom(true)
    self:addChild(self.actionPanel)

    self:refresh()
    
    -- [MP FIX] Request fresh Roster data when window opens
    if isClient() then
        DT_V2_RadarManager.RequestRoster()
    end
end

function DT_V2_RadarWindow:update()
    ISCollapsableWindow.update(self)
    
    if self:getIsVisible() then
        -- 1. Local UI Refresh (Animations, Distance Calc)
        self.updateTimer = self.updateTimer + getGameTime():getRealworldSecondsSinceLastUpdate()
        if self.updateTimer >= 2.0 then
            self.updateTimer = 0
            self:refresh()
        end
        
        -- 2. Server Data Sync (MP Only) - Every 10 seconds
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
    self:refresh()
end

function DT_V2_RadarWindow:refresh()
    if not self.listPanel or not self.headerPanel or not self.actionPanel then return end
    
    local listbox = self.listPanel.listbox
    
    -- Save selection before clear
    local selectedUUID = nil
    if listbox.selected and listbox.selected ~= -1 and listbox.items[listbox.selected] then
        selectedUUID = listbox.items[listbox.selected].item.uuid
    end

    listbox:clear()
    listbox.selected = -1 -- Reset to safe numeric value
    self.actionPanel.btnLocate.enable = (selectedUUID ~= nil)
    
    if not DT_V2_RadarManager then return end

    local player = getSpecificPlayer(0)
    if not player then return end

    local bestRange = 0
    local bestName = "Unknown"

    -- Range Logic (Delegated to Manager)
    if self.device then
        bestName, bestRange = DT_V2_RadarManager.GetDeviceInfo(self.device)
    end

    if bestRange == 0 or bestName == "Unknown Device" then
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

    -- Update Header (Pass category info if needed, or rely on Header's own draw logic for tabs)
    -- For now just standard update
    self.headerPanel:updateSignalInfo(bestName, bestRange)
    
    -- Populate List based on CATEGORY
    DT_V2_RadarManager.Cleanup()
    
    -- 1. Collect and Calculate Distances
    local tempList = {}
    
    -- Currently only "Stationary" has implementation
    -- In future, add logic for "Callable" and "Quest"
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
    elseif self.currentCategory == "Callable" then
        -- Placeholder for callable traders
    elseif self.currentCategory == "Quest" then
        -- Placeholder for quest givers
    end
    
    -- 2. Sort by Distance
    table.sort(tempList, function(a, b) 
        local d1 = a.dist or 999999
        local d2 = b.dist or 999999
        return d1 < d2 
    end)
    
    -- 3. Populate UI
    for _, entry in ipairs(tempList) do
        local uuid = entry.uuid
        local data = entry.data
        
        -- [FIX] Use Manager Accessors (works for both MP Cache and SP ModData)
        local soul = DT_V2_RadarManager.GetSoul(uuid)
        local archetypeID = soul and soul.archetypeID or "General"
        local gender = (soul and soul.isFemale) and "Female" or "Male"
        local portraitID = soul and soul.portraitID or 1
        
        local factionData = DT_V2_RadarManager.GetFaction(data.faction)
        local factionName = factionData and factionData.name or data.faction or "Independent"

        -- Calculate Expiration
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
        
        -- Restore selection
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

    -- Dynamic Sizing Logic
    local screenW = getCore():getScreenWidth()
    local screenH = getCore():getScreenHeight()
    local width = math.min(500, screenW * 0.4) -- Max 500, or 40% of screen
    local height = math.min(600, screenH * 0.6) -- Max 600, or 60% of screen
    
    -- Minimum threshold
    width = math.max(450, width)
    height = math.max(450, height) -- Increased for tabs

    local window = DT_V2_RadarWindow:new(screenW/2 - width/2, screenH/2 - height/2, width, height)
    window.device = device
    window:initialise()
    window:addToUIManager()
    DT_V2_RadarWindow.instance = window
end

function DT_V2_RadarWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function DT_V2_RadarWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    -- ISCollapsableWindow handles bg/border usually, but explicit initialization helps
    o.title = "Trader Radar"
    o.resizable = true
    return o
end

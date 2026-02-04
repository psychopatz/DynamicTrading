-- ==============================================================================
-- DT_V2_RadarWindow.lua
-- Main Orchestrator for the Radar UI. Manages dynamic sizing and sub-panels.
-- ==============================================================================

require "ISUI/ISCollapsableWindow"
require "Radio/DT_V2_RadarHeaderPanel"
require "Radio/DT_V2_RadarListPanel"
require "Radio/DT_V2_RadarActionPanel"
require "Radio/DT_V2_RadarManager"

DT_V2_RadarWindow = ISCollapsableWindow:derive("DT_V2_RadarWindow")
DT_V2_RadarWindow.instance = nil

function DT_V2_RadarWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 450
    self.minimumHeight = 400
end

function DT_V2_RadarWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    
    local th = self:titleBarHeight()
    local w = self.width
    
    -- 1. Header Panel (Title & Range)
    -- Positioned below title bar
    self.headerPanel = DT_V2_RadarHeaderPanel:new(0, th, w, 60)
    self.headerPanel:initialise()
    self.headerPanel:instantiate()
    self.headerPanel:setAnchorRight(true)
    self:addChild(self.headerPanel)

    -- 2. List Panel (Trader entries)
    -- Adjust height to account for title bar (th), header (60), and footer (40)
    local listY = th + 60
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
end

function DT_V2_RadarWindow:refresh()
    if not self.listPanel or not self.headerPanel or not self.actionPanel then return end
    
    local listbox = self.listPanel.listbox
    listbox:clear()
    self.actionPanel.btnLocate.enable = false
    
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

    -- Update Header
    self.headerPanel:updateSignalInfo(bestName, bestRange)
    
    -- Populate List
    DT_V2_RadarManager.Cleanup()
    
    for uuid, data in pairs(DT_V2_RadarManager.FoundTraders) do
        local tx, ty, tz, isLive = DT_V2_RadarManager.GetTraderCoords(uuid)
        
        local distText = "Distance: Unknown"
        if tx and ty then
            local dx = tx - player:getX()
            local dy = ty - player:getY()
            local dist = math.sqrt(dx*dx + dy*dy)
            distText = string.format("Distance: %.0fm", dist)
        end

        local soul = DynamicTrading_Roster and DynamicTrading_Roster.GetSoulRegistry(uuid)
        local archetypeID = soul and soul.archetypeID or "General"
        local gender = (soul and soul.isFemale) and "Female" or "Male"
        local portraitID = soul and soul.portraitID or 1
        
        local factionData = DynamicTrading_Factions and DynamicTrading_Factions.GetFaction(data.faction)
        local factionName = factionData and factionData.name or data.faction or "Independent"

        local item = {
            uuid = uuid,
            name = data.name,
            faction = data.faction,
            factionName = factionName,
            archetype = archetypeID,
            gender = gender,
            portraitID = portraitID,
            distText = distText,
            isLive = isLive,
            x = tx,
            y = ty,
            z = tz
        }
        listbox:addItem(data.name, item)
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
    height = math.max(400, height)

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

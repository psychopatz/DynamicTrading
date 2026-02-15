-- ==============================================================================
-- media/lua/client/DT/V2/UI/Faction/DT_FactionInfoWindow.lua
-- Dedicated Info UI for Factions
-- Refactored to match Radar Window (Scalable, Hideable, Header Separated)
-- ==============================================================================

require "ISUI/ISCollapsableWindow"
require "ISUI/ISTabPanel"
require "DT/V2/UI/Faction/DT_FactionList"
require "DT/V2/UI/Faction/DT_FactionInfoHeaderPanel"
require "DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Info"
require "DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Reputation"
require "DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Economics"
require "DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Stockpiles"
require "DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Population"
require "DT/V2/UI/Faction/DT_NPCProfilePanel"

DT_FactionInfoWindow = ISCollapsableWindow:derive("DT_FactionInfoWindow")
DT_FactionInfoWindow.instance = nil

function DT_FactionInfoWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 800
    self.minimumHeight = 500
    
    self.fontScale = "Medium"
end

function DT_FactionInfoWindow:getFontScale()
    if self.width > 1400 then return "Large" end
    if self.width > 1000 then return "Medium" end
    return "Small"
end

function DT_FactionInfoWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local w = self.width
    local h = self.height

    -- 1. HEADER PANEL
    local headerHeight = 60
    self.headerPanel = DT_FactionInfoHeaderPanel:new(0, th, w, headerHeight)
    self.headerPanel:initialise()
    self.headerPanel:setAnchorRight(true)
    self.headerPanel:setAnchorLeft(true)
    self.headerPanel:setAnchorTop(true)
    self:addChild(self.headerPanel)

    -- Layout Vars
    local listY = th + headerHeight
    local contentHeight = h - listY - 10 -- 10 padding bottom
    local listWidth = 280

    -- 2. LIST BOX (Left Side)
    self.listbox = DT_FactionList:new(10, listY, listWidth, contentHeight)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.onmousedown = DT_FactionInfoWindow.onListMouseDown
    -- Anchors
    self.listbox:setAnchorLeft(true)
    self.listbox:setAnchorTop(true)
    self.listbox:setAnchorBottom(true)
    self:addChild(self.listbox)
    
    -- 3. TAB PANEL (Right Side)
    local tabX = 10 + listWidth + 10
    local tabWidth = w - tabX - 10
    
    self.panel = ISTabPanel:new(tabX, listY, tabWidth, contentHeight)
    self.panel:initialise()
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panel.target = self
    
    -- Anchors
    self.panel:setAnchorLeft(true) 
    self.panel:setAnchorRight(true) 
    self.panel:setAnchorTop(true)
    self.panel:setAnchorBottom(true)
    
    self:addChild(self.panel)

    -- 3.1. Create Tabs
    -- Info Tab
    self.tabInfo = DT_FactionInfoTab_Info:new(0, 0, tabWidth, contentHeight)
    self.tabInfo:initialise()
    self.tabInfo:setAnchorRight(true)
    self.tabInfo:setAnchorBottom(true)
    self.panel:addView("Info", self.tabInfo)
    
    -- Reputation Tab
    self.tabReputation = DT_FactionInfoTab_Reputation:new(0, 0, tabWidth, contentHeight)
    self.tabReputation:initialise()
    self.tabReputation:setAnchorRight(true)
    self.tabReputation:setAnchorBottom(true)
    self.panel:addView("Reputation", self.tabReputation)
    
    -- Economics Tab (Was Events)
    self.tabEconomics = DT_FactionInfoTab_Economics:new(0, 0, tabWidth, contentHeight)
    self.tabEconomics:initialise()
    self.tabEconomics:setAnchorRight(true)
    self.tabEconomics:setAnchorBottom(true)
    self.panel:addView("Economics", self.tabEconomics)
    
    -- Stockpiles Tab
    self.tabStockpiles = DT_FactionInfoTab_Stockpiles:new(0, 0, tabWidth, contentHeight)
    self.tabStockpiles:initialise()
    self.tabStockpiles:setAnchorRight(true)
    self.tabStockpiles:setAnchorBottom(true)
    self.panel:addView("Stockpiles", self.tabStockpiles)
    
    -- Population Tab
    self.tabPopulation = DT_FactionInfoTab_Population:new(0, 0, tabWidth, contentHeight)
    self.tabPopulation:initialise()
    self.tabPopulation:setAnchorRight(true)
    self.tabPopulation:setAnchorBottom(true)
    self.panel:addView("Population", self.tabPopulation)

    self:refreshList()
end

function DT_FactionInfoWindow:prerender()
    ISCollapsableWindow.prerender(self)
    local th = self:titleBarHeight()
    local headerHeight = 60
    local listY = th + headerHeight
    local listWidth = 280
    local contentHeight = self.height - listY - 10
    
    self:drawRectBorder(10, listY, listWidth, contentHeight, 0.5, 1, 1, 1)
end

function DT_FactionInfoWindow:onResize()
    ISCollapsableWindow.onResize(self)
    
    local newScale = self:getFontScale()
    if newScale ~= self.fontScale then
        self.fontScale = newScale
        -- Notify Children to update fonts
        if self.listbox and self.listbox.onResizeFont then
            self.listbox:onResizeFont(newScale)
        end
        
        if self.headerPanel and self.headerPanel.onResizeFont then
            self.headerPanel:onResizeFont(newScale)
        end
        
        -- Update active tab
        local activeView = self.panel:getActiveView()
        if activeView then
            activeView:setWidth(self.panel:getWidth())
            activeView:setHeight(self.panel:getHeight() - self.panel.tabHeight)
            if activeView.onResize then activeView:onResize() end
            if activeView.updateData then
                 activeView:updateData(self.selectedFaction)
            end
        end
    end
end

function DT_FactionInfoWindow:refreshList()
    -- Request Data
    if isClient() and not isServer() then
        sendClientCommand(getPlayer(), "DynamicTrading_V2", "RequestFactionData", {})
        return
    end
    
    -- Singleplayer Direct Access
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    local rosterData = ModData.get("DynamicTrading_Roster") or {}
    self:populateList(factionData, rosterData)
end

function DT_FactionInfoWindow:populateList(factionData, rosterData)
    if not self.listbox then return end
    self.listbox:clear()
    
    -- If rosterData wasn't passed (e.g. from network callback old sig), try to get cached
    if not rosterData then
        rosterData = DT_FactionInfoWindow.cachedRosterData or {}
    end

    local keys = {}
    for id in pairs(factionData) do table.insert(keys, id) end
    table.sort(keys)

    for _, id in ipairs(keys) do
        local f = factionData[id]
        
        -- Check Population
        local isAlive = true
        if rosterData and rosterData.FactionMembers then
            local members = rosterData.FactionMembers[id]
            if not members or #members == 0 then
                isAlive = false
            end
        end

        -- Only add if alive (or if we can't determine, default to show to be safe)
        if isAlive then
            self.listbox:addItem(f.name or id, f)
        end
    end
end

-- =============================================================================
-- INTERACTION HANDLERS
-- =============================================================================
function DT_FactionInfoWindow:onListMouseDown(item)
    local f = item
    if not f then return end
    
    -- Cache selected faction for updates (if needed)
    DT_FactionInfoWindow.selectedFaction = f

    -- Update All Tabs
    if DT_FactionInfoWindow.instance then
        local win = DT_FactionInfoWindow.instance
        if win.tabInfo then win.tabInfo:updateData(f) end
        if win.tabReputation then win.tabReputation:updateData(f) end
        if win.tabEconomics then win.tabEconomics:updateData(f) end
        if win.tabStockpiles then win.tabStockpiles:updateData(f) end
        
        -- Population Tab needs roster data too
        local rosterData = DT_FactionInfoWindow.cachedRosterData or ModData.get("DynamicTrading_Roster")
        if win.tabPopulation then win.tabPopulation:updateData(f, rosterData) end
    end
end

-- =============================================================================
-- NETWORKING & INSTANCE MANAGEMENT
-- =============================================================================

-- Handle server response
local function onServerCommand(module, command, args)
    if module ~= "DynamicTrading_V2" then return end
    
    if command == "SyncFactionDebugData" then
        if DT_FactionInfoWindow.instance and DT_FactionInfoWindow.instance:getIsVisible() then
            -- Cache data
            DT_FactionInfoWindow.cachedFactionData = args.factions
            DT_FactionInfoWindow.cachedRosterData = args.roster
            
            -- Populate
            DT_FactionInfoWindow.instance:populateList(args.factions, args.roster)
        end
    end
end

-- Reactive Refresh for Multiplayer (Static/Singleton level)
if not DT_FactionInfoWindow.EventsAdded then
    Events.OnReceiveGlobalModData.Add(function(key, data)
        if not DT_FactionInfoWindow.instance then return end
        
        if DT_FactionInfoWindow.instance:getIsVisible() then
            -- Faction/Roster Data -> Update List
            if (key == "DynamicTrading_Factions" or key == "DynamicTrading_Roster") then
                DT_FactionInfoWindow.instance:refreshList()
            
            -- Engine Data (Inflation/Events) -> Update Active Tab Details
            elseif key == "DynamicTrading_Engine_v2" then
                 local panel = DT_FactionInfoWindow.instance.panel
                 if panel then
                     local activeView = panel:getActiveView()
                     if activeView and activeView.updateData then
                         -- data is already in ModData, just re-render
                         activeView:updateData(DT_FactionInfoWindow.selectedFaction)
                     end
                 end
            end
        end
    end)
    Events.OnServerCommand.Add(onServerCommand)
    DT_FactionInfoWindow.EventsAdded = true
end

function DT_FactionInfoWindow.ToggleWindow()
    if DT_FactionInfoWindow.instance then
        if DT_FactionInfoWindow.instance:getIsVisible() then
            DT_FactionInfoWindow.instance:close()
        else
            DT_FactionInfoWindow.instance:setVisible(true)
            DT_FactionInfoWindow.instance:addToUIManager()
            DT_FactionInfoWindow.instance:refreshList()
        end
        return
    end
    
    DT_FactionInfoWindow.Open()
end

function DT_FactionInfoWindow.Open()
    if DT_FactionInfoWindow.instance then
        DT_FactionInfoWindow.instance:setVisible(true)
        DT_FactionInfoWindow.instance:addToUIManager()
        DT_FactionInfoWindow.instance:refreshList()
        return
    end

    local width = 900
    local height = 600
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    local window = DT_FactionInfoWindow:new(x, y, width, height)
    window:initialise()
    window:addToUIManager()
    DT_FactionInfoWindow.instance = window
end

function DT_FactionInfoWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function DT_FactionInfoWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "Faction Intelligence"
    o.resizable = true
    return o
end

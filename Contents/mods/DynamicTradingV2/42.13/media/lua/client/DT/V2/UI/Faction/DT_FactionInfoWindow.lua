-- ==============================================================================
-- media/lua/client/DT/V2/UI/Faction/DT_FactionInfoWindow.lua
-- Dedicated Info UI for Factions (Read-Only Version of Debug Window)
-- Build 42 Compatible
-- REF ACTOR: Tabbed Interface
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISTabPanel"
require "DT/V2/UI/Faction/DT_FactionList"
require "DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Info"
require "DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Reputation"
require "DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Events"
require "DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Stockpiles"
require "DT/V2/UI/Faction/Tabs/DT_FactionInfoTab_Population"

DT_FactionInfoWindow = ISPanel:derive("DT_FactionInfoWindow")

function DT_FactionInfoWindow:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_FactionInfoWindow:createChildren()
    -- 1. TITLE
    self.labelTitle = ISLabel:new(self.width/2, 10, 25, "FACTION INTELLIGENCE", 1, 1, 1, 1, UIFont.Large, true)

    self.labelTitle:initialise()
    self:addChild(self.labelTitle)

    -- 2. LIST BOX (Left Side) - Using our custom class
    local listWidth = 280
    self.listbox = DT_FactionList:new(10, 50, listWidth, self.height - 100)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.onmousedown = DT_FactionInfoWindow.onListMouseDown
    self:addChild(self.listbox)
    
    -- List Header Border
    self:drawRectBorder(10, 50, listWidth, self.height - 100, 0.5, 1, 1, 1)

    -- 3. TAB PANEL (Right Side)
    local tabX = 10 + listWidth + 10
    local tabWidth = self.width - tabX - 10
    local tabHeight = self.height - 100
    
    self.panel = ISTabPanel:new(tabX, 50, tabWidth, tabHeight)
    self.panel:initialise()
    self.panel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.panel.target = self
    -- self.panel.onActivateView = DT_FactionInfoWindow.onTabActivated -- Optional if we need lazy loading
    self:addChild(self.panel)

    -- 3.1. Create Tabs
    -- Info Tab
    self.tabInfo = DT_FactionInfoTab_Info:new(0, 0, tabWidth, tabHeight)
    self.tabInfo:initialise()
    self.panel:addView("Info", self.tabInfo)
    
    -- Reputation Tab
    self.tabReputation = DT_FactionInfoTab_Reputation:new(0, 0, tabWidth, tabHeight)
    self.tabReputation:initialise()
    self.panel:addView("Reputation", self.tabReputation)
    
    -- Events Tab
    self.tabEvents = DT_FactionInfoTab_Events:new(0, 0, tabWidth, tabHeight)
    self.tabEvents:initialise()
    self.panel:addView("Events", self.tabEvents)
    
    -- Stockpiles Tab
    self.tabStockpiles = DT_FactionInfoTab_Stockpiles:new(0, 0, tabWidth, tabHeight)
    self.tabStockpiles:initialise()
    self.panel:addView("Stockpiles", self.tabStockpiles)
    
    -- Population Tab
    self.tabPopulation = DT_FactionInfoTab_Population:new(0, 0, tabWidth, tabHeight)
    self.tabPopulation:initialise()
    self.panel:addView("Population", self.tabPopulation)

    -- 4. CLOSE BUTTON
    local btnWidth = 100
    self.btnClose = ISButton:new((self.width - btnWidth) / 2, self.height - 40, btnWidth, 25, "CLOSE", self, function(self) self:removeFromUIManager() end)
    self.btnClose:initialise()
    self.btnClose.backgroundColor = {r=0.5, g=0.1, b=0.1, a=0.8}
    self:addChild(self.btnClose)

    self:refreshList()
end

function DT_FactionInfoWindow:refreshList()
    -- Request Data
    if isClient() and not isServer() then
        sendClientCommand(getPlayer(), "DynamicTrading_V2", "RequestFactionData", {})
        return
    end
    
    -- Singleplayer Direct Access
    local factionData = ModData.get("DynamicTrading_Factions") or {}
    self:populateList(factionData)
end

function DT_FactionInfoWindow:populateList(factionData)
    self.listbox:clear()
    
    local keys = {}
    for id in pairs(factionData) do table.insert(keys, id) end
    table.sort(keys)

    for _, id in ipairs(keys) do
        local f = factionData[id]
        self.listbox:addItem(f.name or id, f)
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
        if win.tabEvents then win.tabEvents:updateData(f) end
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
            DT_FactionInfoWindow.instance:populateList(args.factions)
            
            -- If we had a selection, re-select it or clear tabs
            -- For simplicity, we might just leave it or try to find it again
            -- Ideally we re-trigger onListMouseDown if the selection is still valid
        end
    end
end

-- Reactive Refresh for Multiplayer (Static/Singleton level)
if not DT_FactionInfoWindow.EventsAdded then
    Events.OnReceiveGlobalModData.Add(function(key, data)
        if (key == "DynamicTrading_Factions" or key == "DynamicTrading_Roster") and DT_FactionInfoWindow.instance then
            if DT_FactionInfoWindow.instance:getIsVisible() then
                DT_FactionInfoWindow.instance:refreshList()
            end
        end
    end)
    Events.OnServerCommand.Add(onServerCommand)
    DT_FactionInfoWindow.EventsAdded = true
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

function DT_FactionInfoWindow:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0.9}
    o.borderColor = {r=0.6, g=0.6, b=0.6, a=1}
    o.moveWithMouse = true
    return o
end


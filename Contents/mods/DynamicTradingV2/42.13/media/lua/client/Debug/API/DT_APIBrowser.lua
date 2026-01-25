-- ==============================================================================
-- DT_APIBrowser.lua
-- Standalone Window for browsing Project Zomboid Lua API / Engine Methods.
-- ==============================================================================

-- if not isDebugEnabled() then return end

require "client/Debug/API/DT_APIViePanel"

DT_APIBrowser = ISCollapsableWindow:derive("DT_APIBrowser")
DT_APIBrowser.instance = nil

function DT_APIBrowser:initialise()
    ISCollapsableWindow.initialise(self)
    self.resizable = true
end

function DT_APIBrowser:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = 25 -- tab height
    self.tabPanel = ISTabPanel:new(0, 20, self.width, self.height - 20)
    self.tabPanel:initialise()
    self.tabPanel.target = self
    
    -- Override activateView to refresh when switching tabs
    local oldActivateView = self.tabPanel.activateView
    self.tabPanel.activateView = function(p, name)
        oldActivateView(p, name)
        self:refresh()
    end
    self:addChild(self.tabPanel)

    local viewW = self.tabPanel.width
    local viewH = self.tabPanel.height - (self.tabPanel.tabHeight or 25)
    print("DT_APIBrowser:createChildren viewW=" .. tostring(viewW) .. " viewH=" .. tostring(viewH))

    -- 1. ZOMBIE TAB
    self.zombiePanel = DT_APIViePanel:new(0, 0, viewW, viewH)
    self.zombiePanel:initialise()
    self.tabPanel:addView("Zombie", self.zombiePanel)

    -- 2. PLAYER TAB
    self.playerPanel = DT_APIViePanel:new(0, 0, viewW, viewH)
    self.playerPanel:initialise()
    self.tabPanel:addView("Player", self.playerPanel)

    -- 3. INVENTORY TAB
    self.invPanel = DT_APIViePanel:new(0, 0, viewW, viewH)
    self.invPanel:initialise()
    self.tabPanel:addView("Inventory", self.invPanel)

    -- 4. ITEM TAB
    self.itemPanel = DT_APIViePanel:new(0, 0, viewW, viewH)
    self.itemPanel:initialise()
    self.tabPanel:addView("Item", self.itemPanel)

    -- 5. WORLD TAB
    self.worldPanel = DT_APIViePanel:new(0, 0, viewW, viewH)
    self.worldPanel:initialise()
    self.tabPanel:addView("World", self.worldPanel)

    -- 6. CORE TAB
    self.corePanel = DT_APIViePanel:new(0, 0, viewW, viewH)
    self.corePanel:initialise()
    self.tabPanel:addView("Core", self.corePanel)

    self:refresh()
end

function DT_APIBrowser:refresh()
    if not self.tabPanel or not self.tabPanel.viewList then return end
    
    local player = getPlayer()
    local activeView = nil
    local av = self.tabPanel.activeView
    
    -- Robust tab detection
    if type(av) == "number" and self.tabPanel.viewList[av] then
        activeView = self.tabPanel.viewList[av]
    elseif type(av) == "table" and av.name then
        activeView = av
    elseif self.tabPanel:getActiveViewName() then
        local name = self.tabPanel:getActiveViewName()
        for _, v in ipairs(self.tabPanel.viewList) do
            if v.name == name then activeView = v; break end
        end
    end

    print("DT_APIBrowser:refresh() activeViewIndex=" .. tostring(av) .. " found=" .. tostring(activeView ~= nil))
    if not activeView then return end
    
    local activeTab = activeView.name
    print("DT_APIBrowser:refresh() activeTab=" .. tostring(activeTab))
    
    if activeTab == "Zombie" then
        local cell = getCell()
        local firstZombie = nil
        if cell then
            local zombies = cell:getZombieList()
            if zombies and not zombies:isEmpty() then 
                firstZombie = zombies:get(0) 
            end
        end
        self.zombiePanel:setObject(firstZombie, "IsoZombie")
    
    elseif activeTab == "Player" then
        self.playerPanel:setObject(player, "IsoPlayer")
    
    elseif activeTab == "Inventory" then
        if player then
            self.invPanel:setObject(player:getInventory(), "ItemContainer")
        else
            self.invPanel:setObject(nil, "ItemContainer")
        end
    
    elseif activeTab == "Item" then
        if player and player:getInventory() then
            local items = player:getInventory():getItems()
            if items and not items:isEmpty() then
                self.itemPanel:setObject(items:get(0), "InventoryItem")
            else
                self.itemPanel:setObject(nil, "InventoryItem")
            end
        else
            self.itemPanel:setObject(nil, "InventoryItem")
        end
    
    elseif activeTab == "World" then
        self.worldPanel:setObject(getCell(), "IsoCell / World")

    elseif activeTab == "Core" then
        self.corePanel:setObject(getCore(), "GameCore")
    end
end

function DT_APIBrowser.OnOpenWindow()
    if DT_APIBrowser.instance then
        DT_APIBrowser.instance:setVisible(not DT_APIBrowser.instance:getIsVisible())
        if DT_APIBrowser.instance:getIsVisible() then
            DT_APIBrowser.instance:refresh()
        end
        return
    end

    local window = DT_APIBrowser:new(150, 150, 600, 700)
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)
    window:setTitle("DT API Browser")
    DT_APIBrowser.instance = window
end

return DT_APIBrowser

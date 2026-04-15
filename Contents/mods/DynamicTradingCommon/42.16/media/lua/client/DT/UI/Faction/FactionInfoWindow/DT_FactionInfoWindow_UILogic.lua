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
    self.listbox.target = self
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
                 local rosterData = DT_FactionInfoWindow.cachedRosterData or ModData.get("DynamicTrading_Roster") or {}
                 activeView:updateData(DT_FactionInfoWindow.selectedFaction, rosterData)
            end
        end
    end
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

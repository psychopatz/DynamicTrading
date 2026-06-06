function DT_FactionInfoWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 800
    self.minimumHeight = 500
    
    self.fontScale = "Medium"
end

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

function DT_FactionInfoWindow:getFontScale()
    if self.width > 1400 then return "Large" end
    if self.width > 1000 then return "Medium" end
    return "Small"
end

function DT_FactionInfoWindow.GetTabContentView(view)
    if not view then
        return nil
    end
    if view.updateData then
        return view
    end
    if view.view and view.view.updateData then
        return view.view
    end
    if view.panel and view.panel.updateData then
        return view.panel
    end
    return view
end

function DT_FactionInfoWindow:GetSelectedListFaction()
    if not self.listbox or not self.listbox.items then
        return nil
    end

    local selected = tonumber(self.listbox.selected) or 0
    local entry = selected > 0 and self.listbox.items[selected] or nil
    return entry and entry.item or nil
end

function DT_FactionInfoWindow:refreshSelectedFactionView(requestRoster)
    local currentListFaction = self:GetSelectedListFaction()
    local faction = currentListFaction or DT_FactionInfoWindow.selectedFaction
    if not faction then
        return false
    end

    DT_FactionInfoWindow.selectedFaction = faction
    self.selectedFaction = faction

    local roster = DT_FactionInfoWindow.resolveRosterData and DT_FactionInfoWindow.resolveRosterData()
        or DT_FactionInfoWindow.lastRosterData
        or {}
    DT_FactionInfoWindow.lastRosterData = roster

    if self.updateOwnedFactionStatus then
        self:updateOwnedFactionStatus(DT_FactionInfoWindow.cachedOwnedFactionStatus, faction)
    end
    if self.tabInfo and self.tabInfo.updateData then
        self.tabInfo:updateData(faction, roster)
    end

    local activeView = self.panel and DT_FactionInfoWindow.GetTabContentView(self.panel:getActiveView()) or nil
    if activeView and activeView.updateData then
        activeView:updateData(faction, roster)
        if activeView.onResize then
            activeView:onResize()
        end
    end

    if requestRoster == true
        and isClient()
        and not isServer()
        and not faction.isV1
        and not faction.playerOwned then
        sendClientCommand(getSpecificPlayer(0), "DynamicTrading_V2", "RequestFactionRoster", { factionID = faction.id })
    end

    return true
end

local function trimFactionName(value)
    local text = tostring(value or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function getCurrentPlayerCharacterName(player)
    if player and player.getDescriptor then
        local descriptor = player:getDescriptor()
        if descriptor and descriptor.getForename then
            local forename = trimFactionName(descriptor:getForename())
            local surname = trimFactionName(descriptor.getSurname and descriptor:getSurname() or "")
            local fullName = trimFactionName(forename .. " " .. surname)
            if fullName ~= "" then
                return fullName
            end
            if forename ~= "" then
                return forename
            end
        end
    end

    if player and player.getUsername then
        local username = trimFactionName(player:getUsername())
        if username ~= "" then
            return username
        end
    end

    return T("DTCommon_UI_Faction_MyFaction", nil, "My Faction")
end

function DT_FactionInfoWindow:openOwnedFactionManagementWindow()
    if DC_System and DC_System.OpenWindow then
        DC_System.OpenWindow()
    end
end

function DT_FactionInfoWindow:submitOwnedFactionName(action, name)
    local player = getSpecificPlayer and getSpecificPlayer(0) or getPlayer and getPlayer() or nil
    if not player then
        return
    end

    local command = action == "rename" and "RenamePlayerFaction" or "CreatePlayerFaction"
    local args = { name = trimFactionName(name) }

    if isClient() and not isServer() then
        sendClientCommand(player, "DynamicTrading_V2", command, args)
        return
    end

    if not DynamicTrading_Factions then
        return
    end

    local ok = false
    local message = nil
    if action == "rename" and DynamicTrading_Factions.RenamePlayerFaction then
        ok, message = DynamicTrading_Factions.RenamePlayerFaction(player, args.name)
    elseif DynamicTrading_Factions.CreatePlayerFaction then
        ok, message = DynamicTrading_Factions.CreatePlayerFaction(player, args.name)
    end

    if self.refreshList then
        self:refreshList()
    end
    if ok and self.pendingOpenOwnedFactionWindowAfterAction then
        self.pendingOpenOwnedFactionWindowAfterAction = nil
        self:openOwnedFactionManagementWindow()
    elseif not ok then
        self.pendingOpenOwnedFactionWindowAfterAction = nil
        if DT_PlayerFactionMembersModal and DT_PlayerFactionMembersModal.instance and message then
            DT_PlayerFactionMembersModal.instance:setStatus(message)
        end
    end
end

function DT_FactionInfoWindow:promptOwnedFactionName(action, ownedStatus)
    if not DT_PlayerFactionNameModal or not DT_PlayerFactionNameModal.Open then
        return
    end

    local player = getSpecificPlayer and getSpecificPlayer(0) or getPlayer and getPlayer() or nil
    if not player then
        return
    end

    local defaultName = nil
    if action == "rename" then
        defaultName = trimFactionName(ownedStatus and ownedStatus.faction and ownedStatus.faction.name or "")
    end
    if defaultName == nil or defaultName == "" then
        defaultName = getCurrentPlayerCharacterName(player)
    end

    DT_PlayerFactionNameModal.Open({
        title = action == "rename"
            and T("DTCommon_UI_Faction_RenameTitle", nil, "Rename Faction")
            or T("DTCommon_UI_Faction_NameTitle", nil, "Faction Name"),
        promptText = action == "rename"
            and T("DTCommon_UI_Faction_RenamePrompt", nil, "Choose a new name for your faction.")
            or T("DTCommon_UI_Faction_NamePrompt", nil, "Enter a faction name."),
        confirmLabel = action == "rename"
            and T("DTCommon_UI_Faction_Rename", nil, "Rename")
            or T("DTCommon_UI_Faction_Create", nil, "Create"),
        defaultValue = defaultName,
        onConfirm = function(name)
            self.pendingOpenOwnedFactionWindowAfterAction = action == "create"
            self:submitOwnedFactionName(action, name)
        end
    })
end

function DT_FactionInfoWindow:maybeAutoPromptFactionCreation(status)
    return
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

    -- 1.1 FOOTER PANEL (Centered with margins to avoid resize handle)
    local footerHeight = 44
    local footerMargin = 10
    local bottomMargin = 10
    self.footerPanel = DT_FactionInfoFooterPanel:new(footerMargin, h - footerHeight - bottomMargin, w - (footerMargin * 2), footerHeight)
    self.footerPanel:initialise()
    self.footerPanel:setAnchorRight(true)
    self.footerPanel:setAnchorLeft(true)
    self.footerPanel:setAnchorBottom(true)
    self.footerPanel:setAnchorTop(false)
    self.footerPanel.parent = self
    self:addChild(self.footerPanel)

    -- Layout Vars
    local listY = th + headerHeight
    local footerHeight = 44
    local footerPadding = 10 -- Space between content and footer
    local bottomMargin = 10
    local contentHeight = h - listY - footerHeight - footerPadding - bottomMargin
    local listWidth = 290

    -- 2. LIST BOX (Left Side)
    self.listbox = DT_FactionList:new(0, listY, listWidth, contentHeight)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.target = self
    self.listbox.onmousedown = DT_FactionInfoWindow.onListMouseDown
    -- Anchors
    self.listbox:setAnchorLeft(true)
    self.listbox:setAnchorTop(true)
    self.listbox:setAnchorBottom(true)
    -- 3. TAB PANEL (Right Side)
    local tabX = listWidth + 10
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
    self:addChild(self.listbox)
    
    -- Sync Active View logic override
    self.panel.onActivateView = function(view)
        if DT_FactionInfoWindow.instance and DT_FactionInfoWindow.instance.refreshSelectedFactionView then
            DT_FactionInfoWindow.instance:refreshSelectedFactionView(false)
            return
        end
        local contentView = DT_FactionInfoWindow.GetTabContentView(view)
        if contentView and contentView.updateData then
            local f = DT_FactionInfoWindow.selectedFaction
            local roster = DT_FactionInfoWindow.lastRosterData or DT_FactionInfoWindow.resolveRosterData()
            DT_FactionInfoWindow.lastRosterData = roster
            contentView:updateData(f, roster)
            if contentView.onResize then contentView:onResize() end
        end
    end


    -- 3.1. Create Tabs
    -- Info Tab
    self.tabInfo = DT_FactionInfoTab_Info:new(0, 0, tabWidth, contentHeight)
    self.tabInfo:initialise()
    self.tabInfo:setAnchorRight(true)
    self.tabInfo:setAnchorBottom(true)
    self.panel:addView(T("DTCommon_UI_Faction_Info", nil, "Info"), self.tabInfo)
    
    -- Reputation Tab
    self.tabReputation = DT_FactionInfoTab_Reputation:new(0, 0, tabWidth, contentHeight)
    self.tabReputation:initialise()
    self.tabReputation:setAnchorRight(true)
    self.tabReputation:setAnchorBottom(true)
    self.panel:addView(T("DTCommon_UI_Faction_Reputation", nil, "Reputation"), self.tabReputation)
    
    -- Economics Tab (Was Events)
    self.tabEconomics = DT_FactionInfoTab_Economics:new(0, 0, tabWidth, contentHeight)
    self.tabEconomics:initialise()
    self.tabEconomics:setAnchorRight(true)
    self.tabEconomics:setAnchorBottom(true)
    self.panel:addView(T("DTCommon_UI_Faction_Economics", nil, "Economics"), self.tabEconomics)

    -- Calendar Tab
    self.tabCalendar = DT_FactionInfoTab_Calendar:new(0, 0, tabWidth, contentHeight)
    self.tabCalendar:initialise()
    self.tabCalendar:setAnchorRight(true)
    self.tabCalendar:setAnchorBottom(true)
    self.panel:addView(T("DTCommon_UI_Faction_Calendar", nil, "Calendar"), self.tabCalendar)
    
    -- Stockpiles Tab
    self.tabStockpiles = DT_FactionInfoTab_Stockpiles:new(0, 0, tabWidth, contentHeight)
    self.tabStockpiles:initialise()
    self.tabStockpiles:setAnchorRight(true)
    self.tabStockpiles:setAnchorBottom(true)
    self.panel:addView(T("DTCommon_UI_Faction_Stockpiles", nil, "Stockpiles"), self.tabStockpiles)
    
    -- Population Tab
    self.tabPopulation = DT_FactionInfoTab_Population:new(0, 0, tabWidth, contentHeight)
    self.tabPopulation:initialise()
    self.tabPopulation:setAnchorRight(true)
    self.tabPopulation:setAnchorBottom(true)
    self.panel:addView(T("DTCommon_UI_Faction_Population", nil, "Population"), self.tabPopulation)

    -- Infrastructure Tab (Requires Dynamic Colonies)
    if getActivatedMods():contains("DynamicColonies") then
        self.tabInfrastructure = DT_FactionInfoTab_Infrastructure:new(0, 0, tabWidth, contentHeight)
        self.tabInfrastructure:initialise()
        self.tabInfrastructure:setAnchorRight(true)
        self.tabInfrastructure:setAnchorBottom(true)
        self.panel:addView(T("DTCommon_UI_Faction_Infrastructure", nil, "Infrastructure"), self.tabInfrastructure)
    end
    
    self:refreshList()
end

function DT_FactionInfoWindow:prerender()
    ISCollapsableWindow.prerender(self)
    local th = self:titleBarHeight()
    local headerHeight = 60
    local listY = th + headerHeight
    local listWidth = 290
    local footerHeight = 44
    local footerPadding = 10
    local bottomMargin = 10
    local contentHeight = self.height - listY - footerHeight - footerPadding - bottomMargin
    
    self:drawRectBorder(0, listY, listWidth, contentHeight, 0.5, 1, 1, 1)
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
        local activeView = DT_FactionInfoWindow.GetTabContentView(self.panel:getActiveView())
        if activeView then
            activeView:setWidth(self.panel:getWidth())
            activeView:setHeight(self.panel:getHeight() - self.panel.tabHeight)
            if activeView.onResize then activeView:onResize() end
            if activeView.updateData and self.refreshSelectedFactionView then
                 self:refreshSelectedFactionView(false)
            end
        end
    end
end

function DT_FactionInfoWindow.ToggleWindow(device)
    if DT_RadioScannerWindow and DT_RadioScannerWindow.instance and DT_RadioScannerWindow.instance:getIsVisible() then
        DT_RadioScannerWindow.instance:close()
    end
    if DC_SupplyWindow and DC_SupplyWindow.instance and DC_SupplyWindow.instance:getIsVisible() then
        DC_SupplyWindow.instance:close()
    end

    if DT_FactionInfoWindow.instance then
        if DT_FactionInfoWindow.instance:getIsVisible() then
            DT_FactionInfoWindow.instance:close()
        else
            DT_FactionInfoWindow.instance.device = device
            DT_FactionInfoWindow.instance:setVisible(true)
            DT_FactionInfoWindow.instance:addToUIManager()
            DT_FactionInfoWindow.instance:refreshList()
        end
        return
    end

    DT_FactionInfoWindow.Open(device)
end

function DT_FactionInfoWindow.Open(device)
    if DT_RadioScannerWindow and DT_RadioScannerWindow.instance and DT_RadioScannerWindow.instance:getIsVisible() then
        DT_RadioScannerWindow.instance:close()
    end
    if DC_SupplyWindow and DC_SupplyWindow.instance and DC_SupplyWindow.instance:getIsVisible() then
        DC_SupplyWindow.instance:close()
    end

    if DT_FactionInfoWindow.instance then
        DT_FactionInfoWindow.instance.device = device
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
    window.device = device
    window:initialise()
    window:addToUIManager()
    DT_FactionInfoWindow.instance = window
end

function DT_FactionInfoWindow:close()
    DT_FactionInfoWindow.lastRosterData = nil
    self:setVisible(false)
    self:removeFromUIManager()
end

function DT_FactionInfoWindow:update()
    ISCollapsableWindow.update(self)

    if self:getIsVisible() then
        local player = getSpecificPlayer(0)
        if not player then return end

        -- Radio Requirement Check
        if DT_RadioScannerManager and DT_RadioScannerManager.HasActiveRadio then
            local activeDevice = DT_RadioScannerManager.HasActiveRadio(player, self.device)
            if not activeDevice then
                self:close()
                if HaloTextHelper then
                    HaloTextHelper.addTextWithArrow(player, T("DTCommon_UI_Faction_SignalLost", nil, "Signal Lost (Radio Off/Missing)"), true, HaloTextHelper.getColorRed())
                end
            else
                self.device = activeDevice
            end
        end
    end
end

function DT_FactionInfoWindow:updateOwnedFactionStatus(status, selectedFaction)
    if self.headerPanel and self.headerPanel.updateOwnedFactionStatus then
        self.headerPanel:updateOwnedFactionStatus(status, selectedFaction)
    end
    if self.footerPanel and self.footerPanel.updateOwnedFactionStatus then
        self.footerPanel:updateOwnedFactionStatus(status)
    end
end

function DT_FactionInfoWindow:onRadarButton()
    if DT_RadioScannerWindow and DT_RadioScannerWindow.ToggleWindow then
        DT_RadioScannerWindow.ToggleWindow(self.device)
    end
end

function DT_FactionInfoWindow:onFactionMembersButton(ownedStatus)
    if DT_PlayerFactionMembersModal and DT_PlayerFactionMembersModal.Open then
        DT_PlayerFactionMembersModal.Open(ownedStatus)
    end
end

function DT_FactionInfoWindow:onOwnedFactionButton(ownedStatus)
    self:openOwnedFactionManagementWindow()
end

function DT_FactionInfoWindow:onRenameFactionButton(ownedStatus)
    if not ownedStatus or not ownedStatus.faction then
        return
    end

    if ownedStatus.permissions and ownedStatus.permissions.canRenameFaction == true then
        self:promptOwnedFactionName("rename", ownedStatus)
    end
end

function DT_FactionInfoWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = T("DTCommon_UI_Faction_Intelligence", nil, "Faction Intelligence")
    o.resizable = true
    return o
end

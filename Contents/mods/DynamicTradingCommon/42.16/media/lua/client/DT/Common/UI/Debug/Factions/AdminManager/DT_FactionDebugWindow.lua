-- ==============================================================================
-- DT_FactionDebugWindow.lua
-- Faction Debug Tool: Main UI Window
-- Dedicated UI for Managing Factions
-- Build 42 Compatible
-- ==============================================================================

require "DT/Common/UI/Debug/Factions/AdminManager/DT_FactionDebugData"
require "DT/Common/UI/Debug/Factions/AdminManager/DT_FactionDebugRenderers"
require "DT/Common/UI/Debug/Factions/AdminManager/DT_FactionDebugActions"

DT_FactionDebugWindow = ISPanel:derive("DT_FactionDebugWindow")

function DT_FactionDebugWindow:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_FactionDebugWindow:createChildren()
    local x, y = 10, 10
    
    -- 1. TITLE
    self.labelTitle = ISLabel:new(self.width/2, 10, 25, "FACTION MANAGEMENT", 1, 1, 1, 1, UIFont.Large, true)
    self.labelTitle:initialise()
    self:addChild(self.labelTitle)

    -- 2. LIST BOX (Left Side)
    local listWidth = 250
    self.listbox = ISScrollingListBox:new(10, 45, listWidth, self.height - 140)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.itemheight = 40
    self.listbox.doDrawItem = DT_FactionDebugRenderers.drawFactionItem
    self.listbox.onmousedown = function(target, item) 
        DT_FactionDebugWindow.instance:onFactionSelected(item) 
    end
    self:addChild(self.listbox)

    -- 3. DETAIL PANEL (Middle)
    local detailsX = 10 + listWidth + 10
    local detailsWidth = 300
    self.details = ISRichTextPanel:new(detailsX, 45, detailsWidth, self.height - 140)
    self.details:initialise()
    self.details.backgroundColor = {r=0, g=0, b=0, a=0.5}
    self.details:addScrollBars()
    self:addChild(self.details)
    self.details:setText("Select a faction.")

    -- 4. ROSTER LIST (Right Side)
    local rosterX = detailsX + detailsWidth + 10
    local rosterWidth = self.width - rosterX - 10
    self.rosterlist = ISScrollingListBox:new(rosterX, 45, rosterWidth, self.height - 180)
    self.rosterlist:initialise()
    self.rosterlist:instantiate()
    self.rosterlist.itemheight = 45
    self.rosterlist.doDrawItem = DT_FactionDebugRenderers.drawRosterItem
    self.rosterlist.onmousedown = function(target, item) 
        DT_FactionDebugWindow.instance:onRosterSelected(item) 
    end
    self.rosterlist.backgroundColor = {r=0, g=0, b=0, a=0.5}
    self:addChild(self.rosterlist)

    -- 5. BUTTONS (Centered at bottom)
    local btnWidth = 120
    local totalBtnWidth = (btnWidth * 4) + 30
    local startBtnX = (self.width - totalBtnWidth) / 2
    local btnY = self.height - 40
    
    self.btnRefresh = ISButton:new(startBtnX, btnY, btnWidth, 25, "REFRESH", self, DT_FactionDebugWindow.onRefreshClick)
    self.btnRefresh:initialise()
    self.btnRefresh.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1}
    self:addChild(self.btnRefresh)

    self.btnSim = ISButton:new(startBtnX + btnWidth + 10, btnY, btnWidth, 25, "SIMULATE DAY", self, function()
        DT_FactionDebugActions.simulateDay()
    end)
    self.btnSim:initialise()
    self.btnSim.backgroundColor = {r=0.2, g=0.2, b=0.5, a=1}
    self:addChild(self.btnSim)

    self.btnWipe = ISButton:new(startBtnX + (btnWidth + 10) * 2, btnY, btnWidth, 25, "WIPE ALL", self, function()
        DT_FactionDebugActions.wipeFactions()
    end)
    self.btnWipe:initialise()
    self.btnWipe.backgroundColor = {r=0.5, g=0.2, b=0.2, a=1}
    self:addChild(self.btnWipe)

    self.btnClose = ISButton:new(startBtnX + (btnWidth + 10) * 3, btnY, btnWidth, 25, "CLOSE", self, function(self) 
        self:setVisible(false)
        self:removeFromUIManager() 
    end)
    self.btnClose:initialise()
    self:addChild(self.btnClose)

    -- 6. SELECTED FACTION CONTROLS
    local ctrlX = detailsX
    local ctrlY = self.height - 75
    local ctrlBtnWidth = 100

    self.btnWealthAdd = ISButton:new(ctrlX, ctrlY, ctrlBtnWidth, 20, "+ WEALTH", self, function()
        local f = self.listbox.items[self.listbox.selected]
        if f then
            DT_FactionDebugActions.modifyWealth(f.item.id, 1000)
        end
    end)
    self.btnWealthAdd:initialise()
    self:addChild(self.btnWealthAdd)

    self.btnWealthSub = ISButton:new(ctrlX + ctrlBtnWidth + 5, ctrlY, ctrlBtnWidth, 20, "- WEALTH", self, function()
        local f = self.listbox.items[self.listbox.selected]
        if f then
            DT_FactionDebugActions.modifyWealth(f.item.id, -1000)
        end
    end)
    self.btnWealthSub:initialise()
    self:addChild(self.btnWealthSub)

    self.btnRepAdd = ISButton:new(ctrlX + (ctrlBtnWidth + 5) * 2, ctrlY, ctrlBtnWidth, 20, "+ REP", self, function()
        local f = self.listbox.items[self.listbox.selected]
        if f then
            if self.selectedMemberUUID then
                DT_FactionDebugActions.modifyPersonalReputation(self.selectedMemberUUID, f.item.id, 10)
            else
                DT_FactionDebugActions.modifyReputation(f.item.id, 10)
            end
        end
    end)
    self.btnRepAdd:initialise()
    self:addChild(self.btnRepAdd)

    self.btnRepSub = ISButton:new(ctrlX + (ctrlBtnWidth + 5) * 3, ctrlY, ctrlBtnWidth, 20, "- REP", self, function()
        local f = self.listbox.items[self.listbox.selected]
        if f then
            if self.selectedMemberUUID then
                DT_FactionDebugActions.modifyPersonalReputation(self.selectedMemberUUID, f.item.id, -10)
            else
                DT_FactionDebugActions.modifyReputation(f.item.id, -10)
            end
        end
    end)
    self.btnRepSub:initialise()
    self:addChild(self.btnRepSub)

    -- 7. LOCATE NPC BUTTON (Under Roster)
    local locateX = rosterX
    local locateY = self.height - 130
    local locateWidth = 150

    self.btnLocate = ISButton:new(locateX, locateY, locateWidth, 25, "LOCATE NPC", self, DT_FactionDebugWindow.onLocateClick)
    self.btnLocate:initialise()
    self.btnLocate.backgroundColor = {r=0.2, g=0.2, b=0.7, a=1}
    self.btnLocate.enable = false
    self:addChild(self.btnLocate)

    self.btnForceTrade = ISButton:new(locateX + locateWidth + 10, locateY, locateWidth, 25, "FORCE TRADE", self, DT_FactionDebugWindow.onForceTradeClick)
    self.btnForceTrade:initialise()
    self.btnForceTrade.backgroundColor = {r=0.7, g=0.2, b=0.2, a=1}
    self.btnForceTrade.enable = false
    self:addChild(self.btnForceTrade)

    local spawnY = locateY + 35
    self.archCombo = ISComboBox:new(locateX, spawnY, 220, 25, self, nil)
    self.archCombo:initialise()
    self.archCombo:instantiate()
    self:addChild(self.archCombo)

    self.btnSpawnTrader = ISButton:new(locateX + 230, spawnY, 170, 25, "SPAWN TRADER", self, DT_FactionDebugWindow.onSpawnTraderClick)
    self.btnSpawnTrader:initialise()
    self.btnSpawnTrader.backgroundColor = {r=0.5, g=0.35, b=0.1, a=1}
    self:addChild(self.btnSpawnTrader)

    -- FORCE EVENT BUTTON
    self.btnForceEvent = ISButton:new(ctrlX + (ctrlBtnWidth + 5) * 4, ctrlY, ctrlBtnWidth, 20, "FORCE EVENT", self, DT_FactionDebugWindow.onForceEventClick)
    self.btnForceEvent:initialise()
    self.btnForceEvent.backgroundColor = {r=0.7, g=0.5, b=0, a=1}
    self:addChild(self.btnForceEvent)

    -- MERCHANT STOCK BUTTON
    self.btnMerchant = ISButton:new(ctrlX + (ctrlBtnWidth + 5) * 5, ctrlY, ctrlBtnWidth, 20, "MERCHANTS", self, function()
        if DT_MerchantDebugWindow and DT_MerchantDebugWindow.Open then
            DT_MerchantDebugWindow.Open()
        end
    end)
    self.btnMerchant:initialise()
    self.btnMerchant.backgroundColor = {r=0, g=0.5, b=0.5, a=1}
    self:addChild(self.btnMerchant)

    self:refreshList()
    self:refreshArchetypeOptions()
end

-- ==========================================================
-- DATA MANAGEMENT
-- ==========================================================
function DT_FactionDebugWindow:refreshList()
    DT_FactionDebugData.refreshFactionList(function(factionData, rosterData)
        if DT_FactionDebugWindow.instance and DT_FactionDebugWindow.instance:getIsVisible() then
            DT_FactionDebugWindow.instance:populateList(factionData)
            -- Cache roster data for later use
            if rosterData then
                DT_FactionDebugData.cachedRosterData = rosterData
            end
        end
    end)
end

function DT_FactionDebugWindow:populateList(factionData)
    if not factionData then return end
    self.listbox:clear()
    
    local sorted = DT_FactionDebugData.getSortedFactionList(factionData)
    for _, entry in ipairs(sorted) do
        self.listbox:addItem(entry.data.name or entry.id, entry.data)
    end

    self:refreshArchetypeOptions()
end

function DT_FactionDebugWindow:refreshArchetypeOptions()
    if not self.archCombo then
        return
    end

    local previousText = self.archCombo.selected and self.archCombo:getOptionText(self.archCombo.selected) or nil
    self.archCombo:clear()
    self.availableArchetypes = {}

    local archetypeIDs = {}
    for id, _ in pairs(DynamicTrading.Archetypes or {}) do
        table.insert(archetypeIDs, id)
    end
    table.sort(archetypeIDs)

    local selectedIndex = 1
    for index, archetypeID in ipairs(archetypeIDs) do
        self.archCombo:addOption(archetypeID)
        self.availableArchetypes[index] = archetypeID
        if previousText == archetypeID then
            selectedIndex = index
        end
    end

    self.archCombo.selected = #self.availableArchetypes > 0 and selectedIndex or 0
    if self.btnSpawnTrader then
        self.btnSpawnTrader.enable = #self.availableArchetypes > 0
    end
end

function DT_FactionDebugWindow:getSelectedArchetypeID()
    local selected = self.archCombo and self.archCombo.selected or 0
    return self.availableArchetypes and self.availableArchetypes[selected] or nil
end

-- ==========================================================
-- SELECTION HANDLERS
-- ==========================================================
function DT_FactionDebugWindow:onFactionSelected(item)
    local faction = item
    
    -- Update details panel
    local text = DT_FactionDebugData.formatFactionDetails(faction)
    self.details:setText(text)
    self.details:paginate()

    -- Repopulate Roster List
    self.rosterlist:clear()
    self.selectedMemberUUID = nil
    self.selectedMemberSoul = nil
    self.btnLocate.enable = false
    self.btnForceTrade.enable = false
    
    -- Use cached roster data
    local rosterData = DT_FactionDebugData.cachedRosterData or ModData.get("DynamicTrading_Roster")
    
    if rosterData then
        local roster = DT_FactionDebugData.getRosterForFaction(faction.id, rosterData)
        for _, entry in ipairs(roster) do
            self.rosterlist:addItem(entry.soul.name or entry.uuid, entry)
        end
    end

    -- Request detailed roster in multiplayer (if not from sync)
    if isClient() and not isServer() then
        DT_FactionDebugData.refreshRosterForFaction(faction.id, function(rosterData, factionID)
            -- Refresh roster list with new data
            if DT_FactionDebugWindow.instance and DT_FactionDebugWindow.instance.listbox.selected then
                local selected = DT_FactionDebugWindow.instance.listbox.items[DT_FactionDebugWindow.instance.listbox.selected]
                if selected and selected.item.id == factionID then
                    DT_FactionDebugWindow.instance:onFactionSelected(selected.item)
                end
            end
        end)
    end
end

function DT_FactionDebugWindow:onRosterSelected(item)
    self.selectedMemberUUID = item.uuid
    self.selectedMemberSoul = item.soul
    self.btnLocate.enable = true
    self.btnForceTrade.enable = true
end

-- ==========================================================
-- BUTTON HANDLERS
-- ==========================================================
function DT_FactionDebugWindow:onRefreshClick()
    self:refreshList()
end

function DT_FactionDebugWindow:onLocateClick()
    local item = self.rosterlist.items[self.rosterlist.selected]
    if item and item.item then
        DT_FactionDebugActions.locateNPC(item.item.uuid, item.item.soul)
    end
end

function DT_FactionDebugWindow:onForceTradeClick()
    local item = self.rosterlist.items[self.rosterlist.selected]
    if item and item.item then
        DT_FactionDebugActions.forceTradeMission(item.item.uuid, item.item.soul)
    end
end

function DT_FactionDebugWindow:onForceEventClick()
    local f = self.listbox.items[self.listbox.selected]
    if f then
        DT_FactionDebugActions.showEventSelection(f.item.id, getMouseX(), getMouseY())
    end
end

function DT_FactionDebugWindow:onSpawnTraderClick()
    local archetypeID = self:getSelectedArchetypeID()
    if not archetypeID then
        return
    end

    DT_FactionDebugActions.forceTraderByArchetype(archetypeID)
end

-- ==========================================================
-- REACTIVE REFRESH (Multiplayer)
-- ==========================================================
if not DT_FactionDebugWindow.EventsAdded then
    Events.OnReceiveGlobalModData.Add(function(key, data)
        if (key == "DynamicTrading_Factions" or key == "DynamicTrading_Roster") and DT_FactionDebugWindow.instance then
            if DT_FactionDebugWindow.instance:getIsVisible() then
                DT_FactionDebugWindow.instance:refreshList()
            end
        end
    end)
    DT_FactionDebugWindow.EventsAdded = true
end

-- ==========================================================
-- SINGLETON ACCESS
-- ==========================================================
function DT_FactionDebugWindow.Open()
    if DT_FactionDebugWindow.instance then
        DT_FactionDebugWindow.instance:setVisible(true)
        DT_FactionDebugWindow.instance:addToUIManager()
        DT_FactionDebugWindow.instance:refreshList()
        return
    end

    local window = DT_FactionDebugWindow:new(100, 100, 1000, 500)
    window:initialise()
    window:addToUIManager()
    DT_FactionDebugWindow.instance = window
    window:refreshList()
end

function DT_FactionDebugWindow:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.borderColor = {r=1, g=1, b=1, a=1}
    o.moveWithMouse = true
    return o
end

DynamicTrading.Log("DTCommons", "Debug", "UI", "Faction Debug Window Loaded")

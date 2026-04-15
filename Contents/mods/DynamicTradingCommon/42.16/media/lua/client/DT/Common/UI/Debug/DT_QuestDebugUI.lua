-- =============================================================================
-- DT_QuestDebugUI: Debug Tool for Quest System
-- =============================================================================

DT_QuestDebugUI = ISCollapsableWindow:derive("DT_QuestDebugUI")
DT_QuestDebugUI.instance = nil

function DT_QuestDebugUI:initialise()
    ISCollapsableWindow.initialise(self)
end

function DT_QuestDebugUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local x, y = 10, self:titleBarHeight() + 10
    local btnH = 25
    local labelW = 100

    -- DIFFICULTY SLIDER
    self.labelDiff = ISLabel:new(x, y, btnH, "Difficulty:", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.labelDiff)
    
    self.valDiff = ISLabel:new(x + labelW + 160, y, btnH, "1.0", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(self.valDiff)

    self.sliderDiff = ISVolumeControl:new(x + labelW, y, 150, btnH, self, self.onDifficultyChange)
    self.sliderDiff:initialise()
    self.sliderDiff:setVolume(0.1) -- Represents 1.0 (default)
    self:addChild(self.sliderDiff)
    y = y + 40


    -- ITEM LIST
    self.list = ISScrollingListBox:new(x, y, self.width - 20, 200)
    self.list:initialise()
    self.list:setAnchorBottom(true)
    self:addChild(self.list)
    y = y + 210

    -- BUTTONS
    self.btnSpawn = ISButton:new(x, y, (self.width - 30) / 2, btnH, "SPAWN SELECTED", self, self.onSpawn)
    self.btnSpawn:initialise()
    self:addChild(self.btnSpawn)

    self.btnCheck = ISButton:new(x + (self.width - 30) / 2 + 10, y, (self.width - 30) / 2, btnH, "MOD DATA DUMP", self, self.onDump)
    self.btnCheck:initialise()
    self:addChild(self.btnCheck)
    
    y = y + 35
    
    self.btnClear = ISButton:new(x, y, self.width - 20, btnH, "REMOVE ALL QUEST ITEMS (Inventory)", self, self.onClear)
    self.btnClear:initialise()
    self.btnClear.backgroundColor = {r=0.5, g=0.1, b=0.1, a=1.0}
    self:addChild(self.btnClear)

    self:populateList()
end

function DT_QuestDebugUI:populateList()
    self.list:clear()
    local items = DynamicTrading.Quests.QuestItems
    for _, item in ipairs(items) do
        self.list:addItem(item.name, item.id)
    end
end

function DT_QuestDebugUI:onDifficultyChange(control, newVal)
    -- Map slider 0.0-10.0 to 1.0-100.0 difficulty (or 0.1-100.0)
    -- newVal is 0-10 from ISVolumeControl
    local diff = newVal * 10
    if diff < 0.1 then diff = 0.1 end
    if self.valDiff then
        self.valDiff:setName(string.format("%.1f", diff))
    end
end

function DT_QuestDebugUI:onSpawn()
    local item = self.list:getItem()
    if not item or not item.item then return end
    local itemID = item.item
    
    local diff = self.sliderDiff:getVolume() * 10
    if diff < 0.1 then diff = 0.1 end
    
    local player = getSpecificPlayer(0)
    
    -- Anti-cheese check (Client-side warning)
    if player:getInventory():contains("QuestItem") then
        player:Say("I'm already carrying a quest item!")
        DynamicTrading.Log("DTCommons", "Quest", "Debug", "Anti-cheese triggered but bypassed in Debug UI")
    end
    
    DynamicTrading.Quests.RequestSpawnQuestItem(player, itemID, diff)
end

function DT_QuestDebugUI:onDump()
    local player = getSpecificPlayer(0)
    local items = player:getInventory():getItems()
    
    DynamicTrading.Log("DTCommons", "Quest", "Debug", "========================================================")
    DynamicTrading.Log("DTCommons", "Quest", "Debug", " DT QUEST DEBUG: MOD DATA DUMP")
    DynamicTrading.Log("DTCommons", "Quest", "Debug", "========================================================")
    
    local found = false
    for i=0, items:size()-1 do
        local item = items:get(i)
        local md = item:getModData()
        if md.IsQuestItem then
            DynamicTrading.Log("DTCommons", "Quest", "Debug", "Item: " .. item:getFullType())
            DynamicTrading.Log("DTCommons", "Quest", "Debug", "  - QuestID: " .. tostring(md.QuestID))
            DynamicTrading.Log("DTCommons", "Quest", "Debug", "  - Timestamp: " .. tostring(md.Timestamp))
            DynamicTrading.Log("DTCommons", "Quest", "Debug", "  - ActualWeight: " .. tostring(item:getActualWeight()))
            found = true
        end
    end
    
    if not found then DynamicTrading.Log("DTCommons", "Quest", "Debug", " No quest items found in inventory.") end
    DynamicTrading.Log("DTCommons", "Quest", "Debug", "========================================================")
end

function DT_QuestDebugUI:onClear()
    local player = getSpecificPlayer(0)
    local inv = player:getInventory()
    local items = inv:getItems()
    local toRemove = {}
    
    for i=0, items:size()-1 do
        local item = items:get(i)
        if item:getModData().IsQuestItem then
            table.insert(toRemove, item)
        end
    end
    
    for _, item in ipairs(toRemove) do
        inv:Remove(item)
    end
    
    player:Say("Removed " .. #toRemove .. " quest items.")
end

function DT_QuestDebugUI:onSideClick(x, y)
    -- Close if clicked outside (optional)
end

-- Open the UI
function DT_QuestDebugUI.OnOpen()
    if DT_QuestDebugUI.instance then
        DT_QuestDebugUI.instance:setVisible(true)
        DT_QuestDebugUI.instance:bringToTop()
        return
    end

    local ui = DT_QuestDebugUI:new(100, 100, 400, 400)
    ui:initialise()
    ui:addToUIManager()
    ui:setVisible(true)
    DT_QuestDebugUI.instance = ui
end
function DT_QuestDebugUI:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "Quest System Debug"
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.borderColor = {r=1, g=1, b=1, a=0.5}
    o:setResizable(false)
    return o
end

-- Add to Radial Menu or Context Menu
local function OnFillWorldObjectContextMenu(player, context, worldobjects, test)
    if not isDebugEnabled() then return end
    
    local option = context:addOption("[DEBUG] Dynamic Trading: Quests", nil, DT_QuestDebugUI.OnOpen)
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)

DynamicTrading.Log("DTCommons", "Init", "Quest", "Quest Debug UI Loaded")

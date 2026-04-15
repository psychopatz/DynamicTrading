-- ==============================================================================
-- DT_MerchantDebugWindow.lua
-- Merchant Debug Tool: Main UI Window
-- Debug UI for Monitoring Merchant Stock
-- ==============================================================================

require "DT/Common/UI/Debug/Merchants/StockManager/DT_MerchantDebugData"
require "DT/Common/UI/Debug/Merchants/StockManager/DT_MerchantDebugRenderers"
require "DT/Common/UI/Debug/Merchants/StockManager/DT_MerchantDebugActions"

DT_MerchantDebugWindow = ISPanel:derive("DT_MerchantDebugWindow")

function DT_MerchantDebugWindow:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_MerchantDebugWindow:createChildren()
    local x, y = 10, 10
    self.isGenerating = false
    
    -- 1. TITLE
    self.labelTitle = ISLabel:new(self.width/2, 10, 25, "MERCHANT STOCK DEBUG", 1, 1, 1, 1, UIFont.Large, true)
    self.labelTitle:initialise()
    self:addChild(self.labelTitle)

    -- 2. MERCHANT LIST (Left Side)
    local listWidth = 300
    self.listbox = ISScrollingListBox:new(10, 45, listWidth, self.height - 100)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.itemheight = 45
    self.listbox.doDrawItem = DT_MerchantDebugRenderers.drawMerchantItem
    self.listbox.onmousedown = function(target, item)
        if not DT_MerchantDebugWindow.instance then return false end
        if target and target.items then
            for i, row in ipairs(target.items) do
                if row and row.item == item then
                    target.selected = i
                    break
                end
            end
        end
        DT_MerchantDebugWindow.instance:onMerchantSelected(item)
        return true
    end
    self:addChild(self.listbox)

    -- 3. STOCK DETAIL PANEL (Right Side)
    local detailsX = 10 + listWidth + 10
    local detailsWidth = self.width - detailsX - 10
    self.details = ISScrollingListBox:new(detailsX, 45, detailsWidth, self.height - 100)
    self.details:initialise()
    self.details:instantiate()
    self.details.itemheight = 30
    self.details.doDrawItem = DT_MerchantDebugRenderers.drawStockItem
    self.details.backgroundColor = {r=0, g=0, b=0, a=0.5}
    self:addChild(self.details)

    -- 4. BUTTONS
    local btnWidth = 120
    local btnY = self.height - 40
    
    self.btnRefresh = ISButton:new(10, btnY, btnWidth, 25, "REFRESH", self, DT_MerchantDebugWindow.onRefreshClick)
    self.btnRefresh:initialise()
    self.btnRefresh.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1}
    self:addChild(self.btnRefresh)

    self.btnGenerate = ISButton:new(10 + btnWidth + 10, btnY, btnWidth, 25, "GENERATE", self, DT_MerchantDebugWindow.onGenerateClick)
    self.btnGenerate:initialise()
    self.btnGenerate.enable = false -- Only enabled when valid trader selected
    self:addChild(self.btnGenerate)

    self.btnClose = ISButton:new(self.width - btnWidth - 10, btnY, btnWidth, 25, "CLOSE", self, function(self) 
        self:setVisible(false)
        self:removeFromUIManager() 
    end)
    self.btnClose:initialise()
    self:addChild(self.btnClose)

    self:refreshList()
end

-- ==========================================================
-- DATA MANAGEMENT
-- ==========================================================
function DT_MerchantDebugWindow:refreshList()
    DT_MerchantDebugData.refreshMerchantList(function(stockData, rosterData)
        if DT_MerchantDebugWindow.instance and DT_MerchantDebugWindow.instance:getIsVisible() then
            DT_MerchantDebugWindow.instance:populateList(stockData, rosterData)
        end
    end)
end

function DT_MerchantDebugWindow:populateList(stockData, rosterData)
    local previousUUID = self.selectedTraderUUID
    self.listbox:clear()
    self.details:clear()
    self.btnGenerate.enable = false
    
    local merchants = DT_MerchantDebugData.getMerchantList(stockData, rosterData)
    for _, data in ipairs(merchants) do
        self.listbox:addItem(data.name, data)
    end

    -- Restore selection after refresh if possible.
    if previousUUID then
        for i, row in ipairs(self.listbox.items) do
            if row and row.item and row.item.uuid == previousUUID then
                self.listbox.selected = i
                self:onMerchantSelected(row.item)
                break
            end
        end
    end
end

-- ==========================================================
-- SELECTION HANDLER
-- ==========================================================
function DT_MerchantDebugWindow:onMerchantSelected(item)
    local data = item
    if not data then return end

    self.selectedTraderUUID = data.uuid
    
    self.details:clear()
    
    if data.stock and data.stock.items then
        local sortedItems = DT_MerchantDebugData.getStockItems(data.stock)
        for _, entry in ipairs(sortedItems) do
            self.details:addItem(entry.type, entry.data)
        end
    end
    
    -- Update Generate Button State
    if self.btnGenerate then
        local hasStock = data.hasStock == true
        
        -- Enable ONLY if Trading AND No Stock
        self.btnGenerate.enable = data.isTrading and not hasStock
        
        DynamicTrading.Log("DTCommons", "Debug", "UI", "Selected " .. tostring(data.name) .. " | Trading: " .. tostring(data.isTrading) .. " | HasStock: " .. tostring(hasStock))
    end
end

-- ==========================================================
-- BUTTON HANDLERS
-- ==========================================================
function DT_MerchantDebugWindow:onRefreshClick()
    self:refreshList()
end

function DT_MerchantDebugWindow:onGenerateClick()
    if self.isGenerating then return end

    local list = self.listbox
    if not list or not list.items then return end

    local item = list.selected and list.items[list.selected] or nil
    if (not item) and self.selectedTraderUUID then
        for _, row in ipairs(list.items) do
            if row and row.item and row.item.uuid == self.selectedTraderUUID then
                item = row
                break
            end
        end
    end
    if not item then return end
    
    local data = item.item 
    
    if data and data.uuid then
        local sent = DT_MerchantDebugActions.generateStock(data.uuid, data.name)
        if sent then
            -- Keep current selection and disable until fresh data arrives.
            self.selectedTraderUUID = data.uuid
            self.isGenerating = true
            self.btnGenerate.enable = false
            self:refreshList()
        end
    end
end

-- ==========================================================
-- EVENT HANDLERS
-- ==========================================================
local function onStockUpdated(traderID)
    if DT_MerchantDebugWindow.instance and DT_MerchantDebugWindow.instance:getIsVisible() then
        -- Refresh the list to show new stock
        DT_MerchantDebugWindow.instance.isGenerating = false
        DT_MerchantDebugWindow.instance:refreshList()
    end
end

Events.OnDynamicTradingStockUpdated.Add(onStockUpdated)

local function onPriceConfigUpdated()
    if DT_MerchantDebugWindow.instance and DT_MerchantDebugWindow.instance:getIsVisible() then
        DT_MerchantDebugWindow.instance:refreshList()
    end
end

Events.OnDynamicTradingPriceConfigUpdated.Add(onPriceConfigUpdated)

-- ==========================================================
-- SINGLETON ACCESS
-- ==========================================================
function DT_MerchantDebugWindow.Open()
    if DT_MerchantDebugWindow.instance then
        DT_MerchantDebugWindow.instance:setVisible(true)
        DT_MerchantDebugWindow.instance:addToUIManager()
        DT_MerchantDebugWindow.instance:refreshList()
        return
    end

    local window = DT_MerchantDebugWindow:new(150, 150, 900, 500)
    window:initialise()
    window:addToUIManager()
    DT_MerchantDebugWindow.instance = window
    window:refreshList()
end

function DT_MerchantDebugWindow:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.borderColor = {r=1, g=1, b=1, a=1}
    o.moveWithMouse = true
    return o
end

DynamicTrading.Log("DTCommons", "Debug", "UI", "Merchant Debug Window Loaded")

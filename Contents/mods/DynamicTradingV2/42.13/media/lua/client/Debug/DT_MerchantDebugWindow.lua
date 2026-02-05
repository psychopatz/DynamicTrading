-- ==============================================================================
-- media/lua/client/Debug/DT_MerchantDebugWindow.lua
-- Debug UI for Monitoring Merchant Stock
-- ==============================================================================

DT_MerchantDebugWindow = ISPanel:derive("DT_MerchantDebugWindow")

function DT_MerchantDebugWindow:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_MerchantDebugWindow:createChildren()
    local x, y = 10, 10
    
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
    self.listbox.doDrawItem = DT_MerchantDebugWindow.doDrawMerchantItem
    self.listbox.onmousedown = DT_MerchantDebugWindow.onListMouseDown
    self:addChild(self.listbox)

    -- 3. STOCK DETAIL PANEL (Right Side)
    local detailsX = 10 + listWidth + 10
    local detailsWidth = self.width - detailsX - 10
    self.details = ISScrollingListBox:new(detailsX, 45, detailsWidth, self.height - 100)
    self.details:initialise()
    self.details:instantiate()
    self.details.itemheight = 30
    self.details.doDrawItem = DT_MerchantDebugWindow.doDrawStockItem
    self.details.backgroundColor = {r=0, g=0, b=0, a=0.5}
    self:addChild(self.details)

    -- 4. BUTTONS
    local btnWidth = 120
    local btnY = self.height - 40
    
    self.btnRefresh = ISButton:new(10, btnY, btnWidth, 25, "REFRESH", self, DT_MerchantDebugWindow.refreshList)
    self.btnRefresh:initialise()
    self.btnRefresh.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1}
    self:addChild(self.btnRefresh)

    self.btnClose = ISButton:new(self.width - btnWidth - 10, btnY, btnWidth, 25, "CLOSE", self, function(self) self:setVisible(false); self:removeFromUIManager() end)
    self.btnClose:initialise()
    self:addChild(self.btnClose)

    self:refreshList()
end

function DT_MerchantDebugWindow:refreshList()
    if isClient() and not isServer() then
        sendClientCommand(getPlayer(), "DynamicTrading_V2", "RequestFactionData", {})
        return
    end
    
    local stockData = ModData.get("DynamicTrading_Stock") or {}
    local rosterData = ModData.get("DynamicTrading_Roster") or {}
    self:populateList(stockData, rosterData)
end

function DT_MerchantDebugWindow:populateList(stockData, rosterData)
    self.listbox:clear()
    
    local keys = {}
    for id in pairs(stockData) do table.insert(keys, id) end
    table.sort(keys)

    for _, uuid in ipairs(keys) do
        local stock = stockData[uuid]
        local soul = rosterData.Souls and rosterData.Souls[uuid]
        local name = soul and soul.name or "Unknown NPC"
        local faction = soul and soul.factionID or "Independent"
        
        local data = {
            uuid = uuid,
            name = name,
            faction = faction,
            archetype = soul and soul.archetypeID or "N/A",
            stock = stock
        }
        self.listbox:addItem(name, data)
    end
end

function DT_MerchantDebugWindow:doDrawMerchantItem(y, item, alt)
    local data = item.item
    if not data then return y end

    if item.selected then
        self:drawRect(0, y, self.width, self.itemheight, 0.3, 0.7, 0.7, 0.7)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 1, 1, 1)
    else
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 0, 0, 0)
    end
    
    self:drawText(data.name, 10, y + 2, 1, 1, 1, 1, UIFont.Medium)
    self:drawText("Faction: " .. data.faction .. " | " .. data.archetype, 10, y + 22, 0.7, 0.7, 0.7, 1, UIFont.Small)

    return y + self.itemheight
end

function DT_MerchantDebugWindow:onListMouseDown(item)
    local data = item
    if not DT_MerchantDebugWindow.instance or not DT_MerchantDebugWindow.instance.details then return end
    
    DT_MerchantDebugWindow.instance.details:clear()
    
    if data.stock and data.stock.items then
        local sortedItems = {}
        for k, v in pairs(data.stock.items) do
            table.insert(sortedItems, { type = k, data = v })
        end
        table.sort(sortedItems, function(a, b) return a.type < b.type end)
        
        for _, entry in ipairs(sortedItems) do
            DT_MerchantDebugWindow.instance.details:addItem(entry.type, entry.data)
        end
    end
end

function DT_MerchantDebugWindow:doDrawStockItem(y, item, alt)
    local itemType = item.text
    local stockItem = item.item

    if alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.1, 1, 1, 1)
    end

    self:drawText(itemType, 10, y + 5, 1, 1, 1, 1, UIFont.Small)
    local detailStr = string.format("Qty: %d | Pr: %d | Mod: %.1f", stockItem.qty, stockItem.basePrice or 0, stockItem.dynamicMod or 1.0)
    self:drawText(detailStr, self.width - 250, y + 5, 0.8, 1, 0.8, 1, UIFont.Small)

    return y + self.itemheight
end

-- Handle server response
local function onServerCommand(module, command, args)
    if module ~= "DynamicTrading_V2" then return end
    
    if command == "SyncFactionDebugData" then
        if DT_MerchantDebugWindow.instance and DT_MerchantDebugWindow.instance:getIsVisible() then
            local roster = args.roster or {}
            local stock = args.stock or {} -- We'll update the server to send this
            DT_MerchantDebugWindow.instance:populateList(stock, roster)
        end
    end
end

Events.OnServerCommand.Add(onServerCommand)

-- Singleton Access
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

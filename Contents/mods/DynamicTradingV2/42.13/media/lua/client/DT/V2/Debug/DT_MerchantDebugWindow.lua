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

    self.btnGenerate = ISButton:new(10 + btnWidth + 10, btnY, btnWidth, 25, "GENERATE", self, DT_MerchantDebugWindow.onGenerateClick)
    self.btnGenerate:initialise()
    self.btnGenerate.enable = false -- Only enabled when valid trader selected
    self:addChild(self.btnGenerate)

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
    -- Iterate over SOULS but FILTER for only "Trading" status
    if rosterData.Souls then
        for id, soul in pairs(rosterData.Souls) do 
            if soul.status == "Trading" then
                table.insert(keys, id) 
            end
        end
    end
    table.sort(keys)

    for _, uuid in ipairs(keys) do
        local stock = stockData[uuid]
        local soul = rosterData.Souls and rosterData.Souls[uuid]
        
        -- Fallbacks if soul data is missing but stock exists (unlikely given new logic, but safe)
        local name = soul and soul.name or ("Unknown (" .. uuid .. ")")
        local faction = soul and soul.factionID or "Independent"
        
        -- Status Checks
        local isTrading = (soul and soul.status == "Trading")
        local isCallable = (soul and soul.isCallable) or false -- Placeholder as requested
        local factionStatus = soul and soul.status or "Unknown"

        local data = {
            uuid = uuid,
            name = name,
            faction = faction,
            archetype = soul and soul.archetypeID or "N/A",
            stock = stock,
            isTrading = isTrading,
            isCallable = isCallable,
            status = factionStatus
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
    
    -- Draw Status Line
    local statusStr = "Faction: " .. data.faction .. " | " .. data.archetype
    
    -- Show Trading status (controls Generation)
    if data.isTrading then
        statusStr = statusStr .. " | [TRADING]"
    else
        statusStr = statusStr .. " | [" .. data.status .. "]"
    end
    
    -- Show Callable status (Placeholder/Future feature)
    if data.isCallable then
        statusStr = statusStr .. " | [CALLABLE]"
    end
    
    self:drawText(statusStr, 10, y + 22, 0.7, 0.7, 0.7, 1, UIFont.Small)

    return y + self.itemheight
end

function DT_MerchantDebugWindow.onListMouseDown(target, item)
    local data = item
    if not DT_MerchantDebugWindow.instance or not DT_MerchantDebugWindow.instance.details then return end
    
    -- Safety check if data is valid
    if not data then return end
    
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
    
    -- Update Generate Button State
    if DT_MerchantDebugWindow.instance.btnGenerate then
         local hasStock = false
         if data.stock and data.stock.items then
             -- Safe Empty Check
             for _,_ in pairs(data.stock.items) do 
                 hasStock = true 
                 break 
             end
         end
         
         -- Enable ONLY if Trading AND No Stock (as requested)
         DT_MerchantDebugWindow.instance.btnGenerate.enable = data.isTrading and not hasStock
         
         print("DT DEBUG: Selected " .. tostring(data.name) .. " | Trading: " .. tostring(data.isTrading) .. " | HasStock: " .. tostring(hasStock))
    end
end

function DT_MerchantDebugWindow:onGenerateClick()
    local list = self.listbox
    if not list or not list.items or not list.selected then return end
    
    local item = list.items[list.selected]
    if not item then return end
    
    local data = item.item 
    
    if data and data.uuid then
        -- We removed the client-side optimization block here because the button is now disabled if stock exists.
        -- If the user bypasses UI (e.g. Chat Menu), that optimization still exists there.
        -- Sending command to server.
        print("DT DEBUG: Requesting Stock for " .. data.uuid)
        sendClientCommand(getPlayer(), "DynamicTrading_V2", "GenerateStock", { traderID = data.uuid })
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
            local stock = args.stock or {} 
            DT_MerchantDebugWindow.instance:populateList(stock, roster)
        end
    elseif command == "TradeResult" then
        -- Show feedback for operations
        local success = args.success
        local reason = args.reason or "Unknown"
        local color = success and {r=0, g=1, b=0, a=1} or {r=1, g=0, b=0, a=1}
        
        if DT_MerchantDebugWindow.instance and DT_MerchantDebugWindow.instance:getIsVisible() then
            -- We don't have a status label, let's just use print/Halo as requested (switching to print)
            print("DT: " .. tostring(reason))
        end
    end
end

local function onStockUpdated(traderID)
    if DT_MerchantDebugWindow.instance and DT_MerchantDebugWindow.instance:getIsVisible() then
        -- Refresh the list to show new stock
        DT_MerchantDebugWindow.instance:refreshList()
    end
end

Events.OnServerCommand.Add(onServerCommand)
Events.OnDynamicTradingStockUpdated.Add(onStockUpdated)

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

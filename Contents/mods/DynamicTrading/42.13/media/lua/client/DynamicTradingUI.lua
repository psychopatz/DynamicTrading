require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISScrollingListBox"
require "DynamicTrading_Config"
require "DynamicTrading_Manager"
require "DynamicTrading_Economy"

DynamicTradingUI = ISCollapsableWindow:derive("DynamicTradingUI")
DynamicTradingUI.instance = nil

-- =================================================
-- INITIALIZATION
-- =================================================
function DynamicTradingUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(false)
    self.isBuying = true -- Toggle state
    self.selectedItem = nil -- Currently clicked row
end

function DynamicTradingUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- 1. TITLE / HEADER
    self.lblTitle = ISLabel:new(self.width / 2, 15, 20, "TRADING POST", 1, 1, 1, 1, UIFont.Medium, true)
    self.lblTitle:setAnchorTop(true)
    self.lblTitle.center = true
    self:addChild(self.lblTitle)
    
    -- 2. MODE SWITCH (BUY / SELL)
    self.btnSwitch = ISButton:new(10, 45, self.width - 20, 25, "SWITCH TO SELLING", self, self.onToggleMode)
    self.btnSwitch:initialise()
    self.btnSwitch.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
    self:addChild(self.btnSwitch)

    -- 3. ITEM LIST
    self.listbox = ISScrollingListBox:new(10, 80, self.width - 20, self.height - 120)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.NewSmall
    self.listbox.itemheight = 40 
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.listbox.doDrawItem = DynamicTradingUI.drawItem -- Custom render function
    self.listbox.onMouseDown = DynamicTradingUI.onListMouseDown
    self:addChild(self.listbox)
    
    -- 4. ACTION BUTTON
    self.btnAction = ISButton:new(self.width - 110, self.height - 35, 100, 25, "BUY", self, self.onAction)
    self.btnAction:initialise()
    self.btnAction:setAnchorTop(false)
    self.btnAction:setAnchorBottom(true)
    self.btnAction:setAnchorRight(true)
    self.btnAction:setEnable(false)
    self:addChild(self.btnAction)

    -- 5. INFO LABEL (Money/Stock)
    self.lblInfo = ISLabel:new(15, self.height - 30, 16, "Wallet: $0", 1, 1, 1, 1, UIFont.Small, true)
    self.lblInfo:setAnchorTop(false)
    self.lblInfo:setAnchorBottom(true)
    self:addChild(self.lblInfo)
end

-- =================================================
-- LOGIC: POPULATE LIST
-- =================================================
function DynamicTradingUI:populateList()
    self.listbox:clear()
    
    -- 1. Get Data
    local managerData = DynamicTrading.Manager.GetData()
    if not managerData or not self.traderID then return end
    
    local trader = DynamicTrading.Manager.GetTrader(self.traderID, self.archetype)
    if not trader then return end
    
    -- Update Title
    local archetypeName = DynamicTrading.Archetypes[trader.archetype] and DynamicTrading.Archetypes[trader.archetype].name or "Unknown"
    self.lblTitle:setName(archetypeName)
    
    -- 2. Buying Mode (Trader Stock)
    if self.isBuying then
        self.btnSwitch:setTitle("SWITCH TO SELLING")
        self.btnAction:setTitle("BUY ITEM")

        if trader.stocks then
            for key, qty in pairs(trader.stocks) do
                local itemData = DynamicTrading.Config.MasterList[key]
                if itemData then
                    -- REAL-TIME PRICE CALCULATION
                    -- We pass globalHeat to calculate inflation instantly
                    local price = DynamicTrading.Economy.GetBuyPrice(key, managerData.globalHeat)
                    
                    self.listbox:addItem(itemData.item, {
                        key = key,
                        name = itemData.item, -- Will resolve to DisplayName in drawItem
                        qty = qty,
                        price = price,
                        data = itemData,
                        isBuy = true
                    })
                end
            end
        end

    -- 3. Selling Mode (Player Inventory)
    else
        self.btnSwitch:setTitle("SWITCH TO BUYING")
        self.btnAction:setTitle("SELL ITEM")
        
        local player = getSpecificPlayer(0)
        local inv = player:getInventory()
        local items = inv:getItems()
        
        -- Map Config Items to check against Inventory
        -- (Ideally optimized, but fine for UI loop)
        for i=0, items:size()-1 do
            local invItem = items:get(i)
            local fullType = invItem:getFullType()
            
            -- Find this item in our MasterList
            local masterKey = nil
            for k, v in pairs(DynamicTrading.Config.MasterList) do
                if v.item == fullType then masterKey = k break end
            end
            
            if masterKey then
                local price = DynamicTrading.Economy.GetSellPrice(invItem, masterKey, trader.archetype)
                local itemData = DynamicTrading.Config.MasterList[masterKey]

                -- Check for "Wants" bonus (For visual flair)
                local isWanted = false
                local archData = DynamicTrading.Archetypes[trader.archetype]
                if archData and archData.wants then
                    for _, tag in ipairs(itemData.tags) do
                        if archData.wants[tag] then isWanted = true break end
                    end
                end

                self.listbox:addItem(invItem:getDisplayName(), {
                    key = masterKey,
                    invItem = invItem,
                    price = price,
                    data = itemData,
                    isWanted = isWanted,
                    isBuy = false
                })
            end
        end
    end
    
    self:updateWallet()
end

-- =================================================
-- LOGIC: ACTIONS
-- =================================================
function DynamicTradingUI:onAction()
    local item = self.listbox.items[self.listbox.selected]
    if not item then return end
    local d = item.item -- The data table we passed in populateList
    local player = getSpecificPlayer(0)

    if self.isBuying then
        -- === BUY TRANSACTION ===
        if d.qty <= 0 then return end
        
        local wealth = self:getPlayerWealth(player)
        if wealth >= d.price then
            -- 1. Payment
            self:removeMoney(player, d.price)
            
            -- 2. Give Item
            player:getInventory():AddItem(d.data.item)
            
            -- 3. Manager Update (Stock & Inflation)
            -- Note: We assume the first tag is the primary category for inflation
            local primaryCat = d.data.tags[1] or "Misc"
            DynamicTrading.Manager.OnBuyItem(self.traderID, d.key, primaryCat, 1)
            
            -- 4. Feedback
            player:playSound("Transaction") 
        else
            player:Say("Not enough cash!")
        end
        
    else
        -- === SELL TRANSACTION ===
        -- 1. Remove Item
        player:getInventory():Remove(d.invItem)
        
        -- 2. Add Money
        self:addMoney(player, d.price)
        
        -- 3. Manager Update
        local primaryCat = d.data.tags[1] or "Misc"
        DynamicTrading.Manager.OnSellItem(self.traderID, d.key, primaryCat, 1)
        
        player:playSound("Transaction")
    end

    -- REFRESH UI
    -- This recalculates prices immediately, simulating the "Slippage" / Inflation
    self:populateList()
end

-- =================================================
-- VISUALS & HELPERS
-- =================================================
function DynamicTradingUI.drawItem(listbox, y, item, alt)
    local height = listbox.itemheight
    local d = item.item
    local width = listbox:getWidth()
    
    -- Background
    if listbox.selected == item.index then
        listbox:drawRect(0, y, width, height, 0.3, 0.7, 0.35, 0.2)
    elseif alt then
        listbox:drawRect(0, y, width, height, 0.1, 0.2, 0.2, 0.2)
    end
    listbox:drawRectBorder(0, y, width, height, 0.1, 1, 1, 1)

    -- Icon
    local texName = d.data.item
    local scriptItem = getScriptManager():getItem(texName)
    if scriptItem then
        local icon = scriptItem:getIcon()
        if icon then
            local tex = getTexture("Item_" .. icon) or getTexture(icon)
            if tex then listbox:drawTextureScaled(tex, 6, y+4, 32, 32, 1, 1, 1, 1) end
        end
    end
    
    -- Name
    local name = scriptItem and scriptItem:getDisplayName() or d.key
    local textCol = {r=0.9, g=0.9, b=0.9}
    
    if d.isBuy and d.qty <= 0 then textCol = {r=0.5, g=0.5, b=0.5} name = name .. " (SOLD OUT)" end
    
    listbox:drawText(name, 45, y + 12, textCol.r, textCol.g, textCol.b, 1, listbox.font)
    
    -- Right Side Info
    if d.isBuy then
        -- Stock & Price
        listbox:drawText("Stock: " .. d.qty, width - 140, y + 12, 0.7, 0.7, 0.7, 1, listbox.font)
        listbox:drawText("$" .. d.price, width - 60, y + 12, 0.6, 1.0, 0.6, 1, listbox.font)
    else
        -- Sell Price
        if d.isWanted then
            -- Green/Gold indicator for High Demand
            listbox:drawText("HIGH DEMAND", width - 160, y + 12, 1.0, 0.8, 0.2, 1, UIFont.Small)
            listbox:drawText("$" .. d.price, width - 60, y + 12, 1.0, 0.8, 0.2, 1, listbox.font)
        else
            listbox:drawText("$" .. d.price, width - 60, y + 12, 0.6, 1.0, 0.6, 1, listbox.font)
        end
    end

    return y + height
end

function DynamicTradingUI.onListMouseDown(target, x, y)
    local row = target:rowAt(x, y)
    if row == -1 then return end
    target.selected = row
    
    local ui = DynamicTradingUI.instance
    if ui then
        ui.btnAction:setEnable(true)
    end
end

function DynamicTradingUI:onToggleMode()
    self.isBuying = not self.isBuying
    self:populateList()
end

-- =================================================
-- MONEY HANDLING (Vanilla-ish)
-- =================================================
function DynamicTradingUI:getPlayerWealth(player)
    local inv = player:getInventory()
    return inv:getItemCount("Base.Money") + (inv:getItemCount("Base.MoneyBundle") * 100)
end

function DynamicTradingUI:removeMoney(player, amount)
    local inv = player:getInventory()
    local current = self:getPlayerWealth(player)
    local remaining = current - amount
    
    -- Dirty hack: Remove all money, re-add change
    -- (Proper implementations handle bundles better, but this is safe for now)
    inv:RemoveAll("Base.Money")
    inv:RemoveAll("Base.MoneyBundle")
    
    self:addMoney(player, remaining)
end

function DynamicTradingUI:addMoney(player, amount)
    local inv = player:getInventory()
    local bundles = math.floor(amount / 100)
    local loose = amount % 100
    
    if bundles > 0 then inv:AddItems("Base.MoneyBundle", bundles) end
    if loose > 0 then inv:AddItems("Base.Money", loose) end
    
    self:updateWallet()
end

function DynamicTradingUI:updateWallet()
    local player = getSpecificPlayer(0)
    local wealth = self:getPlayerWealth(player)
    self.lblInfo:setName("Wallet: $" .. wealth)
end

-- =================================================
-- WINDOW CONTROL
-- =================================================
function DynamicTradingUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DynamicTradingUI.instance = nil
end

-- OPENING THE WINDOW
-- Call this from your WorldObject or NPC interaction code.
-- traderID: Unique String (e.g. "Muldraugh_Farmer")
-- archetype: (Optional) "Farmer", "Butcher", etc.
function DynamicTradingUI.ToggleWindow(traderID, archetype)
    if DynamicTradingUI.instance then
        DynamicTradingUI.instance:close()
        -- If opening different trader, re-open immediately
        if DynamicTradingUI.instance and DynamicTradingUI.instance.traderID ~= traderID then
             -- Logic handled below
        else
            return
        end
    end

    local ui = DynamicTradingUI:new(100, 100, 400, 500)
    ui:initialise()
    ui:addToUIManager()
    
    ui.traderID = traderID
    ui.archetype = archetype or "General"
    
    -- Pre-load the trader data to ensure it exists
    DynamicTrading.Manager.GetTrader(traderID, archetype)
    
    ui:populateList()
    DynamicTradingUI.instance = ui
end
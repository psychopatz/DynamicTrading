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
-- LIGHTWEIGHT VALIDATION (No more heavy scanning)
-- =================================================
function DynamicTradingUI:isConnectionValid()
    local player = getSpecificPlayer(0)
    local obj = self.radioObj
    
    if not obj then return false end
    
    local data = obj:getDeviceData()
    if not data or not data:getIsTurnedOn() then return false end

    -- Ham Radio Logic
    if instanceof(obj, "IsoWaveSignal") then
        local sq = obj:getSquare()
        if not sq then return false end
        -- Distance Check (Reuse same logic as parent UI)
        if IsoUtils.DistanceTo(player:getX(), player:getY(), obj:getX(), obj:getY()) > 3.0 then return false end
        
        -- Power Check
        if data:getIsBatteryPowered() then
            if data:getPower() <= 0 then return false end
        elseif not sq:haveElectricity() then
            return false
        end

    -- Walkie Talkie Logic
    else
        if obj:getContainer() ~= player:getInventory() then return false end
        if data:getPower() <= 0.001 then return false end
    end

    return true
end

-- =================================================
-- INITIALIZATION
-- =================================================
function DynamicTradingUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(false)
    self.isBuying = true 
    self.selectedItem = nil 
    self.radioObj = nil -- Stores the active radio
end

function DynamicTradingUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    self.lblTitle = ISLabel:new(self.width / 2, 15, 20, "TRADING POST", 1, 1, 1, 1, UIFont.Medium, true)
    self.lblTitle:setAnchorTop(true)
    self.lblTitle.center = true
    self:addChild(self.lblTitle)
    
    self.lblSignal = ISLabel:new(self.width / 2, 35, 16, "Signal: Stable", 0.2, 1.0, 0.2, 1, UIFont.Small, true)
    self.lblSignal.center = true
    self:addChild(self.lblSignal)
    
    self.btnSwitch = ISButton:new(10, 55, self.width - 20, 25, "SWITCH TO SELLING", self, self.onToggleMode)
    self.btnSwitch:initialise()
    self.btnSwitch.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
    self:addChild(self.btnSwitch)

    self.listbox = ISScrollingListBox:new(10, 90, self.width - 20, self.height - 130)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.NewSmall
    self.listbox.itemheight = 40 
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.listbox.doDrawItem = DynamicTradingUI.drawItem 
    self.listbox.onMouseDown = DynamicTradingUI.onListMouseDown
    self:addChild(self.listbox)
    
    self.btnAction = ISButton:new(self.width - 110, self.height - 35, 100, 25, "BUY", self, self.onAction)
    self.btnAction:initialise()
    self.btnAction:setAnchorTop(false)
    self.btnAction:setAnchorBottom(true)
    self.btnAction:setAnchorRight(true)
    self.btnAction:setEnable(false)
    self:addChild(self.btnAction)

    self.lblInfo = ISLabel:new(15, self.height - 30, 16, "Wallet: $0", 1, 1, 1, 1, UIFont.Small, true)
    self.lblInfo:setAnchorTop(false)
    self.lblInfo:setAnchorBottom(true)
    self:addChild(self.lblInfo)
end

function DynamicTradingUI:populateList()
    self.listbox:clear()
    
    local managerData = DynamicTrading.Manager.GetData()
    if not managerData or not self.traderID then return end
    
    local trader = DynamicTrading.Manager.GetTrader(self.traderID, self.archetype)
    if not trader then return end
    
    local archetypeName = DynamicTrading.Archetypes[trader.archetype] and DynamicTrading.Archetypes[trader.archetype].name or "Unknown"
    self.lblTitle:setName((trader.name or "Unknown") .. " - " .. archetypeName)
    
    if trader.expirationDay then
        local gt = GameTime:getInstance()
        local daysLeft = trader.expirationDay - math.floor(gt:getDaysSurvived())
        if daysLeft <= 1 then
            self.lblSignal:setName("Signal: Fading (< 24h)")
            self.lblSignal:setColor(1.0, 0.2, 0.2, 1)
        else
            self.lblSignal:setName("Signal: Stable (" .. daysLeft .. " Days)")
            self.lblSignal:setColor(0.2, 1.0, 0.2, 1)
        end
    else
        self.lblSignal:setName("Signal: Permanent Connection")
        self.lblSignal:setColor(0.5, 0.8, 1.0, 1)
    end

    if self.isBuying then
        self.btnSwitch:setTitle("SWITCH TO SELLING")
        self.btnAction:setTitle("BUY ITEM")

        if trader.stocks then
            local sortedStock = {}
            for key, qty in pairs(trader.stocks) do
                local itemData = DynamicTrading.Config.MasterList[key]
                if itemData then
                    local scriptItem = getScriptManager():getItem(itemData.item)
                    local sortName = scriptItem and scriptItem:getDisplayName() or key
                    table.insert(sortedStock, {key=key, qty=qty, data=itemData, name=sortName})
                end
            end
            table.sort(sortedStock, function(a,b) return a.name < b.name end)

            for _, stock in ipairs(sortedStock) do
                local price = DynamicTrading.Economy.GetBuyPrice(stock.key, managerData.globalHeat)
                self.listbox:addItem(stock.name, {
                    key = stock.key, name = stock.name, qty = stock.qty,
                    price = price, data = stock.data, isBuy = true
                })
            end
        end
    else
        self.btnSwitch:setTitle("SWITCH TO BUYING")
        self.btnAction:setTitle("SELL ITEM")
        
        local player = getSpecificPlayer(0)
        local inv = player:getInventory()
        local items = inv:getItems()
        local sellList = {}

        for i=0, items:size()-1 do
            local invItem = items:get(i)
            local fullType = invItem:getFullType()
            
            local masterKey = nil
            for k, v in pairs(DynamicTrading.Config.MasterList) do
                if v.item == fullType then masterKey = k break end
            end
            
            if masterKey then table.insert(sellList, {item=invItem, key=masterKey}) end
        end

        table.sort(sellList, function(a,b) return a.item:getDisplayName() < b.item:getDisplayName() end)

        for _, entry in ipairs(sellList) do
            local invItem = entry.item
            local masterKey = entry.key
            
            local price = DynamicTrading.Economy.GetSellPrice(invItem, masterKey, trader.archetype)
            local itemData = DynamicTrading.Config.MasterList[masterKey]

            local isWanted = false
            local archData = DynamicTrading.Archetypes[trader.archetype]
            if archData and archData.wants then
                for _, tag in ipairs(itemData.tags) do
                    if archData.wants[tag] then isWanted = true break end
                end
            end

            self.listbox:addItem(invItem:getDisplayName(), {
                key = masterKey, invItem = invItem, price = price,
                data = itemData, isWanted = isWanted, isBuy = false
            })
        end
    end
    self:updateWallet()
end

function DynamicTradingUI:onAction()
    local selItem = self.listbox.items[self.listbox.selected]
    if not selItem then return end
    
    local d = selItem.item
    local player = getSpecificPlayer(0)

    -- [OPTIMIZED] Check the stored radio object directly
    if not self:isConnectionValid() then
        self:close()
        player:Say("Signal lost!")
        player:playSound("RadioStatic")
        HaloTextHelper.addTextWithArrow(player, "Connection Lost", false, HaloTextHelper.getColorRed())
        return
    end

    local lastKey = d.key
    local wasBuying = self.isBuying
    local transactionSuccess = false

    if self.isBuying then
        if d.qty <= 0 then return end
        local wealth = self:getPlayerWealth(player)
        if wealth >= d.price then
            self:removeMoney(player, d.price)
            player:getInventory():AddItem(d.data.item)
            local primaryCat = d.data.tags[1] or "Misc"
            DynamicTrading.Manager.OnBuyItem(self.traderID, d.key, primaryCat, 1)
            player:playSound("Transaction") 
            transactionSuccess = true
        else
            player:Say("Not enough cash!")
        end
    else
        player:getInventory():Remove(d.invItem)
        self:addMoney(player, d.price)
        local primaryCat = d.data.tags[1] or "Misc"
        DynamicTrading.Manager.OnSellItem(self.traderID, d.key, primaryCat, 1)
        player:playSound("Transaction")
        transactionSuccess = true
    end

    self:populateList()

    if transactionSuccess and wasBuying then
        for i, item in ipairs(self.listbox.items) do
            if item.item.key == lastKey then
                self.listbox.selected = i
                break
            end
        end
    elseif transactionSuccess and not wasBuying then
        if self.listbox.selected > #self.listbox.items then
            self.listbox.selected = #self.listbox.items
        end
    end
    
    if self.listbox.items[self.listbox.selected] then
        self.btnAction:setEnable(true)
    else
        self.btnAction:setEnable(false)
    end
end

function DynamicTradingUI.drawItem(listbox, y, item, alt)
    local height = listbox.itemheight
    local d = item.item
    local width = listbox:getWidth()
    
    if listbox.selected == item.index then
        listbox:drawRect(0, y, width, height, 0.3, 0.7, 0.35, 0.2)
    elseif alt then
        listbox:drawRect(0, y, width, height, 0.1, 0.2, 0.2, 0.2)
    end
    listbox:drawRectBorder(0, y, width, height, 0.1, 1, 1, 1)

    local texName = d.data.item
    local scriptItem = getScriptManager():getItem(texName)
    local name = d.key
    if scriptItem then
        local icon = scriptItem:getIcon()
        if icon then
            local tex = getTexture("Item_" .. icon) or getTexture(icon)
            if tex then listbox:drawTextureScaled(tex, 6, y+4, 32, 32, 1, 1, 1, 1) end
        end
        name = scriptItem:getDisplayName()
    end
    
    local textCol = {r=0.9, g=0.9, b=0.9}
    if d.isBuy and d.qty <= 0 then textCol = {r=0.5, g=0.5, b=0.5} name = name .. " (SOLD OUT)" end
    listbox:drawText(name, 45, y + 12, textCol.r, textCol.g, textCol.b, 1, listbox.font)
    
    if d.isBuy then
        listbox:drawText("Stock: " .. d.qty, width - 140, y + 12, 0.7, 0.7, 0.7, 1, listbox.font)
        listbox:drawText("$" .. d.price, width - 60, y + 12, 0.6, 1.0, 0.6, 1, listbox.font)
    else
        if d.isWanted then
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
    if DynamicTradingUI.instance then DynamicTradingUI.instance.btnAction:setEnable(true) end
end

function DynamicTradingUI:onToggleMode()
    self.isBuying = not self.isBuying
    self:populateList()
    self.selectedItem = nil
    self.btnAction:setEnable(false)
end

function DynamicTradingUI:getPlayerWealth(player)
    local inv = player:getInventory()
    return inv:getItemCount("Base.Money") + (inv:getItemCount("Base.MoneyBundle") * 100)
end

function DynamicTradingUI:removeMoney(player, amount)
    local inv = player:getInventory()
    local current = self:getPlayerWealth(player)
    local remaining = current - amount
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

function DynamicTradingUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DynamicTradingUI.instance = nil
end

-- =================================================
-- TOGGLE WINDOW (Accepts Radio Object)
-- =================================================
function DynamicTradingUI.ToggleWindow(traderID, archetype, radioObj)
    if DynamicTradingUI.instance then
        DynamicTradingUI.instance:close()
        -- If reopening, we close first to reset state, then return. 
        -- If user clicked different trader, they can click again.
        return
    end

    local ui = DynamicTradingUI:new(100, 100, 420, 520)
    ui:initialise()
    ui:addToUIManager()
    ui.traderID = traderID
    ui.archetype = archetype or "General"
    ui.radioObj = radioObj -- [STORE RADIO]
    
    DynamicTrading.Manager.GetTrader(traderID, archetype)
    
    ui:populateList()
    DynamicTradingUI.instance = ui
end
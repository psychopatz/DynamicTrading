require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISScrollingListBox"
require "DynamicTrading_Config"
require "DynamicTrading_Manager"
require "DynamicTrading_Economy"
require "DynamicTrading_Events" 

DynamicTradingUI = ISCollapsableWindow:derive("DynamicTradingUI")
DynamicTradingUI.instance = nil

-- =================================================
-- INITIALIZATION
-- =================================================
function DynamicTradingUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(false)
    self.isBuying = true 
    self.selectedKey = nil 
    self.radioObj = nil
    self.collapsed = {} 
end

-- =================================================
-- LIVE STATE CHECK (MOVED TO UPDATE)
-- =================================================
function DynamicTradingUI:update()
    ISCollapsableWindow.update(self)

    -- Safety: If no ID is set, we shouldn't be open
    if not self.traderID then 
        self:close() 
        return 
    end

    -- 1. Fetch Latest Data
    local data = DynamicTrading.Manager.GetData()

    -- 2. "DEATH CHECK": Does the trader still exist in ModData?
    local traderExists = false
    if data.Traders and data.Traders[self.traderID] then
        traderExists = true
    end

    if not traderExists then
        print("[DynamicTrading] Client UI: Trader " .. tostring(self.traderID) .. " no longer exists. Closing.")
        
        local player = getSpecificPlayer(0)
        if player then
            player:playSound("RadioStatic")
            player:Say("Signal Lost: The trader signed off.")
        end
        
        self:close()
        return
    end

    -- 3. Check Physical Connection (Distance/Power)
    if not self:isConnectionValid() then
        local player = getSpecificPlayer(0)
        if player then player:Say("Connection lost (Check Power/Distance)") end
        self:close()
        return
    end
end

-- =================================================
-- LIGHTWEIGHT VALIDATION
-- =================================================
function DynamicTradingUI:isConnectionValid()
    local player = getSpecificPlayer(0)
    local obj = self.radioObj
    if not obj then return false end
    
    local data = obj:getDeviceData()
    if not data or not data:getIsTurnedOn() then return false end

    -- Distance/Power Check
    if instanceof(obj, "IsoWaveSignal") then
        local sq = obj:getSquare()
        if not sq then return false end
        -- Relaxed distance to 5.0 to prevent accidental closes
        if IsoUtils.DistanceTo(player:getX(), player:getY(), obj:getX(), obj:getY()) > 5.0 then return false end
        if data:getIsBatteryPowered() then
            if data:getPower() <= 0 then return false end
        elseif not sq:haveElectricity() then return false end
    else
        -- Handheld Check
        if obj:getContainer() ~= player:getInventory() then return false end
        if data:getPower() <= 0.001 then return false end
    end
    return true
end

-- =================================================
-- UI CREATION
-- =================================================
function DynamicTradingUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    -- HEADER
    self.lblTitle = ISLabel:new(self.width / 2, 15, 20, "TRADING POST", 1, 1, 1, 1, UIFont.Medium, true)
    self.lblTitle:setAnchorTop(true)
    self.lblTitle.center = true
    self:addChild(self.lblTitle)
    
    -- SIGNAL INDICATOR (Timer)
    self.lblSignal = ISLabel:new(self.width / 2, 35, 16, "Signal: Stable", 0.2, 1.0, 0.2, 1, UIFont.Small, true)
    self.lblSignal.center = true
    self:addChild(self.lblSignal)
    
    -- SWITCH BUTTON
    self.btnSwitch = ISButton:new(10, 55, self.width - 20, 25, "SWITCH TO SELLING", self, self.onToggleMode)
    self.btnSwitch:initialise()
    self.btnSwitch.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
    self:addChild(self.btnSwitch)

    -- LISTBOX
    self.listbox = ISScrollingListBox:new(10, 90, self.width - 20, self.height - 130)
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.NewSmall
    self.listbox.itemheight = 40 
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    
    self.listbox.doDrawItem = DynamicTradingUI.drawItem 
    
    -- Custom Mouse interaction for Categories
    self.listbox.onMouseDown = function(target, x, y)
        local row = target:rowAt(x, y)
        if row == -1 then return end
        
        local item = target.items[row]
        if not item then return end
        
        -- 1. Handle Category Click
        if item.item.isCategory then
            local catName = item.item.categoryName
            local ui = DynamicTradingUI.instance
            ui.collapsed[catName] = not ui.collapsed[catName]
            ui:populateList()
            return
        end
        
        -- 2. Handle Item Selection
        target.selected = row
        local ui = DynamicTradingUI.instance
        if ui then 
            ui.selectedKey = item.item.key 
            ui.btnAction:setEnable(true) 
        end
    end
    
    self:addChild(self.listbox)
    
    -- ACTION BUTTON
    self.btnAction = ISButton:new(self.width - 110, self.height - 35, 100, 25, "BUY", self, self.onAction)
    self.btnAction:initialise()
    self.btnAction:setAnchorTop(false)
    self.btnAction:setAnchorBottom(true)
    self.btnAction:setAnchorRight(true)
    self.btnAction:setEnable(false)
    self:addChild(self.btnAction)

    -- WALLET
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
    self.listbox.selected = -1 
    
    local managerData = DynamicTrading.Manager.GetData()
    if not managerData or not self.traderID then return end
    
    local trader = DynamicTrading.Manager.GetTrader(self.traderID, self.archetype)
    if not trader then return end
    
    local archetypeName = DynamicTrading.Archetypes[trader.archetype] and DynamicTrading.Archetypes[trader.archetype].name or "Unknown"
    self.lblTitle:setName((trader.name or "Unknown") .. " - " .. archetypeName)
    
    self:updateSignalDisplay(trader)
    self:updateWallet()

    local categorized = {} 
    local categories = {}  

    -- Get Global Stock Modifier
    local globalStockMult = 1.0
    if DynamicTrading.Events and DynamicTrading.Events.GetSystemModifier then
        globalStockMult = DynamicTrading.Events.GetSystemModifier("globalStock")
    end

    if self.isBuying then
        self.btnSwitch:setTitle("SWITCH TO SELLING")
        self.btnAction:setTitle("BUY ITEM")

        if trader.stocks then
            for key, qty in pairs(trader.stocks) do
                local itemData = DynamicTrading.Config.MasterList[key]
                if itemData then
                    local scriptItem = getScriptManager():getItem(itemData.item)
                    local sortName = scriptItem and scriptItem:getDisplayName() or key
                    
                    -- Calculate prices first
                    local price = DynamicTrading.Economy.GetBuyPrice(key, managerData.globalHeat)
                    
                    local cat = "Misc"
                    if itemData.tags and #itemData.tags > 0 then cat = itemData.tags[1] end

                    -- [FIX] Ensure Category creation happens HERE
                    if not categorized[cat] then 
                        categorized[cat] = {}
                        table.insert(categories, cat)
                    end

                    local priceMod = 1.0
                    local stockMod = globalStockMult
                    
                    if DynamicTrading.Events then
                        if DynamicTrading.Events.GetPriceModifier then
                            priceMod = DynamicTrading.Events.GetPriceModifier(itemData.tags)
                        end
                        if DynamicTrading.Events.GetVolumeModifier then
                            stockMod = stockMod * DynamicTrading.Events.GetVolumeModifier(itemData.tags)
                        end
                    end

                    table.insert(categorized[cat], {
                        key = key,
                        name = sortName,
                        qty = qty,
                        price = price,
                        data = itemData,
                        isBuy = true,
                        isCategory = false,
                        priceMod = priceMod, 
                        stockMod = stockMod
                    })
                end
            end
        end
    else
        self.btnSwitch:setTitle("SWITCH TO BUYING")
        self.btnAction:setTitle("SELL ITEM")

        local player = getSpecificPlayer(0)
        local items = player:getInventory():getItems()
        
        for i=0, items:size()-1 do
            local invItem = items:get(i)
            local fullType = invItem:getFullType()
            
            -- 1. Filter out actual Currency items
            if fullType ~= "Base.Money" and fullType ~= "Base.MoneyBundle" then

                local masterKey = nil
                for k, v in pairs(DynamicTrading.Config.MasterList) do
                    if v.item == fullType then masterKey = k break end
                end
                
                if masterKey then
                    local itemData = DynamicTrading.Config.MasterList[masterKey]
                    local price = DynamicTrading.Economy.GetSellPrice(invItem, masterKey, trader.archetype)

                    -- [FIX] 2. Filter out items worth $0 AND initialize Category inside check
                    if price > 0 then
                        local cat = "Misc"
                        if itemData.tags and #itemData.tags > 0 then cat = itemData.tags[1] end

                        -- [FIX] Create Category only if item is valid
                        if not categorized[cat] then 
                            categorized[cat] = {}
                            table.insert(categories, cat)
                        end

                        local priceMod = 1.0
                        if DynamicTrading.Events and DynamicTrading.Events.GetPriceModifier then
                            priceMod = DynamicTrading.Events.GetPriceModifier(itemData.tags)
                        end

                        table.insert(categorized[cat], {
                            key = masterKey,
                            invItem = invItem,
                            name = invItem:getDisplayName(),
                            price = price,
                            data = itemData,
                            isBuy = false,
                            isCategory = false,
                            priceMod = priceMod,
                            stockMod = 1.0 
                        })
                    end
                end
            end
        end
    end

    table.sort(categories) 

    for _, catName in ipairs(categories) do
        -- [FIX] Double Check: Only add header if category actually has items
        if categorized[catName] and #categorized[catName] > 0 then
            
            local hItem = self.listbox:addItem(string.upper(catName), nil)
            hItem.item = { isCategory = true, categoryName = catName, text = string.upper(catName) }
            hItem.height = 32
            
            if not self.collapsed[catName] then
                local itemsInCat = categorized[catName]
                table.sort(itemsInCat, function(a,b) return a.name < b.name end)
                
                for _, prod in ipairs(itemsInCat) do
                    self.listbox:addItem(prod.name, prod)
                    
                    if self.isBuying and self.selectedKey and prod.key == self.selectedKey then
                        self.listbox.selected = #self.listbox.items
                    end
                end
            end
        end
    end
end

-- =================================================
-- DRAWING
-- =================================================
function DynamicTradingUI.drawItem(listbox, y, item, alt)
    local height = listbox.itemheight
    local d = item.item
    local width = listbox:getWidth()
    
    if d.isCategory then
        listbox:drawRect(0, y, width, height, 0.9, 0.1, 0.1, 0.1)
        listbox:drawRectBorder(0, y, width, height, 0.3, 0.5, 0.5, 0.5)
        
        local ui = DynamicTradingUI.instance
        local isCol = ui and ui.collapsed[d.categoryName]
        local prefix = isCol and "[+] " or "[-] "
        
        listbox:drawText(prefix .. d.text, 10, y + (height/2) - 7, 1, 0.8, 0.3, 1, UIFont.Medium)
        return y + height
    end

    if listbox.selected == item.index then
        listbox:drawRect(0, y, width, height, 0.3, 0.7, 0.35, 0.2)
    elseif alt then
        listbox:drawRect(0, y, width, height, 0.1, 0.2, 0.2, 0.2)
    end
    listbox:drawRectBorder(0, y, width, height, 0.1, 1, 1, 1)

    local texName = d.data.item
    local scriptItem = getScriptManager():getItem(texName)
    if scriptItem then
        local icon = scriptItem:getIcon()
        if icon then
            local tex = getTexture("Item_" .. icon) or getTexture(icon)
            if tex then listbox:drawTextureScaled(tex, 6, y+4, 32, 32, 1, 1, 1, 1) end
        end
    end
    
    local nameColor = {r=0.9, g=0.9, b=0.9}
    if d.isBuy and d.qty <= 0 then nameColor = {r=0.5, g=0.5, b=0.5} end
    
    listbox:drawText(d.name, 45, y + 12, nameColor.r, nameColor.g, nameColor.b, 1, listbox.font)
    
    -- DYNAMIC COLORING LOGIC
    local priceR, priceG, priceB = 0.6, 1.0, 0.6 -- Default Light Green
    local stockR, stockG, stockB = 0.7, 0.7, 0.7 -- Default Grey

    if d.isBuy then
        -- BUY MODE
        -- Price: Cyan = Cheap, Red = Expensive
        if d.priceMod < 0.99 then priceR, priceG, priceB = 0.2, 1.0, 1.0 
        elseif d.priceMod > 1.01 then priceR, priceG, priceB = 1.0, 0.4, 0.4 
        end
        
        -- Stock: Green = High, Red = Low
        if d.stockMod > 1.01 then stockR, stockG, stockB = 0.4, 1.0, 0.4
        elseif d.stockMod < 0.99 then stockR, stockG, stockB = 1.0, 0.4, 0.4
        end
    else
        -- SELL MODE
        -- Price: Cyan = High Payout, Red = Low Payout
        if d.priceMod > 1.01 then priceR, priceG, priceB = 0.2, 1.0, 1.0
        elseif d.priceMod < 0.99 then priceR, priceG, priceB = 1.0, 0.4, 0.4
        end
    end

    if d.isBuy then
        if d.qty <= 0 then
            listbox:drawText("(SOLD OUT)", width - 140, y + 12, 1.0, 0.2, 0.2, 1, UIFont.Small)
        else
            listbox:drawText("Stock: " .. d.qty, width - 140, y + 12, stockR, stockG, stockB, 1, listbox.font)
        end
        listbox:drawText("$" .. d.price, width - 60, y + 12, priceR, priceG, priceB, 1, listbox.font)
    else
        listbox:drawText("$" .. d.price, width - 60, y + 12, priceR, priceG, priceB, 1, listbox.font)
    end
    
    return y + height
end

-- =================================================
-- ACTION LOGIC
-- =================================================
function DynamicTradingUI:onAction()
    -- 1. CAPTURE CURRENT ROW INDEX BEFORE REFRESH
    local savedSelectionIndex = self.listbox.selected
    
    local selItem = self.listbox.items[self.listbox.selected]
    if not selItem or not selItem.item or selItem.item.isCategory then return end
    
    local d = selItem.item
    local player = getSpecificPlayer(0)

    if not self:isConnectionValid() then
        self:close()
        player:Say("Signal lost!")
        return
    end

    local transactionSuccess = false

    if self.isBuying then
        if d.qty <= 0 then 
            player:Say("It's sold out.")
            return 
        end
        
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

    if transactionSuccess then
        -- Refresh the list
        self:populateList()

        -- SELL MODE: AUTO-SELECT NEXT ITEM
        if not self.isBuying then
            local newCount = #self.listbox.items
            
            if newCount > 0 then
                if savedSelectionIndex > newCount then 
                    savedSelectionIndex = newCount 
                end
                
                self.listbox.selected = savedSelectionIndex
                
                local nextItem = self.listbox.items[savedSelectionIndex]
                if nextItem and nextItem.item and not nextItem.item.isCategory then
                     self.selectedKey = nextItem.item.key
                     self.btnAction:setEnable(true)
                else
                     self.btnAction:setEnable(false)
                     self.selectedKey = nil
                end
            else
                self.btnAction:setEnable(false)
            end
        end
    end
end

-- =================================================
-- HELPERS
-- =================================================
function DynamicTradingUI:updateSignalDisplay(trader)
    local gt = GameTime:getInstance()
    local text = "Signal: Permanent Connection"
    local r, g, b = 0.5, 0.8, 1.0 

    if trader.expirationTime then
        local currentHours = gt:getWorldAgeHours()
        local diff = trader.expirationTime - currentHours

        if diff <= 0 then
            text = "Signal: Lost"
            r, g, b = 1.0, 0.0, 0.0 
        elseif diff > 24 then
            local days = math.floor(diff / 24)
            local hours = math.floor(diff % 24)
            text = string.format("Signal: Stable (%dd %dh)", days, hours)
            r, g, b = 0.2, 1.0, 0.2 
        elseif diff > 1 then
            text = string.format("Signal: Fading (%dh)", math.floor(diff))
            r, g, b = 1.0, 0.8, 0.2 
        else
            text = "Signal: Critical (< 1h)"
            r, g, b = 1.0, 0.2, 0.2 
        end
    elseif trader.expirationDay then
        local days = trader.expirationDay - math.floor(gt:getDaysSurvived())
        text = string.format("Signal: Stable (%d Days)", days)
        if days <= 1 then r,g,b = 1.0, 0.2, 0.2 else r,g,b = 0.2, 1.0, 0.2 end
    end

    self.lblSignal:setName(text)
    self.lblSignal:setColor(r, g, b, 1)
end

function DynamicTradingUI:onToggleMode()
    self.isBuying = not self.isBuying
    self.selectedKey = nil
    self:populateList()
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

function DynamicTradingUI.ToggleWindow(traderID, archetype, radioObj)
    if DynamicTradingUI.instance then
        DynamicTradingUI.instance:close()
        return
    end

    local ui = DynamicTradingUI:new(100, 100, 420, 520)
    ui:initialise()
    ui:addToUIManager()
    ui.traderID = traderID
    ui.archetype = archetype or "General"
    ui.radioObj = radioObj
    
    DynamicTrading.Manager.GetTrader(traderID, archetype)
    
    ui:populateList()
    DynamicTradingUI.instance = ui
end
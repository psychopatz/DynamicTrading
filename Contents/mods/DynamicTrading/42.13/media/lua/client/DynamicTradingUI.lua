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
-- LIVE STATE CHECK & CRASH PREVENTION
-- =================================================
function DynamicTradingUI:update()
    ISCollapsableWindow.update(self)

    -- [CRASH FIX] EMERGENCY SANITY CHECK
    if self.listbox and type(self.listbox.selected) ~= "number" then
        self.listbox.selected = -1
    end

    if not self.traderID then self:close() return end

    local data = DynamicTrading.Manager.GetData()
    if not data.Traders or not data.Traders[self.traderID] then
        print("[DynamicTrading] Trader lost signal.")
        self:close()
        return
    end

    if not self:isConnectionValid() then self:close() return end
end

function DynamicTradingUI:isConnectionValid()
    local player = getSpecificPlayer(0)
    local obj = self.radioObj
    if not obj then return false end
    
    local data = obj:getDeviceData()
    if not data or not data:getIsTurnedOn() then return false end

    if instanceof(obj, "IsoWaveSignal") then
        local sq = obj:getSquare()
        if not sq then return false end
        if IsoUtils.DistanceTo(player:getX(), player:getY(), obj:getX(), obj:getY()) > 5.0 then return false end
        if data:getIsBatteryPowered() and data:getPower() <= 0 then return false end
        if not data:getIsBatteryPowered() and not sq:haveElectricity() then return false end
    else
        if obj:getContainer() ~= player:getInventory() then return false end
        if data:getPower() <= 0.001 then return false end
    end
    return true
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
    
    self.listbox.onMouseDown = function(target, x, y)
        local row = target:rowAt(x, y)
        if type(row) ~= "number" or row == -1 then return end
        
        local item = target.items[row]
        if not item then return end
        
        if item.item.isCategory then
            local catName = item.item.categoryName
            local ui = DynamicTradingUI.instance
            ui.collapsed[catName] = not ui.collapsed[catName]
            ui:populateList()
            return
        end
        
        target.selected = row
        local ui = DynamicTradingUI.instance
        if ui then 
            ui.selectedKey = item.item.key 
            ui.btnAction:setEnable(true) 
        end
    end
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

    if self.lblSignal then
        self.lblSignal:setName(text)
        self.lblSignal:setColor(r, g, b, 1)
    end
end

function DynamicTradingUI:getPlayerWealth(player)
    local inv = player:getInventory()
    return inv:getItemCount("Base.Money") + (inv:getItemCount("Base.MoneyBundle") * 100)
end

function DynamicTradingUI:updateWallet()
    local player = getSpecificPlayer(0)
    local wealth = self:getPlayerWealth(player)
    if self.lblInfo then
        self.lblInfo:setName("Wallet: $" .. wealth)
    end
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
    local qty = tonumber(d.qty) or 0
    if d.isBuy and qty <= 0 then nameColor = {r=0.5, g=0.5, b=0.5} end
    
    listbox:drawText(d.name, 45, y + 12, nameColor.r, nameColor.g, nameColor.b, 1, listbox.font)
    
    local priceR, priceG, priceB = 0.6, 1.0, 0.6 
    local stockR, stockG, stockB = 0.7, 0.7, 0.7 

    local pMod = tonumber(d.priceMod) or 1.0
    local sMod = tonumber(d.stockMod) or 1.0

    if d.isBuy then
        if pMod < 0.99 then priceR, priceG, priceB = 0.2, 1.0, 1.0 
        elseif pMod > 1.01 then priceR, priceG, priceB = 1.0, 0.4, 0.4 
        end
        if sMod > 1.01 then stockR, stockG, stockB = 0.4, 1.0, 0.4
        elseif sMod < 0.99 then stockR, stockG, stockB = 1.0, 0.4, 0.4
        end
    else
        if pMod > 1.01 then priceR, priceG, priceB = 0.2, 1.0, 1.0
        elseif pMod < 0.99 then priceR, priceG, priceB = 1.0, 0.4, 0.4
        end
    end

    if d.isBuy then
        if qty <= 0 then
            listbox:drawText("(SOLD OUT)", width - 140, y + 12, 1.0, 0.2, 0.2, 1, UIFont.Small)
        else
            listbox:drawText("Stock: " .. qty, width - 140, y + 12, stockR, stockG, stockB, 1, listbox.font)
        end
        listbox:drawText("$" .. d.price, width - 60, y + 12, priceR, priceG, priceB, 1, listbox.font)
    else
        listbox:drawText("$" .. d.price, width - 60, y + 12, priceR, priceG, priceB, 1, listbox.font)
    end
    
    return y + height
end

-- =================================================
-- LOGIC: POPULATE LIST
-- =================================================
function DynamicTradingUI:populateList()
    local oldScroll = self.listbox:getYScroll()
    
    self.listbox:clear()
    self.listbox.selected = -1 
    
    local managerData = DynamicTrading.Manager.GetData()
    if not managerData or not self.traderID then return end
    
    local trader = DynamicTrading.Manager.GetTrader(self.traderID, self.archetype)
    if not trader then return end
    
    local archetypeName = DynamicTrading.Archetypes[trader.archetype] and DynamicTrading.Archetypes[trader.archetype].name or "Unknown"
    if self.lblTitle then
        self.lblTitle:setName((trader.name or "Unknown") .. " - " .. archetypeName)
    end
    
    self:updateSignalDisplay(trader)
    self:updateWallet()

    local categorized = {} 
    local categories = {}  

    local globalStockMult = 1.0
    if DynamicTrading.Events and type(DynamicTrading.Events.GetSystemModifier) == "function" then
        local val = DynamicTrading.Events.GetSystemModifier("globalStock")
        if type(val) == "number" then globalStockMult = val end
    end

    if self.isBuying then
        self.btnSwitch:setTitle("SWITCH TO SELLING")
        self.btnAction:setTitle("BUY ITEM")

        if trader.stocks then
            for key, qty in pairs(trader.stocks) do
                local itemData = DynamicTrading.Config.MasterList[key]
                if itemData then
                    local scriptItem = getScriptManager():getItem(itemData.item)
                    local sortName = tostring(scriptItem and scriptItem:getDisplayName() or key)
                    
                    local price = DynamicTrading.Economy.GetBuyPrice(key, managerData.globalHeat)
                    
                    local cat = "Misc"
                    if itemData.tags and #itemData.tags > 0 then cat = itemData.tags[1] end
                    cat = tostring(cat)

                    if not categorized[cat] then 
                        categorized[cat] = {}
                        table.insert(categories, cat)
                    end

                    local priceMod = 1.0
                    local stockMod = globalStockMult
                    
                    if DynamicTrading.Events then
                        if type(DynamicTrading.Events.GetPriceModifier) == "function" then
                            local val = DynamicTrading.Events.GetPriceModifier(itemData.tags)
                            if type(val) == "number" then priceMod = val end
                        end
                        if type(DynamicTrading.Events.GetVolumeModifier) == "function" then
                            local val = DynamicTrading.Events.GetVolumeModifier(itemData.tags)
                            if type(val) == "number" then stockMod = stockMod * val end
                        end
                    end

                    table.insert(categorized[cat], {
                        key = key,
                        name = sortName,
                        qty = tonumber(qty) or 0,
                        price = tonumber(price) or 0,
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
            
            if fullType ~= "Base.Money" and fullType ~= "Base.MoneyBundle" then
                local masterKey = nil
                for k, v in pairs(DynamicTrading.Config.MasterList) do
                    if v.item == fullType then masterKey = k break end
                end
                
                if masterKey then
                    local itemData = DynamicTrading.Config.MasterList[masterKey]
                    if itemData then
                        local price = DynamicTrading.Economy.GetSellPrice(invItem, masterKey, trader.archetype)

                        if price > 0 then
                            local cat = "Misc"
                            if itemData.tags and #itemData.tags > 0 then cat = itemData.tags[1] end
                            cat = tostring(cat)

                            if not categorized[cat] then 
                                categorized[cat] = {}
                                table.insert(categories, cat)
                            end

                            local priceMod = 1.0
                            if DynamicTrading.Events and type(DynamicTrading.Events.GetPriceModifier) == "function" then
                                local val = DynamicTrading.Events.GetPriceModifier(itemData.tags)
                                if type(val) == "number" then priceMod = val end
                            end

                            local displayName = tostring(invItem:getDisplayName())

                            table.insert(categorized[cat], {
                                key = masterKey,
                                invItem = invItem,
                                name = displayName,
                                price = tonumber(price) or 0,
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
    end

    table.sort(categories, function(a,b) return tostring(a) < tostring(b) end)

    for _, catName in ipairs(categories) do
        if categorized[catName] and #categorized[catName] > 0 then
            
            local hItem = self.listbox:addItem(string.upper(catName), nil)
            hItem.item = { isCategory = true, categoryName = catName, text = string.upper(catName) }
            hItem.height = 32
            
            if not self.collapsed[catName] then
                local itemsInCat = categorized[catName]
                
                table.sort(itemsInCat, function(a,b) 
                    local na = tostring(a.name or "")
                    local nb = tostring(b.name or "")
                    return na < nb
                end)
                
                for _, prod in ipairs(itemsInCat) do
                    local index = self.listbox:addItem(prod.name, prod)
                    
                    if self.isBuying and self.selectedKey and prod.key == self.selectedKey then
                        if type(index) == "number" then
                            self.listbox.selected = index
                        else
                            self.listbox.selected = -1
                        end
                    end
                end
            end
        end
    end
    
    self.listbox:setYScroll(oldScroll)
end

-- =================================================
-- ACTION LOGIC (SYNC FIX)
-- =================================================
function DynamicTradingUI:onAction()
    if not self.listbox or type(self.listbox.selected) ~= "number" or self.listbox.selected == -1 then return end

    local selItem = self.listbox.items[self.listbox.selected]
    if not selItem or not selItem.item or selItem.item.isCategory then return end
    
    local d = selItem.item
    local player = getSpecificPlayer(0)

    if not self:isConnectionValid() then
        self:close()
        player:Say("Signal lost!")
        return
    end

    if self.isBuying then
        if d.qty <= 0 then 
            player:Say("It's sold out.")
            return 
        end
        
        local wealth = self:getPlayerWealth(player)
        if wealth >= d.price then
            self:removeMoney(player, d.price)
            
            -- [FIX] Use standard AddItem
            -- This handles creation logic internally in C++/Java.
            player:getInventory():AddItem(d.data.item)
            
            local primaryCat = d.data.tags[1] or "Misc"
            
            -- Send server update for Stock
            sendClientCommand(player, "DynamicTrading", "TradeTransaction", {
                type = "buy",
                traderID = self.traderID,
                key = d.key,
                category = primaryCat,
                qty = 1
            })
            player:playSound("Transaction") 
            
            -- [FIX] FORCE INVENTORY UI REFRESH
            -- This ensures the player's inventory UI syncs up with the new item immediately,
            -- fixing the "Ghost Item" bug.
            triggerEvent("OnContainerUpdate")
        else
            player:Say("Not enough cash!")
        end
    else
        player:getInventory():Remove(d.invItem)
        self:addMoney(player, d.price)
        local primaryCat = d.data.tags[1] or "Misc"
        
        sendClientCommand(player, "DynamicTrading", "TradeTransaction", {
            type = "sell",
            traderID = self.traderID,
            key = d.key,
            category = primaryCat,
            qty = 1
        })
        player:playSound("Transaction")
        
        -- [FIX] FORCE INVENTORY UI REFRESH
        triggerEvent("OnContainerUpdate")
    end
    self.btnAction:setEnable(false)
end

function DynamicTradingUI:onToggleMode()
    self.isBuying = not self.isBuying
    self.selectedKey = nil
    self:populateList()
    self.btnAction:setEnable(false)
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

local function OnDataSync(key, data)
    if key == "DynamicTrading_Engine_v1" then
        if DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
            DynamicTradingUI.instance:populateList()
        end
    end
end
Events.OnReceiveGlobalModData.Add(OnDataSync)
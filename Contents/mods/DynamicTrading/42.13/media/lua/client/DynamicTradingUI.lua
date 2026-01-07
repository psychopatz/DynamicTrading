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
    self.lastSelectedIndex = -1
end

-- =================================================
-- LIVE STATE CHECK
-- =================================================
function DynamicTradingUI:update()
    ISCollapsableWindow.update(self)

    -- Crash Shield
    if self.listbox then
        if self.listbox.items == nil then self.listbox.items = {} end
        if type(self.listbox.selected) ~= "number" then self.listbox.selected = -1 end
    end

    if not self.traderID then self:close() return end

    local data = DynamicTrading.Manager.GetData()
    local trader = data.Traders and data.Traders[self.traderID]

    if not trader then
        local player = getSpecificPlayer(0)
        if player then
            player:playSound("RadioStatic")
            player:Say("Signal Lost: The trader signed off.")
        end
        self:close()
        return
    end

    -- Update Title if changed
    if self.lblTitle then
        local archetypeName = DynamicTrading.Archetypes[trader.archetype] and DynamicTrading.Archetypes[trader.archetype].name or "Unknown"
        local desiredTitle = (trader.name or "Unknown") .. " - " .. archetypeName
        
        if self.lblTitle.name ~= desiredTitle then
            self.lblTitle:setName(desiredTitle)
        end
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

-- =================================================
-- UI LAYOUT
-- =================================================
function DynamicTradingUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    self.lblTitle = ISLabel:new(self.width / 2, 15, 20, "Establishing Connection...", 1, 1, 1, 1, UIFont.Medium, true)
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

    local oldPrerender = self.listbox.prerender
    self.listbox.prerender = function(box)
        if box.items == nil then box.items = {} end
        if type(box.selected) ~= "number" then box.selected = -1 end
        if box.selected ~= -1 and box.selected > #box.items then box.selected = -1 end
        if oldPrerender then oldPrerender(box) end
    end
    
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
            ui.lastSelectedIndex = row
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
function DynamicTradingUI.TruncateString(text, font, maxWidth)
    local tm = TextManager.instance
    if tm:MeasureStringX(font, text) <= maxWidth then return text end
    
    local len = string.len(text)
    while len > 0 do
        text = string.sub(text, 1, len - 1)
        if tm:MeasureStringX(font, text .. "...") <= maxWidth then
            return text .. "..."
        end
        len = len - 1
    end
    return "..."
end

function DynamicTradingUI:getPlayerWealth(player)
    local inv = player:getInventory()
    local looseList = inv:getItemsFromType("Base.Money", true)
    local bundleList = inv:getItemsFromType("Base.MoneyBundle", true)
    local looseCount = looseList and looseList:size() or 0
    local bundleCount = bundleList and bundleList:size() or 0
    return looseCount + (bundleCount * 100)
end

function DynamicTradingUI:updateWallet()
    local player = getSpecificPlayer(0)
    local wealth = self:getPlayerWealth(player)
    if self.lblInfo then
        self.lblInfo:setName("Wallet: $" .. wealth)
    end
end

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
        else
            text = string.format("Signal: Fading (%dh)", math.floor(diff))
            r, g, b = 1.0, 0.8, 0.2 
        end
    end

    if self.lblSignal then
        self.lblSignal:setName(text)
        self.lblSignal:setColor(r, g, b, 1)
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
    local qty = tonumber(d.qty) or 0
    if d.isBuy and qty <= 0 then nameColor = {r=0.5, g=0.5, b=0.5} end
    
    local maxNameWidth = (width - 150) - 45
    local displayName = DynamicTradingUI.TruncateString(d.name, listbox.font, maxNameWidth)
    listbox:drawText(displayName, 45, y + 12, nameColor.r, nameColor.g, nameColor.b, 1, listbox.font)
    
    local priceR, priceG, priceB = 0.6, 1.0, 0.6 
    if d.isBuy and d.priceMod > 1.01 then priceR, priceG, priceB = 1.0, 0.4, 0.4 end
    if d.isBuy and d.priceMod < 0.99 then priceR, priceG, priceB = 0.2, 1.0, 1.0 end

    if d.isBuy then
        if qty <= 0 then
            listbox:drawText("(SOLD OUT)", width - 140, y + 12, 1.0, 0.2, 0.2, 1, UIFont.Small)
        else
            listbox:drawText("Stock: " .. qty, width - 140, y + 12, 0.7, 0.7, 0.7, 1, listbox.font)
        end
    end
    listbox:drawText("$" .. d.price, width - 60, y + 12, priceR, priceG, priceB, 1, listbox.font)
    
    return y + height
end

-- =================================================
-- POPULATE LIST
-- =================================================
function DynamicTradingUI:populateList()
    local oldScroll = self.listbox:getYScroll()
    self.listbox:clear()
    
    local managerData = DynamicTrading.Manager.GetData()
    if not managerData or not self.traderID then return end
    
    local trader = DynamicTrading.Manager.GetTrader(self.traderID, self.archetype)
    if not trader then return end
    
    local archetypeName = DynamicTrading.Archetypes[trader.archetype] and DynamicTrading.Archetypes[trader.archetype].name or "Unknown"
    local desiredTitle = (trader.name or "Unknown") .. " - " .. archetypeName
    self.lblTitle:setName(desiredTitle)
    
    self:updateSignalDisplay(trader)
    self:updateWallet()

    local categorized = {} 
    local categories = {}  

    -- 1. BUILD DATA
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
                    local cat = itemData.tags[1] or "Misc"

                    if not categorized[cat] then 
                        categorized[cat] = {}
                        table.insert(categories, cat)
                    end
                    
                    local priceMod = 1.0
                    if DynamicTrading.Events and DynamicTrading.Events.GetPriceModifier then
                        priceMod = DynamicTrading.Events.GetPriceModifier(itemData.tags)
                    end

                    table.insert(categorized[cat], {
                        key = key,
                        name = sortName,
                        qty = tonumber(qty) or 0,
                        price = tonumber(price) or 0,
                        data = itemData,
                        isBuy = true,
                        isCategory = false,
                        priceMod = priceMod
                    })
                end
            end
        end
    else
        self.btnSwitch:setTitle("SWITCH TO BUYING")
        self.btnAction:setTitle("SELL ITEM")

        local player = getSpecificPlayer(0)
        local inv = player:getInventory()
        local items = inv:getItems()
        
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
                            local cat = itemData.tags[1] or "Misc"
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
                                name = tostring(invItem:getDisplayName()),
                                price = tonumber(price) or 0,
                                data = itemData,
                                isBuy = false,
                                isCategory = false,
                                priceMod = priceMod
                            })
                        end
                    end
                end
            end
        end
    end

    table.sort(categories)

    for _, catName in ipairs(categories) do
        if categorized[catName] and #categorized[catName] > 0 then
            local hItem = self.listbox:addItem(string.upper(catName), nil)
            hItem.item = { isCategory = true, categoryName = catName, text = string.upper(catName) }
            hItem.height = 32
            
            if not self.collapsed[catName] then
                local itemsInCat = categorized[catName]
                table.sort(itemsInCat, function(a,b) return a.name < b.name end)
                
                for _, prod in ipairs(itemsInCat) do
                    self.listbox:addItem(prod.name, prod)
                end
            end
        end
    end
    
    -- Selection Recovery
    local foundSelection = false
    if self.selectedKey then
        for i, listItem in ipairs(self.listbox.items) do
            if listItem.item and not listItem.item.isCategory then
                if listItem.item.key == self.selectedKey then
                    self.listbox.selected = i
                    foundSelection = true
                    if self.isBuying then
                        if listItem.item.qty > 0 then self.btnAction:setEnable(true)
                        else self.btnAction:setEnable(false) end
                    else
                        self.btnAction:setEnable(true)
                    end
                    break
                end
            end
        end
    end
    
    if not foundSelection and not self.isBuying and self.lastSelectedIndex > -1 then
        local count = #self.listbox.items
        if count > 0 then
            if self.lastSelectedIndex > count then self.lastSelectedIndex = count end
            local candidate = self.listbox.items[self.lastSelectedIndex]
            
            if candidate and candidate.item and candidate.item.isCategory then
                self.lastSelectedIndex = self.lastSelectedIndex + 1
            end
            
            if self.lastSelectedIndex <= count then
                local newItem = self.listbox.items[self.lastSelectedIndex]
                if newItem and newItem.item and not newItem.item.isCategory then
                    self.listbox.selected = self.lastSelectedIndex
                    self.selectedKey = newItem.item.key
                    self.btnAction:setEnable(true)
                else
                    self.selectedKey = nil
                    self.btnAction:setEnable(false)
                end
            else
                self.selectedKey = nil
                self.btnAction:setEnable(false)
            end
        else
             self.selectedKey = nil
             self.btnAction:setEnable(false)
        end
    end
    
    if self.isBuying and not foundSelection then
        self.btnAction:setEnable(false)
    end
    
    self.listbox:setYScroll(oldScroll)
end

-- =================================================
-- ACTION (SP/MP BRIDGE)
-- =================================================
function DynamicTradingUI:onAction()
    if not self.listbox or self.listbox.selected == -1 then return end
    local selItem = self.listbox.items[self.listbox.selected]
    if not selItem or not selItem.item or selItem.item.isCategory then return end
    
    local d = selItem.item
    local player = getSpecificPlayer(0)
    local primaryCat = d.data.tags[1] or "Misc"

    -- Pre-checks for feedback
    if self.isBuying then
        if d.qty <= 0 then 
            player:Say("It's sold out.")
            return 
        end
        local wealth = self:getPlayerWealth(player)
        if wealth < d.price then
            player:Say("Not enough cash!")
            return
        end
    end

    local args = {
        type = self.isBuying and "buy" or "sell",
        traderID = self.traderID,
        key = d.key,
        category = primaryCat,
        qty = 1
    }

    -- 1. DETECT MODE
    local gameMode = getWorld():getGameMode()
    local isMultiplayer = (gameMode == "Multiplayer")

    if isMultiplayer then
        -- [MULTIPLAYER] Send packet, wait for OnServerCommand event to refresh UI
        sendClientCommand(player, "DynamicTrading", "TradeTransaction", args)
    else
        -- [SINGLEPLAYER] Direct Call & Manual Refresh
        if DynamicTrading.ServerCommands and DynamicTrading.ServerCommands.TradeTransaction then
            DynamicTrading.ServerCommands.TradeTransaction(player, args)
            
            -- FORCE REFRESH IMMEDIATELY (Fixes the SP UI update lag)
            self:populateList()
            player:playSound("Transaction")
        end
    end
end

function DynamicTradingUI:onToggleMode()
    self.isBuying = not self.isBuying
    self.selectedKey = nil
    self.lastSelectedIndex = -1
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

-- =================================================
-- EVENTS (MP ONLY REFRESH)
-- =================================================
local function OnDataSync(key, data)
    if key == "DynamicTrading_Engine_v1" then
        if DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
            DynamicTradingUI.instance:populateList()
        end
    end
end
Events.OnReceiveGlobalModData.Add(OnDataSync)

local function OnServerCommand(module, command, args)
    if module == "DynamicTrading" and command == "TransactionResult" then
        if args.success then
            -- This plays sound/refreshes for MP. 
            -- In SP, the manual call in onAction handles this, so this is just redundant but harmless.
            getSpecificPlayer(0):playSound("Transaction")
            if DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
                DynamicTradingUI.instance:populateList()
            end
        else
            if args.msg then getSpecificPlayer(0):Say(args.msg) end
        end
    end
end
Events.OnServerCommand.Add(OnServerCommand)
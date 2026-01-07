require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISImage"
require "DynamicTrading_Config"
require "DynamicTrading_Manager"
require "DynamicTrading_Economy"
require "DynamicTrading_Events" 

DynamicTradingUI = ISCollapsableWindow:derive("DynamicTradingUI")
DynamicTradingUI.instance = nil

-- =================================================
-- CONFIGURATION: AVATAR MAPPING
-- =================================================
local ArchetypeIcons = {
    ["General"]     = "Item_Spiffo",
    ["Farmer"]      = "Item_Corn",
    ["Butcher"]     = "Item_MeatCleaver",
    ["Doctor"]      = "Item_FirstAidKit",
    ["Mechanic"]    = "Item_Wrench",
    ["Survivalist"] = "Item_Bag_ALICEpack",
    ["Gunrunner"]   = "Item_Pistol",
    ["Foreman"]     = "Item_Sledgehammer",
    ["Scavenger"]   = "Item_Crowbar",
    ["Tailor"]      = "Item_SewingKit",
    ["Electrician"] = "Item_ElectronicsScrap",
    ["Welder"]      = "Item_BlowTorch",
    ["Chef"]        = "Item_ChefHat",
    ["Herbalist"]   = "Item_Plantain",
    ["Smuggler"]    = "Item_Cigarettes",
    ["Librarian"]   = "Item_Book",
    ["Angler"]      = "Item_FishingRod",
    ["Sheriff"]     = "Item_Revolver_Long",
    ["Bartender"]   = "Item_WhiskeyFull",
    ["Teacher"]     = "Item_Pencil",
    ["Hunter"]      = "Item_Shotgun",
    ["Quartermaster"]= "Item_Bag_SurvivorBag",
    ["Musician"]    = "Item_GuitarAcoustic",
    ["Janitor"]     = "Item_Bleach",
    ["Carpenter"]   = "Item_Hammer",
    ["Pawnbroker"]  = "Item_GoldBar",
    ["Pyro"]        = "Item_PetrolCan",
    ["Athlete"]     = "Item_BaseballBat",
    ["Pharmacist"]  = "Item_Pills",
    ["Hiker"]       = "Item_Bag_HikingBag",
    ["Burglar"]     = "Item_Lockpick",
    ["Blacksmith"]  = "Item_MetalBar",
    ["Tribal"]      = "Item_SpearCrafted",
    ["Painter"]     = "Item_Paintbrush",
    ["RoadWarrior"] = "Item_SpikedBat",
    ["Designer"]    = "Item_Rug",
    ["Office"]      = "Item_Paperclip",
    ["Geek"]        = "Item_ToyCar",
    ["Brewer"]      = "Item_AlcoholWipes",
    ["Demo"]        = "Item_PipeBomb"
}

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
    self.localLogs = {}
end

-- =================================================
-- UPDATE LOOP
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
        self:logLocal("Signal Lost: Trader signed off.", true)
        self:close()
        return
    end

    -- Update Identity Info
    self:updateIdentityDisplay(trader)
    
    -- Update Wallet Text
    self:updateWallet()

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

    -- Layout Metrics
    local leftColW = 250
    local rightX = 270
    local rightW = self.width - rightX - 10
    local th = self:titleBarHeight()

    -- ====================================
    -- LEFT COLUMN (Identity & Logs)
    -- ====================================

    -- 1. TRADER IMAGE AREA
    self.imageY = th + 10
    self.imageH = 200
    
    -- 2. TEXT LABELS (Name, Archetype, Signal)
    -- Using separate labels to control centering and color perfectly
    local nameY = self.imageY + self.imageH + 10      -- Y = ~226
    local archY = nameY + 25                          -- Y = ~251
    local sigY  = archY + 20                          -- Y = ~271
    local wallY = sigY + 30                           -- Y = ~301
    
    -- LABEL: Name (White, Large)
    self.lblName = ISLabel:new(leftColW / 2 + 10, nameY, 25, "Loading...", 1, 1, 1, 1, UIFont.Medium, true)
    self.lblName.center = true
    self:addChild(self.lblName)
    
    -- LABEL: Archetype (Gold, No Parens)
    self.lblArchetype = ISLabel:new(leftColW / 2 + 10, archY, 20, "Survivor", 1.0, 0.8, 0.2, 1, UIFont.Small, true)
    self.lblArchetype.center = true
    self:addChild(self.lblArchetype)

    -- LABEL: Signal (Dynamic Color)
    self.lblSignal = ISLabel:new(leftColW / 2 + 10, sigY, 16, "Signal: ...", 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.lblSignal.center = true
    self:addChild(self.lblSignal)

    -- 3. WALLET DISPLAY
    self.lblInfo = ISLabel:new(leftColW / 2 + 10, wallY, 25, "Wallet: $0", 0.2, 1.0, 0.2, 1, UIFont.Medium, true)
    self.lblInfo.center = true
    self:addChild(self.lblInfo)

    -- 4. ACTION BUTTON (Buy/Sell)
    self.btnAction = ISButton:new(20, wallY + 35, leftColW - 20, 30, "BUY ITEM", self, self.onAction)
    self.btnAction:initialise()
    self.btnAction.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1.0}
    self.btnAction:setEnable(false)
    self:addChild(self.btnAction)

    -- 5. LOCAL MESSAGE LOG (Bottom Left)
    local logY = wallY + 75
    local logH = self.height - logY - 10
    
    self.chatList = ISScrollingListBox:new(10, logY, leftColW, logH)
    self.chatList:initialise()
    self.chatList:setAnchorBottom(true)
    self.chatList.font = UIFont.NewSmall
    self.chatList.itemheight = 18
    self.chatList.drawBorder = true
    self.chatList.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.chatList.backgroundColor = {r=0.0, g=0.0, b=0.0, a=0.8}
    self.chatList.doDrawItem = self.drawLogItem 
    self:addChild(self.chatList)
    
    self:logLocal("Connection established.", false)

    -- ====================================
    -- RIGHT COLUMN (Market Data)
    -- ====================================

    -- 1. SWITCH BUTTON
    self.btnSwitch = ISButton:new(rightX, th + 10, rightW, 25, "SWITCH TO SELLING", self, self.onToggleMode)
    self.btnSwitch:initialise()
    self.btnSwitch.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
    self.btnSwitch:setAnchorRight(true)
    self:addChild(self.btnSwitch)

    -- 2. ITEM LIST
    self.listbox = ISScrollingListBox:new(rightX, th + 45, rightW, self.height - (th + 55))
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
            
            if ui.isBuying then
                ui.btnAction:setTitle("BUY ($" .. item.item.price .. ")")
            else
                ui.btnAction:setTitle("SELL ($" .. item.item.price .. ")")
            end
        end
    end
    self:addChild(self.listbox)
end

-- =================================================
-- LOGIC & HELPERS
-- =================================================

function DynamicTradingUI:logLocal(text, isError)
    local entry = { text = text, error = isError }
    table.insert(self.localLogs, entry)
    
    self.chatList:clear()
    for _, log in ipairs(self.localLogs) do
        self.chatList:addItem(log.text, log)
    end
    self.chatList:ensureVisible(#self.chatList.items)
end

function DynamicTradingUI:drawLogItem(y, item, alt)
    local height = self.itemheight
    local width = self:getWidth()
    
    if alt then 
        self:drawRect(0, y, width, height, 0.1, 0.1, 0.1, 0.5) 
    end
    
    local r, g, b = 0.8, 0.8, 0.8
    if item.item.error then r, g, b = 1.0, 0.4, 0.4 end 
    if string.find(item.item.text, "Purchased") then r, g, b = 0.4, 1.0, 0.4 end 
    if string.find(item.item.text, "Sold") then r, g, b = 0.4, 0.8, 1.0 end 

    self:drawText(item.text, 5, y + 2, r, g, b, 1, self.font)
    return y + height
end

function DynamicTradingUI:getTraderTexture(archetype)
    local iconName = ArchetypeIcons[archetype]
    if not iconName then iconName = "Item_Spiffo" end
    
    local tex = getTexture(iconName)
    if not tex then 
        tex = getTexture("Item_" .. iconName)
    end
    if not tex then tex = getTexture("Item_Radio") end
    
    return tex
end

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

-- [REVISED] Update all identity text elements
function DynamicTradingUI:updateIdentityDisplay(trader)
    -- 1. NAME
    if self.lblName then
        self.lblName:setName(trader.name or "Unknown")
    end

    -- 2. ARCHETYPE (Gold Color, No Parens)
    if self.lblArchetype then
        local archName = DynamicTrading.Archetypes[trader.archetype] and DynamicTrading.Archetypes[trader.archetype].name or "Unknown"
        self.lblArchetype:setName(archName)
        -- Set Color (Gold/Orange)
        self.lblArchetype:setColor(1.0, 0.8, 0.2, 1) 
    end

    -- 3. SIGNAL (Color Logic)
    if self.lblSignal then
        local gt = GameTime:getInstance()
        local text = "Signal: Permanent"
        local r, g, b = 0.5, 0.8, 1.0 

        if trader.expirationTime then
            local currentHours = gt:getWorldAgeHours()
            local diff = trader.expirationTime - currentHours
            if diff <= 0 then
                text = "Signal: Lost"
                r, g, b = 1.0, 0.0, 0.0 
            elseif diff > 24 then
                local days = math.floor(diff / 24)
                text = string.format("Signal: Stable (%dd)", days)
                r, g, b = 0.2, 1.0, 0.2 
            else
                text = string.format("Signal: Fading (%dh)", math.floor(diff))
                r, g, b = 1.0, 0.8, 0.2 
            end
        end
        
        self.lblSignal:setName(text)
        self.lblSignal:setColor(r, g, b, 1)
    end
end

-- =================================================
-- RENDER (Custom Drawing)
-- =================================================
function DynamicTradingUI:render()
    ISCollapsableWindow.render(self)

    -- Draw Trader Avatar
    local tex = self:getTraderTexture(self.archetype)
    if tex then
        self:drawRectBorder(10, self.imageY, 250, 200, 1.0, 1.0, 1.0, 1.0)
        self:drawTextureScaled(tex, 11, self.imageY + 1, 248, 198, 1.0, 1.0, 1.0, 1.0)
    end
end

-- =================================================
-- LISTBOX DRAWING
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
    if d.isBuy then
        if d.priceMod > 1.01 then priceR, priceG, priceB = 1.0, 0.4, 0.4 end 
        if d.priceMod < 0.99 then priceR, priceG, priceB = 0.2, 1.0, 1.0 end 
    else
        if d.priceMod > 1.01 then priceR, priceG, priceB = 1.0, 0.8, 0.2 end 
    end

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
    
    self:updateIdentityDisplay(trader)
    self:updateWallet()

    local categorized = {} 
    local categories = {}  

    if self.isBuying then
        self.btnSwitch:setTitle("SWITCH TO SELLING")
        self.btnAction:setTitle("SELECT AN ITEM")

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
        self.btnAction:setTitle("SELECT AN ITEM")

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
    
    local foundSelection = false
    if self.selectedKey then
        for i, listItem in ipairs(self.listbox.items) do
            if listItem.item and not listItem.item.isCategory then
                if listItem.item.key == self.selectedKey then
                    self.listbox.selected = i
                    foundSelection = true
                    
                    local actionStr = self.isBuying and "BUY" or "SELL"
                    self.btnAction:setTitle(actionStr .. " ($" .. listItem.item.price .. ")")
                    
                    if self.isBuying and listItem.item.qty <= 0 then 
                        self.btnAction:setEnable(false)
                    else 
                        self.btnAction:setEnable(true)
                    end
                    break
                end
            end
        end
    end
    
    if not foundSelection then
        self.btnAction:setEnable(false)
        self.btnAction:setTitle("SELECT AN ITEM")
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

    if self.isBuying then
        if d.qty <= 0 then 
            self:logLocal("Error: Item is sold out.", true)
            return 
        end
        local wealth = self:getPlayerWealth(player)
        if wealth < d.price then
            self:logLocal("Error: Not enough cash. Need $" .. d.price, true)
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

    local gameMode = getWorld():getGameMode()
    local isMultiplayer = (gameMode == "Multiplayer")

    if isMultiplayer then
        sendClientCommand(player, "DynamicTrading", "TradeTransaction", args)
    else
        if DynamicTrading.ServerCommands and DynamicTrading.ServerCommands.TradeTransaction then
            DynamicTrading.ServerCommands.TradeTransaction(player, args)
            self:populateList()
            player:playSound("Transaction")
            
            if self.isBuying then
                self:logLocal("Purchased: " .. d.name .. " (-$" .. d.price .. ")", false)
            else
                self:logLocal("Sold: " .. d.name .. " (+$" .. d.price .. ")", false)
            end
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

    local ui = DynamicTradingUI:new(100, 100, 750, 600)
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
    if key == "DynamicTrading_Engine_v1.1" then
        if DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
            DynamicTradingUI.instance:populateList()
        end
    end
end
Events.OnReceiveGlobalModData.Add(OnDataSync)

local function OnServerCommand(module, command, args)
    if module == "DynamicTrading" and command == "TransactionResult" then
        if DynamicTradingUI.instance and DynamicTradingUI.instance:isVisible() then
            if args.msg then
                local isErr = not args.success
                DynamicTradingUI.instance:logLocal(args.msg, isErr)
            end
            if args.success then
                getSpecificPlayer(0):playSound("Transaction")
                DynamicTradingUI.instance:populateList()
            end
        end
    end
end
Events.OnServerCommand.Add(OnServerCommand)
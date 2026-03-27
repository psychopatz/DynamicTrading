require "DT/Common/UI/Trading/DT_Trading"

local LEFT_COL_W = 250
local RIGHT_MARGIN = 10
local PADDING = 10

function DT_TradingWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local rightX = LEFT_COL_W + 20
    local rightW = self.width - rightX - RIGHT_MARGIN

    self.imageY = th + PADDING
    self.imageH = 250 -- Fixed square height
    self.imageW = 250 -- Fixed square width

    -- Identity Labels
    self.lblName = ISLabel:new(LEFT_COL_W / 2 + 10, 0, 25, "Loading...", 1, 1, 1, 1, UIFont.Medium, true)
    self.lblName.center = true
    self:addChild(self.lblName)

    self.lblArchetype = ISLabel:new(LEFT_COL_W / 2 + 10, 0, 20, "Survivor", 1.0, 0.8, 0.2, 1, UIFont.Small, true)
    self.lblArchetype.center = true
    self:addChild(self.lblArchetype)

    self.lblSignal = ISLabel:new(LEFT_COL_W / 2 + 10, 0, 16, "Signal: ...", 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.lblSignal.center = true
    self:addChild(self.lblSignal)

    self.lblTraderBudget = ISLabel:new(LEFT_COL_W / 2 + 10, 0, 25, "Trader Budget: $0", 1.0, 0.8, 0.2, 1, UIFont.Medium, true)
    self.lblTraderBudget.center = true
    self:addChild(self.lblTraderBudget)

    self.lblInfo = ISLabel:new(LEFT_COL_W / 2 + 10, 0, 25, "Wallet: $0", 0.2, 1.0, 0.2, 1, UIFont.Medium, true)
    self.lblInfo.center = true
    self:addChild(self.lblInfo)

    -- Ask Button (Organic immersion)
    self.btnAsk = ISButton:new(20, 0, LEFT_COL_W - 20, 25, "Talk", self, self.onAsk)
    self.btnAsk:initialise()
    self.btnAsk.backgroundColor = {r=0.2, g=0.2, b=0.4, a=1.0}
    self.btnAsk:setVisible(true) 
    self:addChild(self.btnAsk)

    -- Lock Button (Client-side protection)
    self.btnLock = ISButton:new(20, 0, LEFT_COL_W - 20, 25, "LOCK ITEM", self, self.onToggleLock)
    self.btnLock:initialise()
    self.btnLock.backgroundColor = {r=0.4, g=0.4, b=0.1, a=1.0}
    self.btnLock:setEnable(false)
    self.btnLock:setVisible(false) 
    self:addChild(self.btnLock)

    -- Main Action Button (Buy/Sell)
    self.btnAction = ISButton:new(20, 0, LEFT_COL_W - 20, 30, "BUY ITEM", self, self.onAction)
    self.btnAction:initialise()
    self.btnAction.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1.0}
    self.btnAction:setEnable(false)
    self:addChild(self.btnAction)

    -- Chat/Log List
    self.chatList = ISScrollingListBox:new(10, 0, LEFT_COL_W, 100)
    self.chatList:initialise()
    self.chatList:setAnchorBottom(true)
    self.chatList.font = UIFont.NewSmall
    self.chatList.itemheight = 18
    self.chatList.drawBorder = true
    self.chatList.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.chatList.backgroundColor = {r=0.0, g=0.0, b=0.0, a=0.8}
    self.chatList.doDrawItem = self.drawLogItem
    self:addChild(self.chatList)

    -- Tab Panel (Mode Switching)
    local tabW = rightW / 2
    self.btnTabBuy = ISButton:new(rightX, th + PADDING, tabW, 25, "BUY FROM TRADER", self, function(self) self:setTradingMode(true) end)
    self.btnTabBuy:initialise()
    self.btnTabBuy.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1.0}
    self.btnTabBuy:setAnchorRight(true)
    self:addChild(self.btnTabBuy)

    self.btnTabSell = ISButton:new(rightX + tabW, th + PADDING, tabW, 25, "SELL TO TRADER", self, function(self) self:setTradingMode(false) end)
    self.btnTabSell:initialise()
    self.btnTabSell.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
    self.btnTabSell:setAnchorRight(true)
    self:addChild(self.btnTabSell)

    -- Main Item List
    self.listbox = ISScrollingListBox:new(rightX, th + 45, rightW, self.height - (th + 55))
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.NewSmall
    self.listbox.itemheight = 40
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.listbox.doDrawItem = DT_TradingWindow.drawItem

    -- Selection Logic with Safety Checks
    self.listbox.onMouseDown = function(target, x, y)
        local row = target:rowAt(x, y)
        if type(row) ~= "number" or row == -1 then return end

        local item = target.items[row]
        if not item or not item.item then return end

        local ui = DT_TradingWindow.instance
        if not ui then return end

        -- Handle Categories
        if item.item.isCategory then
            local catName = item.item.categoryName
            ui.collapsed[catName] = not ui.collapsed[catName]
            ui:populateList()
            return
        end

        -- Update Selection State
        target.selected = row
        ui.selectedKey = item.item.selectionKey or item.item.key
        ui.selectedItemID = item.item.isGrouped and -1 or (item.item.itemID or -1)
        ui.lastSelectedIndex = row
        
        -- Default Button State
        ui.btnAction:setEnable(true)
        
        if ui.isBuying then
            -- Buying Mode: Lock button hidden
            ui.btnAction:setTitle("BUY ($" .. item.item.price .. ")")
            ui.btnLock:setVisible(false)
            ui.btnAction:setEnable(item.item.qty > 0)
        else
            -- Selling Mode: Show Lock & Ask buttons
            local sellQty = tonumber(item.item.qty) or 1
            if sellQty > 1 then
                ui.btnAction:setTitle("SELL x" .. sellQty .. " ($" .. item.item.price .. " EA)")
            else
                ui.btnAction:setTitle("SELL ($" .. item.item.price .. ")")
            end
            if ui.btnAsk then ui.btnAsk:setVisible(true) end
            
            local isLocked = item.item.isLocked == true

            if sellQty > 1 then
                ui.btnLock:setTitle("LOCK ITEM")
                ui.btnLock:setEnable(false)
                ui.btnLock:setVisible(false)
                ui.btnAction:setEnable(true)
            elseif isLocked then
                ui.btnLock:setTitle("UNLOCK ITEM")
                ui.btnLock:setVisible(true)
                ui.btnLock:setEnable(true)
                ui.btnAction:setEnable(false) -- Cannot sell while locked
            else
                ui.btnLock:setTitle("LOCK ITEM")
                ui.btnLock:setVisible(true)
                ui.btnLock:setEnable(true)
                ui.btnAction:setEnable(true)
            end
        end
    end

    self:addChild(self.listbox)
    
    -- Initial Layout Strike
    self:relayout()
end

function DT_TradingWindow:relayout()
    local th = self:titleBarHeight()
    local rightX = LEFT_COL_W + 20
    local rightW = self.width - rightX - RIGHT_MARGIN
    
    -- 1. Portrait stays top-left square
    self.imageY = th + PADDING
    self.imageH = 250
    self.imageW = 250
    
    -- 2. Labels follow portrait
    local nextY = self.imageY + self.imageH + PADDING
    if self.lblName then self.lblName:setY(nextY) end
    if self.lblArchetype then self.lblArchetype:setY(nextY + 25) end
    if self.lblSignal then self.lblSignal:setY(nextY + 45) end
    if self.lblTraderBudget then self.lblTraderBudget:setY(nextY + 70) end
    if self.lblInfo then self.lblInfo:setY(nextY + 95) end
    
    -- 3. Buttons follow labels
    local buttonBaseY = nextY + 130
    if self.btnAsk then self.btnAsk:setY(buttonBaseY) end
    if self.btnLock then self.btnLock:setY(buttonBaseY + 30) end
    if self.btnAction then self.btnAction:setY(buttonBaseY + 60) end
    
    -- 4. Chat List starts below last button and fills to bottom
    local logY = buttonBaseY + 100
    if self.chatList then
        self.chatList:setY(logY)
        self.chatList:setHeight(self.height - logY - PADDING)
        -- Force scrollbar update
        if self.chatList.vscroll then
            self.chatList.vscroll:setHeight(self.chatList:getHeight())
        end
    end
    
    -- 5. Right column (Tabs & Listbox) updates
    local tabW = rightW / 2
    if self.btnTabBuy then
        self.btnTabBuy:setX(rightX)
        self.btnTabBuy:setWidth(tabW)
    end
    if self.btnTabSell then
        self.btnTabSell:setX(rightX + tabW)
        self.btnTabSell:setWidth(tabW)
    end
    
    if self.listbox then
        self.listbox:setX(rightX)
        self.listbox:setWidth(rightW)
        self.listbox:setHeight(self.height - (th + 55))
        -- Force scrollbar update
        if self.listbox.vscroll then
            self.listbox.vscroll:setHeight(self.listbox:getHeight())
        end
    end
end

function DT_TradingWindow:onResize()
    ISCollapsableWindow.onResize(self)
    self:relayout()
end

function DT_TradingWindow:render()
    ISCollapsableWindow.render(self)

    if self.traderID then
        local trader = self.dataProvider:getTrader(self.traderID, self.archetype)
        -- Portrait stays fixed size
        local imgW, imgH = 250, 250
        local imgX, imgY = 10, self.imageY

        local bgTex = self:getBackgroundTexture()
        if bgTex then self:drawTextureScaled(bgTex, imgX, imgY, imgW, imgH, 1.0, 1.0, 1.0, 1.0) end

        local faceTex = self:getTraderTexture(trader)
        if faceTex then self:drawTextureScaled(faceTex, imgX, imgY, imgW, imgH, 1.0, 1.0, 1.0, 1.0) end

        local crtTex = self:getOverlayTexture()
        if crtTex then
            local gt = GameTime:getInstance()
            local chaosFactor = 0.0
            if trader and trader.returnTime then
                local timeLeft = trader.returnTime - gt:getWorldAgeHours()
                if timeLeft > 24 then chaosFactor = 0.0
                elseif timeLeft <= 0 then chaosFactor = 1.0
                else chaosFactor = 1.0 - (timeLeft / 24.0) end
            else chaosFactor = 1.0 end
            
            local alpha = (0.15 + (chaosFactor * 0.3)) + ZombRandFloat(0.0, 0.05 + (chaosFactor * 0.4))
            self:drawTextureScaled(crtTex, imgX, imgY, imgW, imgH, math.min(alpha, 0.9), 1, 1, 1)
        end

        self:drawRectBorder(imgX - 1, self.imageY - 1, imgW + 2, imgH + 2, 1.0, 1.0, 1.0, 1.0)
        
        -- Positioning is now handled by relayout()

        -- [NEW] TYPING INDICATOR
        if #self.msgQueue > 0 then
            local nextMsg = self.msgQueue[1]
            if (not nextMsg.isPlayer) and (nextMsg.delay > 0) then
                local frame = math.floor(self.typingTick / 10) % 4
                local dots = ""
                if frame == 1 then dots = "."
                elseif frame == 2 then dots = ".."
                elseif frame == 3 then dots = "..."
                end
                local bubbleX, bubbleY = self.chatList:getX() + 5, self.chatList:getY() + self.chatList:getHeight() - 25
                self:drawRect(bubbleX, bubbleY, 40, 20, 0.9, 0.2, 0.2, 0.2)
                self:drawRectBorder(bubbleX, bubbleY, 40, 20, 0.5, 0.5, 0.5, 0.5)
                self:drawText(dots, bubbleX + 12, bubbleY + 2, 0.8, 0.8, 0.8, 1, self.chatList.font)
            end
        end
    end
end

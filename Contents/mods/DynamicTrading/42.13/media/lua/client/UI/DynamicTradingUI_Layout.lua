function DynamicTradingUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local leftColW = 250
    local rightX = 270
    local rightW = self.width - rightX - 10
    local th = self:titleBarHeight()

    self.imageY = th + 10
    self.imageH = 250 

    -- Calculate Y positions
    local nameY = self.imageY + self.imageH + 10
    local archY = nameY + 25
    local sigY  = archY + 20
    local wallY = sigY + 30

    -- Identity Labels
    self.lblName = ISLabel:new(leftColW / 2 + 10, nameY, 25, "Loading...", 1, 1, 1, 1, UIFont.Medium, true)
    self.lblName.center = true
    self:addChild(self.lblName)

    self.lblArchetype = ISLabel:new(leftColW / 2 + 10, archY, 20, "Survivor", 1.0, 0.8, 0.2, 1, UIFont.Small, true)
    self.lblArchetype.center = true
    self:addChild(self.lblArchetype)

    self.lblSignal = ISLabel:new(leftColW / 2 + 10, sigY, 16, "Signal: ...", 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.lblSignal.center = true
    self:addChild(self.lblSignal)

    self.lblInfo = ISLabel:new(leftColW / 2 + 10, wallY, 25, "Wallet: $0", 0.2, 1.0, 0.2, 1, UIFont.Medium, true)
    self.lblInfo.center = true
    self:addChild(self.lblInfo)

    -- Ask Button (Organic immersion)
    self.btnAsk = ISButton:new(20, wallY + 35, leftColW - 20, 25, "ASK WHAT THEY WANT", self, self.onAsk)
    self.btnAsk:initialise()
    self.btnAsk.backgroundColor = {r=0.2, g=0.2, b=0.4, a=1.0}
    self.btnAsk:setVisible(false) 
    self:addChild(self.btnAsk)

    -- Lock Button (Client-side protection)
    self.btnLock = ISButton:new(20, wallY + 65, leftColW - 20, 25, "LOCK ITEM", self, self.onToggleLock)
    self.btnLock:initialise()
    self.btnLock.backgroundColor = {r=0.4, g=0.4, b=0.1, a=1.0}
    self.btnLock:setEnable(false)
    self.btnLock:setVisible(false) 
    self:addChild(self.btnLock)

    -- Main Action Button (Buy/Sell)
    self.btnAction = ISButton:new(20, wallY + 95, leftColW - 20, 30, "BUY ITEM", self, self.onAction)
    self.btnAction:initialise()
    self.btnAction.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1.0}
    self.btnAction:setEnable(false)
    self:addChild(self.btnAction)

    -- Chat/Log List
    local logY = wallY + 135
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

    -- Mode Switch Button
    self.btnSwitch = ISButton:new(rightX, th + 10, rightW, 25, "SWITCH TO SELLING", self, self.onToggleMode)
    self.btnSwitch:initialise()
    self.btnSwitch.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
    self.btnSwitch:setAnchorRight(true)
    self:addChild(self.btnSwitch)

    -- Main Item List
    self.listbox = ISScrollingListBox:new(rightX, th + 45, rightW, self.height - (th + 55))
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.NewSmall
    self.listbox.itemheight = 40
    self.listbox.drawBorder = true
    self.listbox.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    self.listbox.doDrawItem = DynamicTradingUI.drawItem

    -- Selection Logic with Safety Checks
    self.listbox.onMouseDown = function(target, x, y)
        local row = target:rowAt(x, y)
        if type(row) ~= "number" or row == -1 then return end

        local item = target.items[row]
        if not item or not item.item then return end

        local ui = DynamicTradingUI.instance
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
        ui.selectedKey = item.item.key
        ui.selectedItemID = item.item.itemID or -1
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
            ui.btnAction:setTitle("SELL ($" .. item.item.price .. ")")
            ui.btnLock:setVisible(true)
            ui.btnLock:setEnable(true)
            if ui.btnAsk then ui.btnAsk:setVisible(true) end
            
            -- [CRITICAL SAFETY CHECK]
            -- Check if helper function exists before calling to prevent crash
            local isLocked = false
            if ui.isItemLocked then
                isLocked = ui:isItemLocked(ui.selectedItemID)
            end

            if isLocked then
                ui.btnLock:setTitle("UNLOCK ITEM")
                ui.btnAction:setEnable(false) -- Cannot sell while locked
            else
                ui.btnLock:setTitle("LOCK ITEM")
                ui.btnAction:setEnable(true)
            end
        end
    end

    self:addChild(self.listbox)
end

function DynamicTradingUI:render()
    ISCollapsableWindow.render(self)

    if self.traderID then
        local trader = DynamicTrading.Manager.GetTrader(self.traderID, self.archetype)
        local imgX, imgY = 11, self.imageY + 1
        local imgW, imgH = 248, 248

        local bgTex = self:getBackgroundTexture()
        if bgTex then self:drawTextureScaled(bgTex, imgX, imgY, imgW, imgH, 1.0, 1.0, 1.0, 1.0) end

        local faceTex = self:getTraderTexture(trader)
        if faceTex then self:drawTextureScaled(faceTex, imgX, imgY, imgW, imgH, 1.0, 1.0, 1.0, 1.0) end

        local crtTex = self:getOverlayTexture()
        if crtTex then
            local gt = GameTime:getInstance()
            local chaosFactor = 0.0
            if trader and trader.expirationTime then
                local timeLeft = trader.expirationTime - gt:getWorldAgeHours()
                if timeLeft > 24 then chaosFactor = 0.0
                elseif timeLeft <= 0 then chaosFactor = 1.0
                else chaosFactor = 1.0 - (timeLeft / 24.0) end
            else chaosFactor = 1.0 end
            
            local alpha = (0.15 + (chaosFactor * 0.3)) + ZombRandFloat(0.0, 0.05 + (chaosFactor * 0.4))
            self:drawTextureScaled(crtTex, imgX, imgY, imgW, imgH, math.min(alpha, 0.9), 1, 1, 1)
        end

        self:drawRectBorder(10, self.imageY, 250, 250, 1.0, 1.0, 1.0, 1.0)
    end
end
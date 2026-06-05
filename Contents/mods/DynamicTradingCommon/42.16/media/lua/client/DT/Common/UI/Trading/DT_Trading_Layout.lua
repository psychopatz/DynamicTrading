

local RIGHT_MARGIN = 10
local PADDING = 10

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

local function getLeftColumnWidth(window)
    return math.max(220, math.min(320, math.floor(window.width * 0.33)))
end

local function getColumnCenterX(window)
    local leftColW = getLeftColumnWidth(window)
    return math.floor((leftColW / 2) + PADDING)
end

function DT_TradingWindow:refreshPortraitWithTrader(trader, force)
    if not self.portraitPanel or not trader then
        return
    end

    local modeKey = DT_NPCPortraitRenderers.Use3DPortraits() and "3d" or "legacy"
    local genderKey = trader.gender or (trader.isFemale and "Female" or "Male") or "Male"
    local archetypeKey = trader.archetype or trader.archetypeID or trader.role or "General"
    local portraitKey = table.concat({
        modeKey,
        tostring(trader.traderID or trader.id or "unknown"),
        tostring(trader.identitySeed or 1),
        tostring(archetypeKey),
        tostring(genderKey),
        tostring(trader.npcRef or self.radioObj)
    }, ":")

    if (not force) and self._portraitKey == portraitKey then
        return
    end

    self._portraitKey = portraitKey

    self.portraitPanel:setOverlayMode("trading")
    self.portraitPanel:setAnimationProfile("trading")
    self.portraitPanel:setLegacyProvider(self.dataProvider)
    self.portraitPanel:setTargetCharacter(trader.npcRef, trader)
end

function DT_TradingWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local leftColW = getLeftColumnWidth(self)
    local rightX = leftColW + 20
    local rightW = self.width - rightX - RIGHT_MARGIN

    self.imageY = th + PADDING
    self.imageW = leftColW
    self.imageH = leftColW

    self.portraitPanel = DT_NPCPortraitPanel:new(PADDING, self.imageY, self.imageW, self.imageH, {
        overlayStyle = "trading"
    })
    self.portraitPanel:initialise()
    self.portraitPanel:instantiate()
    self:addChild(self.portraitPanel)

    local centerX = getColumnCenterX(self)

    self.lblName = ISLabel:new(centerX, 0, 25, T("DTCommon_UI_Trading_Loading", nil, "Loading..."), 1, 1, 1, 1, UIFont.Medium, true)
    self.lblName.center = true
    self:addChild(self.lblName)

    self.lblArchetype = ISLabel:new(centerX, 0, 20, T("DTCommon_UI_Trading_Survivor", nil, "Survivor"), 1.0, 0.8, 0.2, 1, UIFont.Small, true)
    self.lblArchetype.center = true
    self:addChild(self.lblArchetype)

    self.lblSignal = ISLabel:new(centerX, 0, 16, T("DTCommon_Status_Permanent", nil, "Status: Permanent"), 0.5, 0.5, 0.5, 1, UIFont.Small, true)
    self.lblSignal.center = true
    self:addChild(self.lblSignal)

    self.lblTraderBudget = ISLabel:new(centerX, 0, 25, T("DTCommon_UI_Trading_TraderBudget", { amount = 0 }, "Trader Budget: $0"), 1.0, 0.8, 0.2, 1, UIFont.Medium, true)
    self.lblTraderBudget.center = true
    self:addChild(self.lblTraderBudget)

    self.lblInfo = ISLabel:new(centerX, 0, 25, T("DTCommon_UI_Trading_Wallet", { amount = 0 }, "Wallet: $0"), 0.2, 1.0, 0.2, 1, UIFont.Medium, true)
    self.lblInfo.center = true
    self:addChild(self.lblInfo)

    self.btnAsk = ISButton:new(20, 0, leftColW - 20, 25, T("DTCommon_UI_Trading_Talk", nil, "Talk"), self, self.onAsk)
    self.btnAsk:initialise()
    self.btnAsk.backgroundColor = { r = 0.2, g = 0.2, b = 0.4, a = 1.0 }
    self.btnAsk:setVisible(true)
    self:addChild(self.btnAsk)

    self.btnLock = ISButton:new(20, 0, leftColW - 20, 25, T("DTCommon_UI_Trading_LockItem", nil, "LOCK ITEM"), self, self.onToggleLock)
    self.btnLock:initialise()
    self.btnLock.backgroundColor = { r = 0.4, g = 0.4, b = 0.1, a = 1.0 }
    self.btnLock:setEnable(false)
    self.btnLock:setVisible(false)
    self:addChild(self.btnLock)

    self.btnAction = ISButton:new(20, 0, leftColW - 20, 30, self:getDefaultActionTitle(), self, self.onAction)
    self.btnAction:initialise()
    self.btnAction.backgroundColor = { r = 0.2, g = 0.5, b = 0.2, a = 1.0 }
    self.btnAction:setEnable(false)
    self:addChild(self.btnAction)

    self.chatList = ISScrollingListBox:new(PADDING, 0, leftColW, 100)
    self.chatList:initialise()
    self.chatList:setAnchorBottom(true)
    self.chatList.font = UIFont.NewSmall
    self.chatList.itemheight = 18
    self.chatList.drawBorder = true
    self.chatList.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.chatList.backgroundColor = { r = 0.0, g = 0.0, b = 0.0, a = 0.8 }
    self.chatList.doDrawItem = self.drawLogItem
    self:addChild(self.chatList)

    local tabW = rightW / 2
    self.btnTabBuy = ISButton:new(rightX, th + PADDING, tabW, 25, self:getModeTabTitle(true), self, function(window) window:setTradingMode(true) end)
    self.btnTabBuy:initialise()
    self.btnTabBuy.backgroundColor = { r = 0.2, g = 0.5, b = 0.2, a = 1.0 }
    self.btnTabBuy:setAnchorRight(true)
    self:addChild(self.btnTabBuy)

    self.btnTabSell = ISButton:new(rightX + tabW, th + PADDING, tabW, 25, self:getModeTabTitle(false), self, function(window) window:setTradingMode(false) end)
    self.btnTabSell:initialise()
    self.btnTabSell.backgroundColor = { r = 0.2, g = 0.2, b = 0.2, a = 1.0 }
    self.btnTabSell:setAnchorRight(true)
    self:addChild(self.btnTabSell)

    self.listbox = ISScrollingListBox:new(rightX, th + 45, rightW, self.height - (th + 55))
    self.listbox:initialise()
    self.listbox:setAnchorRight(true)
    self.listbox:setAnchorBottom(true)
    self.listbox.font = UIFont.NewSmall
    self.listbox.itemheight = 40
    self.listbox.drawBorder = true
    self.listbox.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.listbox.doDrawItem = DT_TradingWindow.drawItem

    self.listbox.onMouseDown = function(target, x, y)
        local row = target:rowAt(x, y)
        if type(row) ~= "number" or row == -1 then
            return
        end

        local item = target.items[row]
        if not item or not item.item then
            return
        end

        local ui = DT_TradingWindow.instance
        if not ui then
            return
        end

        if item.item.isCategory then
            local catName = item.item.categoryName
            ui.collapsed[catName] = not ui.collapsed[catName]
            if not ui.isBuying and ui.sellScanSession then
                ui.sellScanListDirty = true
                ui:refreshSellScanProgress(true)
            else
                ui:populateList()
            end
            return
        end

        if item.item.isPlaceholder then
            target.selected = -1
            ui.selectedItemID = -1
            ui.btnAction:setEnable(false)
            ui.btnAction:setTitle(ui:getDefaultActionTitle())
            if ui.btnLock then
                ui.btnLock:setVisible(false)
            end
            return
        end

        target.selected = row
        ui.selectedKey = item.item.selectionKey or item.item.key
        ui.selectedItemID = item.item.isGrouped and -1 or (item.item.itemID or -1)
        ui.lastSelectedIndex = row
        ui.btnAction:setEnable(true)
        ui.btnAction:setTitle(ui:getActionButtonTitle(item.item))

        if ui.isBuying then
            ui.btnLock:setVisible(false)
            ui.btnAction:setEnable(item.item.qty > 0)
        else
            local sellQty = tonumber(item.item.qty) or 1
            if ui.btnAsk then
                ui.btnAsk:setVisible(true)
            end

            local isLocked = item.item.isLocked == true
            if sellQty > 1 then
                ui.btnLock:setTitle(T("DTCommon_UI_Trading_LockItem", nil, "LOCK ITEM"))
                ui.btnLock:setEnable(false)
                ui.btnLock:setVisible(false)
                ui.btnAction:setEnable(true)
            elseif isLocked then
                ui.btnLock:setTitle(T("DTCommon_UI_Trading_UnlockItem", nil, "UNLOCK ITEM"))
                ui.btnLock:setVisible(true)
                ui.btnLock:setEnable(true)
                ui.btnAction:setEnable(false)
            else
                ui.btnLock:setTitle(T("DTCommon_UI_Trading_LockItem", nil, "LOCK ITEM"))
                ui.btnLock:setVisible(true)
                ui.btnLock:setEnable(true)
                ui.btnAction:setEnable(true)
            end
        end

        if ui.tradeRequestPending and ui.btnAction then
            ui.btnAction:setEnable(false)
            ui.btnAction:setTitle(T("DTCommon_UI_Trading_Processing", nil, "PROCESSING..."))
        end
    end

    self:addChild(self.listbox)
    self:relayout()
end

function DT_TradingWindow:relayout()
    local th = self:titleBarHeight()
    local leftColW = getLeftColumnWidth(self)
    local centerX = getColumnCenterX(self)
    local rightX = leftColW + 20
    local rightW = self.width - rightX - RIGHT_MARGIN

    self.imageY = th + PADDING
    self.imageW = leftColW
    self.imageH = leftColW

    if self.portraitPanel then
        self.portraitPanel:setPortraitBounds(PADDING, self.imageY, self.imageW, self.imageH)
    end

    if self.lblName then
        self.lblName:setX(centerX)
    end
    if self.lblArchetype then
        self.lblArchetype:setX(centerX)
    end
    if self.lblSignal then
        self.lblSignal:setX(centerX)
    end
    if self.lblTraderBudget then
        self.lblTraderBudget:setX(centerX)
    end
    if self.lblInfo then
        self.lblInfo:setX(centerX)
    end

    local nextY = self.imageY + self.imageH + PADDING
    if self.lblName then self.lblName:setY(nextY) end
    if self.lblArchetype then self.lblArchetype:setY(nextY + 25) end
    if self.lblSignal then self.lblSignal:setY(nextY + 45) end
    if self.lblTraderBudget then self.lblTraderBudget:setY(nextY + 70) end
    if self.lblInfo then self.lblInfo:setY(nextY + 95) end

    local buttonBaseY = nextY + 130
    if self.btnAsk then
        self.btnAsk:setX(20)
        self.btnAsk:setWidth(leftColW - 20)
        self.btnAsk:setY(buttonBaseY)
    end
    if self.btnLock then
        self.btnLock:setX(20)
        self.btnLock:setWidth(leftColW - 20)
        self.btnLock:setY(buttonBaseY + 30)
    end
    if self.btnAction then
        self.btnAction:setX(20)
        self.btnAction:setWidth(leftColW - 20)
        self.btnAction:setY(buttonBaseY + 60)
    end

    local logY = buttonBaseY + 100
    if self.chatList then
        self.chatList:setX(PADDING)
        self.chatList:setWidth(leftColW)
        self.chatList:setY(logY)
        self.chatList:setHeight(self.height - logY - PADDING)
        if self.chatList.vscroll then
            self.chatList.vscroll:setHeight(self.chatList:getHeight())
        end
    end

    local visibleTabs = {}
    if self.btnTabBuy and self.btnTabBuy:isVisible() then
        table.insert(visibleTabs, self.btnTabBuy)
    end
    if self.btnTabSell and self.btnTabSell:isVisible() then
        table.insert(visibleTabs, self.btnTabSell)
    end

    if #visibleTabs == 0 and self.btnTabBuy then
        self.btnTabBuy:setVisible(true)
        table.insert(visibleTabs, self.btnTabBuy)
    end

    local tabW = rightW / math.max(1, #visibleTabs)
    for index, button in ipairs(visibleTabs) do
        button:setX(rightX + ((index - 1) * tabW))
        button:setY(th + PADDING)
        button:setWidth(tabW)
    end

    if self.listbox then
        self.listbox:setX(rightX)
        self.listbox:setWidth(rightW)
        self.listbox:setHeight(self.height - (th + 55))
        if self.listbox.vscroll then
            self.listbox.vscroll:setHeight(self.listbox:getHeight())
        end
    end
end

function DT_TradingWindow:onResize()
    ISCollapsableWindow.onResize(self)
    self:relayout()

    local trader = self:getCurrentTrader()
    if trader then
        self:refreshPortraitWithTrader(trader, true)
    end
end

function DT_TradingWindow:render()
    ISCollapsableWindow.render(self)

    if self.traderID and #self.msgQueue > 0 then
        local nextMsg = self.msgQueue[1]
        if (not nextMsg.isPlayer) and (nextMsg.delay > 0) then
            local frame = math.floor(self.typingTick / 10) % 4
            local dots = ""
            if frame == 1 then
                dots = "."
            elseif frame == 2 then
                dots = ".."
            elseif frame == 3 then
                dots = "..."
            end

            local bubbleX = self.chatList:getX() + 5
            local bubbleY = self.chatList:getY() + self.chatList:getHeight() - 25
            self:drawRect(bubbleX, bubbleY, 40, 20, 0.9, 0.2, 0.2, 0.2)
            self:drawRectBorder(bubbleX, bubbleY, 40, 20, 0.5, 0.5, 0.5, 0.5)
            self:drawText(dots, bubbleX + 12, bubbleY + 2, 0.8, 0.8, 0.8, 1, self.chatList.font)
        end
    end
end

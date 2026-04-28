-- =============================================================================
-- CLASS DEFINITION
-- =============================================================================
DT_TradingWindow = DT_TradingWindow or ISCollapsableWindow:derive("DT_TradingWindow")
DT_TradingWindow.instance = nil

function DT_TradingWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 600
    self.minimumHeight = 650
    self.isBuying = true
    self.transactionKind = "buy"
    self.sessionContext = nil
    self.selectedKey = nil
    self.radioObj = nil
    self.collapsed = {}
    self.lastSelectedIndex = -1
    self.localLogs = {}
    self.dataProvider = nil -- INJECTED ON CREATION

    -- ==========================================================
    -- LOGIC STATE TRACKERS
    -- ==========================================================
    self.idleTimer = 0
    self.updateTick = 0

    -- Prevent FPS drops by limiting inventory scanning frequency.
    self.inventoryDirty = false
    self.refreshCooldown = 0

    self.lastHour = -1
    self.wasRaining = false
    self.wasFoggy = false

    -- Structure: { text="", isError=false, isPlayer=false, delay=0, sound=nil }
    self.msgQueue = {}
    self.typingTick = 0
end

function DT_TradingWindow:getTradeSessionContext()
    if self.sessionContext ~= nil then
        return self.sessionContext
    end

    if self.dataProvider and self.dataProvider.getTradeSessionContext then
        self.sessionContext = self.dataProvider:getTradeSessionContext(self.traderID, self.archetype)
    end

    return self.sessionContext
end

function DT_TradingWindow:getTransactionKind()
    local sessionContext = self:getTradeSessionContext()
    local transactionKind = sessionContext and sessionContext.transactionKind or nil
    if transactionKind == "gift" then
        return "gift"
    end

    return self.isBuying and "buy" or "sell"
end

function DT_TradingWindow:isGiftMode()
    return self:getTransactionKind() == "gift"
end

function DT_TradingWindow:getDefaultActionTitle()
    if self.isBuying then
        return "BUY ITEM"
    end

    if self:isGiftMode() then
        return "GIFT ITEM"
    end

    return "SELL ITEM"
end

function DT_TradingWindow:getModeTabTitle(isBuying)
    if isBuying then
        return "BUY FROM TRADER"
    end

    if self:isGiftMode() then
        return "GIFT TO NPC"
    end

    return "SELL TO TRADER"
end

function DT_TradingWindow:getActionButtonTitle(data)
    if not data then
        return self:getDefaultActionTitle()
    end

    local price = tonumber(data.price) or 0
    if self.isBuying then
        return "BUY ($" .. tostring(price) .. ")"
    end

    local qty = tonumber(data.qty) or 1
    if self:isGiftMode() then
        if qty > 1 then
            return "GIFT x" .. tostring(qty) .. " (Value $" .. tostring(price) .. " EA)"
        end
        return "GIFT (Value $" .. tostring(price) .. ")"
    end

    if qty > 1 then
        return "SELL x" .. tostring(qty) .. " ($" .. tostring(price) .. " EA)"
    end
    return "SELL ($" .. tostring(price) .. ")"
end

function DT_TradingWindow:refreshTradeLabels()
    if self.btnTabBuy then
        self.btnTabBuy:setTitle(self:getModeTabTitle(true))
    end

    if self.btnTabSell then
        self.btnTabSell:setTitle(self:getModeTabTitle(false))
    end

    if self.btnAction and (not self.listbox or self.listbox.selected == -1) then
        self.btnAction:setTitle(self:getDefaultActionTitle())
    end
end

function DT_TradingWindow:resetIdleTimer()
    self.idleTimer = 0
end

function DT_TradingWindow:queueMessage(text, isError, isPlayer, delay, soundName, tag)
    if tag then
        for _, msg in ipairs(self.msgQueue) do
            if msg.tag == tag then
                msg.delay = 0
            end
        end
    end

    table.insert(self.msgQueue, {
        text = text,
        isError = isError or false,
        isPlayer = isPlayer or false,
        delay = delay or 0,
        sound = soundName,
        tag = tag
    })
end

function DT_TradingWindow:getCurrentTrader()
    if not self.dataProvider or not self.traderID or not self.dataProvider.getTrader then
        return nil
    end

    return self.dataProvider:getTrader(self.traderID, self.archetype)
end

function DT_TradingWindow:getTradeModeConfig(trader)
    if self.dataProvider and self.dataProvider.getTradeModeConfig then
        return self.dataProvider:getTradeModeConfig(trader or self:getCurrentTrader())
    end

    return { canBuy = true, canSell = true, defaultIsBuying = true }
end

function DT_TradingWindow:isTradeModeEnabled(isBuying, trader)
    local config = self:getTradeModeConfig(trader)
    return isBuying and config.canBuy or config.canSell
end

function DT_TradingWindow:syncTradeModeVisibility(trader)
    local config = self:getTradeModeConfig(trader)

    if self.btnTabBuy then
        self.btnTabBuy:setVisible(config.canBuy)
    end

    if self.btnTabSell then
        self.btnTabSell:setVisible(config.canSell)
    end

    self:refreshTradeLabels()

    return config
end

function DT_TradingWindow:coerceTradeMode(trader)
    local config = self:syncTradeModeVisibility(trader)
    if not self:isTradeModeEnabled(self.isBuying, trader) then
        self.isBuying = config.defaultIsBuying ~= false
    end

    return config
end

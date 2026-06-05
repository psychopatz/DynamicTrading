local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

function DT_TradingWindow:setTradingMode(isBuying)
    local trader = self:getCurrentTrader()
    self:coerceTradeMode(trader)

    if not self:isTradeModeEnabled(isBuying, trader) then
        return
    end

    if self.isBuying == isBuying then
        if self.relayout then self:relayout() end
        return
    end
    if self.resetIdleTimer then self:resetIdleTimer() end

    self.isBuying = isBuying
    self.selectedKey = nil
    self.selectedItemID = -1
    self.lastSelectedIndex = -1
    self.sellScanSession = nil
    self.sellScanListDirty = false

    if self.btnTabBuy and self.btnTabSell then
        if self.isBuying then
            self.btnTabBuy.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1.0}
            self.btnTabSell.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
        else
            self.btnTabBuy.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
            self.btnTabSell.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1.0}
        end
    end

    if self.refreshTradeLabels then
        self:refreshTradeLabels()
    end

    if self.btnAsk then
        local config = self.dataProvider:getAskButtonConfig(self.isBuying)
        if config then
            self.btnAsk:setTitle(config.title or T("DTCommon_UI_Trading_Talk", nil, "Talk"))
            self.btnAsk:setVisible(config.visible ~= false)
            self.btnAsk:setEnable(true)
        else
            self.btnAsk:setVisible(false)
        end
    end

    if self.btnLock then
        self.btnLock:setVisible(self.dataProvider:getLockButtonVisible(self.isBuying))
    end

    if self.relayout then
        self:relayout()
    end
    self:populateList()
    self.btnAction:setEnable(false)
    self.btnAction:setTitle(self:getDefaultActionTitle())
end

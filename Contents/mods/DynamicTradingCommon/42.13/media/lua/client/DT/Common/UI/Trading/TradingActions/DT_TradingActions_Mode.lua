function DT_TradingWindow:setTradingMode(isBuying)
    if self.isBuying == isBuying then return end
    if self.resetIdleTimer then self:resetIdleTimer() end

    self.isBuying = isBuying
    self.selectedKey = nil
    self.selectedItemID = -1
    self.lastSelectedIndex = -1

    if not isBuying then
        self.inventoryDirty = true
        self.refreshCooldown = 0
    end

    if self.btnTabBuy and self.btnTabSell then
        if self.isBuying then
            self.btnTabBuy.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1.0}
            self.btnTabSell.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
        else
            self.btnTabBuy.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
            self.btnTabSell.backgroundColor = {r=0.2, g=0.5, b=0.2, a=1.0}
        end
    end

    if self.btnAsk then
        local config = self.dataProvider:getAskButtonConfig(self.isBuying)
        if config then
            self.btnAsk:setTitle(config.title or "Talk")
            self.btnAsk:setVisible(config.visible ~= false)
            self.btnAsk:setEnable(true)
        else
            self.btnAsk:setVisible(false)
        end
    end

    if self.btnLock then
        self.btnLock:setVisible(self.dataProvider:getLockButtonVisible(self.isBuying))
    end

    self:populateList()
    self.btnAction:setEnable(false)
end

function DT_TradingWindow:onAsk()
    if self.resetIdleTimer then self:resetIdleTimer() end

    local trader = self.dataProvider:getTrader(self.traderID, self.archetype)
    if not trader then return end

    self.dataProvider:onAsk(trader, self.isBuying, self)
end

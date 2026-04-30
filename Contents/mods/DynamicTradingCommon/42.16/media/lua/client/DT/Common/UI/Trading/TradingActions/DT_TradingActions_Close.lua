function DT_TradingWindow:close()
    local closingTraderID = self.traderID

    if DT_ConversationUI and DT_ConversationUI.instance then
        if DT_ConversationUI.instance.parentUI == self then
            DT_ConversationUI.instance:close()
        end
    end

    if self.onCloseCallback then
        local success, err = pcall(self.onCloseCallback, self)
        if not success and DynamicTrading and DynamicTrading.Log then
            DynamicTrading.Log("DTV2", "Trade", "Error", "Trading close callback failed: " .. tostring(err))
        end
    end

    if DT_ConfigManager and DT_ConfigManager.setWindowState then
        DT_ConfigManager.setWindowState("TradingWindow", self:getX(), self:getY(), self:getWidth(), self:getHeight())
    end

    if DT_TradingWindowWrapper_State then
        DT_TradingWindowWrapper_State.currentTraderID = nil
        DT_TradingWindowWrapper_State.lastStockVersion = nil
    end

    if DynamicTrading_Client and DynamicTrading_Client.EndTradeView and closingTraderID then
        DynamicTrading_Client.EndTradeView(closingTraderID)
    end

    self:setVisible(false)
    self:removeFromUIManager()
    DT_TradingWindow.instance = nil
end

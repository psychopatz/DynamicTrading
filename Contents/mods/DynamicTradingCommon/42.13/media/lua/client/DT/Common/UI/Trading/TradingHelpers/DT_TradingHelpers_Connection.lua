-- =============================================================================
-- CONNECTION & POWER VALIDATION
-- =============================================================================

function DT_TradingWindow:isConnectionValid()
    return self.dataProvider:isConnectionValid(self.radioObj)
end

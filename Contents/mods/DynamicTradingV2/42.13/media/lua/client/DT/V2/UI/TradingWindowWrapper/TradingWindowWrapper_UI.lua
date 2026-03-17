-- =============================================================================
-- TradingWindowWrapper_UI.lua
-- UI-facing configuration methods for the trading provider.
-- =============================================================================

require "DT/Common/UI/Trading/DT_Trading_ProviderCore"

V2_DataProvider = V2_DataProvider or {}

DynamicTrading.TradingProvider.AttachCore(V2_DataProvider)

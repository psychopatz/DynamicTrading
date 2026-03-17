-- =============================================================================
-- DYNAMIC TRADING V1: RADIO TRADING WRAPPER - PRICING
-- =============================================================================
-- Economy and price calculation logic, delegated to Common Economy.
-- =============================================================================

require "DT/Common/UI/Trading/DT_Trading_ProviderPricing"

V1_RadioTradingWrapper_Pricing_logic = {}

DynamicTrading.TradingProvider.AttachPricing(V1_Radio_DataProvider)

DynamicTrading.Log("DTV1", "Init", "Pricing", "V1 Radio Trading Pricing Logic Loaded")

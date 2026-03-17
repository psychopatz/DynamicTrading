-- =============================================================================
-- TradingWindowWrapper_Pricing.lua
-- Server-authoritative buy/sell pricing for the trading provider.
-- =============================================================================

require "DT/Common/UI/Trading/DT_Trading_ProviderPricing"

V2_DataProvider = V2_DataProvider or {}

DynamicTrading.TradingProvider.AttachPricing(V2_DataProvider)

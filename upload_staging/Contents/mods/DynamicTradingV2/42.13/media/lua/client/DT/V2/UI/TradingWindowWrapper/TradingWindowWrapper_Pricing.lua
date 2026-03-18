-- =============================================================================
-- TradingWindowWrapper_Pricing.lua
-- Server-authoritative buy/sell pricing for the trading provider.
-- =============================================================================

require "DT/Common/UI/Trading/Provider/DT_TradingProvider_Pricing"

V2_DataProvider = V2_DataProvider or {}

DynamicTrading.TradingProvider.AttachPricing(V2_DataProvider)

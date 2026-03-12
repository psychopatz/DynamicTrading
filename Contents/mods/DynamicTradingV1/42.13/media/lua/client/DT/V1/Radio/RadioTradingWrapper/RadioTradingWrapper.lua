-- =============================================================================
-- DYNAMIC TRADING V1: RADIO TRADING WINDOW WRAPPER
-- =============================================================================
-- Entry point for the V1 modular Radio Trading Wrapper.
-- Provides V1_Radio_DataProvider for DT_TradingWindow integration.
-- =============================================================================

require "DT/Common/UI/Trading/DT_TradingWindow"
require "DT/Common/Config"
require "Utils/DT_CoreUtils"
require "DT/Common/Utils/DT_AudioManager"
require "DT/Common/Trading/DT_Economy_Common"

-- Require submodules in correct order
require "DT/V1/Radio/RadioTradingWrapper/RadioTradingWrapper_Core"
require "DT/V1/Radio/RadioTradingWrapper/RadioTradingWrapper_Polling"
require "DT/V1/Radio/RadioTradingWrapper/RadioTradingWrapper_TraderData"
require "DT/V1/Radio/RadioTradingWrapper/RadioTradingWrapper_Dialogue"
require "DT/V1/Radio/RadioTradingWrapper/RadioTradingWrapper_Pricing"
require "DT/V1/Radio/RadioTradingWrapper/RadioTradingWrapper_Utils"

DynamicTrading.Log("DTV1", "Init", "System", "V1 Modular Radio Trading Wrapper loaded successfully")

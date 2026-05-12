if not DT_TradingItemUtils then DT_TradingItemUtils = {} end
DT_TradingItemUtils.Internal = DT_TradingItemUtils.Internal or {}

require "DT/Common/Trading/EconomyCommon/DT_EconomyCommon"
require "Utils/DT_CoreUtils"

-- Keep explicit load order so dependent helpers are registered before scanners.
require "DT/Common/UI/Trading/TradingItemUtils/DT_TradingItemUtils_Fluids"
require "DT/Common/UI/Trading/TradingItemUtils/DT_TradingItemUtils_Display"
require "DT/Common/UI/Trading/TradingItemUtils/DT_TradingItemUtils_Price"
require "DT/Common/UI/Trading/TradingItemUtils/DT_TradingItemUtils_ItemSearch"
require "DT/Common/UI/Trading/TradingSellScan/DT_TradingSellScan"
require "DT/Common/UI/Trading/TradingItemUtils/DT_TradingItemUtils_BuyScan"

return DT_TradingItemUtils

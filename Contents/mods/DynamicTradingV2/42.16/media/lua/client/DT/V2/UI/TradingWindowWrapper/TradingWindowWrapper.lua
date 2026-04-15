-- =============================================================================
-- DYNAMIC TRADING V2: TRADING WINDOW WRAPPER
-- =============================================================================
-- Entry point for the V2 trading window wrapper modules.
-- =============================================================================

require "DT/Common/UI/Trading/DT_Trading"
require "DT/Common/Config"
require "Utils/DT_CoreUtils"
require "DT/Common/Reputation/DT_Reputation"
require "DT/V2/Dialog/DT_DialogueManager"
require "DT/V2/NPC/ClientSync/DTNPC_ClientSync"
require "DT/Common/Utils/DT_AudioManager"
require "DT/Common/Trading/DT_Economy_Common"

V2_DataProvider = V2_DataProvider or {}

-- Shared mutable state that was previously file-local in the monolithic wrapper.
DT_TradingWindowWrapper_State = DT_TradingWindowWrapper_State or {
    lastStockVersion = nil,
    currentTraderID = nil
}

-- Keep explicit load order to preserve behavior and dependencies.
require "DT/V2/UI/TradingWindowWrapper/TradingWindowWrapper_Core"
require "DT/V2/UI/TradingWindowWrapper/TradingWindowWrapper_Polling"
require "DT/V2/UI/TradingWindowWrapper/TradingWindowWrapper_TraderData"
require "DT/V2/UI/TradingWindowWrapper/TradingWindowWrapper_Dialogue"
require "DT/V2/UI/TradingWindowWrapper/TradingWindowWrapper_Pricing"
require "DT/V2/UI/TradingWindowWrapper/TradingWindowWrapper_UI"
require "DT/V2/UI/TradingWindowWrapper/TradingWindowWrapper_Actions"

DynamicTrading.Log("DTV2", "Init", "System", "V2 Trading Window Wrapper loaded successfully")

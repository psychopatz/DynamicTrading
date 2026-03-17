-- =============================================================================
-- DYNAMIC TRADING V1: RADIO TRADING WRAPPER - DIALOGUE
-- =============================================================================
-- Delegates dialogue generation to the Common Trading Provider helper.
-- =============================================================================

require "DT/Common/UI/Trading/DT_TradingProvider_Dialogue"

V1_RadioTradingWrapper_Dialogue_logic = {}

DynamicTrading.TradingProvider.AttachDialogue(V1_Radio_DataProvider)

DynamicTrading.Log("DTV1", "Init", "Dialogue", "V1 Radio Trading Dialogue Logic Loaded")

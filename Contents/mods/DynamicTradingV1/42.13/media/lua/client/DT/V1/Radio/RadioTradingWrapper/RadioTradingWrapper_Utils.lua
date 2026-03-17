-- =============================================================================
-- DYNAMIC TRADING V1: RADIO TRADING WRAPPER - UTILS
-- =============================================================================
-- Utility functions for audio, connection validation, and window toggling.
-- =============================================================================

require "DT/Common/UI/Trading/DT_Trading_ProviderCore"

V1_RadioTradingWrapper_Utils_logic = {}

function V1_Radio_DataProvider:getMasterKey(fullType)
    return DynamicTrading.Utils.GetMasterKey(fullType)
end

function V1_Radio_DataProvider:openHub(trader, parentUI)
    if parentUI then parentUI:close() end
    if DT_V1_Dialogue_Hub then
        DT_V1_Dialogue_Hub.Init(nil, self.radioObj, trader.traderID, getSpecificPlayer(0))
    end
end

function V1_Radio_DataProvider:isConnectionValid(radioObj)
    -- [OPTIMIZATION]
    -- 1. Check if we have a radio obj.
    if not radioObj then
        return self.radioObj ~= nil
    end

    -- 2. VISIBILITY CHECK (The "Kill Switch")
    if DT_TradingWindow and DT_TradingWindow.instance then
        if not DT_TradingWindow.instance:getIsVisible() then
            return false
        end
    end

    -- 3. DISTANCE CHECK
    -- Delegate to core util, which handles nil objects safely by returning true
    return DynamicTrading.Utils.IsInteractionValid(radioObj, nil, nil)
end

-- =============================================================================
-- TOGGLE WINDOW HELPER
-- =============================================================================
function V1_Radio_DataProvider.Open(traderID, archetype, radioObj)
    DynamicTrading.Log("DTV1", "UI", "Open", "Opening Radio Trading Window for " .. tostring(traderID))
    V1_Radio_DataProvider._currentTraderID = traderID
    V1_Radio_DataProvider.radioObj = radioObj
    DT_TradingWindow.ToggleWindow(traderID, archetype, radioObj, V1_Radio_DataProvider)
end

DynamicTrading.TradingProvider.AttachCore(V1_Radio_DataProvider)

DynamicTrading.Log("DTV1", "Init", "Utils", "V1 Radio Trading Utility Logic Loaded")

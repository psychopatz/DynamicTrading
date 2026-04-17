DynamicTrading = DynamicTrading or {}
DynamicTrading.NetworkLogs = DynamicTrading.NetworkLogs or {}

local RADIO_LOGS_KEY = "DynamicTrading_Logs_v1.0"

-- =============================================================================
-- NETWORK LOGS MANAGER (V1 WRAPPER)
-- =============================================================================

function DynamicTrading.NetworkLogs.AddRadioLog(text, category)
    -- Check for shared module availability
    if DynamicTrading.NetworkLogManager and DynamicTrading.NetworkLogManager.Append then
        DynamicTrading.NetworkLogManager.Append(RADIO_LOGS_KEY, text, category)
    else
        -- Fallback: If shared module isn't loaded (e.g. strict load order issues),
        -- try to load it.
        require("DT/Common/DT_NetworkLogManager")
        if DynamicTrading.NetworkLogManager and DynamicTrading.NetworkLogManager.Append then
            DynamicTrading.NetworkLogManager.Append(RADIO_LOGS_KEY, text, category)
        else
            DynamicTrading.Log("DTV1", "Network", "Error", "Shared DT_NetworkLogManager module missing.")
        end
    end
end

function DynamicTrading.NetworkLogs.AddLog(text, category)
    DynamicTrading.NetworkLogs.AddRadioLog(text, category)
end

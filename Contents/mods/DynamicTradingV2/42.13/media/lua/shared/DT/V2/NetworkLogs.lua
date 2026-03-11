DynamicTrading = DynamicTrading or {}
DynamicTrading.NetworkLogs = DynamicTrading.NetworkLogs or {}

-- Key for isolated storage V2
local LOGS_KEY = "DynamicTrading_Logs_v2.0"

-- =============================================================================
-- NETWORK LOGS MANAGER (V2 WRAPPER)
-- =============================================================================

-- V2-Specific Wrapper
function DynamicTrading.NetworkLogs.AddLogV2(text, category)
    -- Check for shared module availability
    if DynamicTrading.NetworkLogManager and DynamicTrading.NetworkLogManager.Append then
        DynamicTrading.NetworkLogManager.Append(LOGS_KEY, text, category)
    else
        -- Fallback
        require("DT/Common/DT_NetworkLogManager")
        if DynamicTrading.NetworkLogManager and DynamicTrading.NetworkLogManager.Append then
            DynamicTrading.NetworkLogManager.Append(LOGS_KEY, text, category)
        else
             DynamicTrading.Log("DTV2", "Network", "Error", "Shared DT_NetworkLogManager module missing.")
        end
    end
end

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
    if DynamicTrading.NetworkLogs.Append then
        DynamicTrading.NetworkLogs.Append(LOGS_KEY, text, category)
    else
        -- Fallback
        require("DT/Common/NetworkLogs")
        if DynamicTrading.NetworkLogs.Append then
            DynamicTrading.NetworkLogs.Append(LOGS_KEY, text, category)
        else
             print("[DynamicTrading] Error: Shared NetworkLogs module missing.")
        end
    end
end

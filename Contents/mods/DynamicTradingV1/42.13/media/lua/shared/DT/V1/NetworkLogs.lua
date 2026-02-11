DynamicTrading = DynamicTrading or {}
DynamicTrading.NetworkLogs = DynamicTrading.NetworkLogs or {}

-- Key for isolated storage
local LOGS_KEY = "DynamicTrading_Logs_v1.0"

-- =============================================================================
-- NETWORK LOGS MANAGER (V1 WRAPPER)
-- =============================================================================

function DynamicTrading.NetworkLogs.AddLog(text, category)
    -- Check for shared module availability
    if DynamicTrading.NetworkLogManager and DynamicTrading.NetworkLogManager.Append then
        DynamicTrading.NetworkLogManager.Append(LOGS_KEY, text, category)
    else
        -- Fallback: If shared module isn't loaded (e.g. strict load order issues),
        -- try to load it.
        require("DT/Common/DT_NetworkLogManager")
        if DynamicTrading.NetworkLogManager and DynamicTrading.NetworkLogManager.Append then
            DynamicTrading.NetworkLogManager.Append(LOGS_KEY, text, category)
        else
            print("[DynamicTrading] Error: Shared DT_NetworkLogManager module missing.")
        end
    end
end

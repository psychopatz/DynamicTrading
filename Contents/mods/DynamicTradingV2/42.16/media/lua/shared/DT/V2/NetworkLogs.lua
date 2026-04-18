DynamicTrading = DynamicTrading or {}
DynamicTrading.NetworkLogs = DynamicTrading.NetworkLogs or {}

local RADIO_LOGS_KEY = "DynamicTrading_Logs_v1.0"

-- =============================================================================
-- NETWORK LOGS MANAGER (V2 WRAPPER)
-- =============================================================================

function DynamicTrading.NetworkLogs.AddRadioLog(text, category)
    -- Check for shared module availability
    if DynamicTrading.NetworkLogManager and DynamicTrading.NetworkLogManager.Append then
        DynamicTrading.NetworkLogManager.Append(RADIO_LOGS_KEY, text, category)
    else
        -- Fallback
        require("DT/Common/DT_NetworkLogManager")
        if DynamicTrading.NetworkLogManager and DynamicTrading.NetworkLogManager.Append then
            DynamicTrading.NetworkLogManager.Append(RADIO_LOGS_KEY, text, category)
        else
             DynamicTrading.Log("DTV2", "Network", "Error", "Shared DT_NetworkLogManager module missing.")
        end
    end
end

function DynamicTrading.NetworkLogs.AddLogV2(text, category)
    DynamicTrading.NetworkLogs.AddRadioLog(text, category)
end

-- Register Network/Radio Enums
if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.RegisterTemplate then
    DynamicTrading.GameplayLogs.SIGNAL_ACQUIRED = 101
    DynamicTrading.GameplayLogs.SIGNAL_RELEASED = 102
    DynamicTrading.GameplayLogs.SIGNAL_MEMORY_FULL = 103

    DynamicTrading.GameplayLogs.RegisterTemplate(101, "Signal Acquired by {1}: {2} ({3})", "good")
    DynamicTrading.GameplayLogs.RegisterTemplate(102, "Signal Released: {1} ({2})", "event")
    DynamicTrading.GameplayLogs.RegisterTemplate(103, "Signal Memory Full: all locked channels occupied", "bad")
end

function DynamicTrading.NetworkLogs.AddRadioEvent(eventType, dataArray)
    if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.QueueAndFlush then
        DynamicTrading.GameplayLogs.QueueAndFlush("Radio", "Global", eventType, dataArray)
    else
        DynamicTrading.Log("DTV2", "Network", "Error", "Shared DT_GameplayLogs module missing.")
    end
end

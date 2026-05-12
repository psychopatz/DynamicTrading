DynamicTrading = DynamicTrading or {}

---@class DT_GameplayLogs
DynamicTrading.GameplayLogs = DynamicTrading.GameplayLogs or {}
DynamicTrading.Logging = DynamicTrading.Logging or {}
DynamicTrading.GameplayLogDefinitions = DynamicTrading.GameplayLogDefinitions or {}
DynamicTrading.Logging.Registry = DynamicTrading.GameplayLogDefinitions

local Logs = DynamicTrading.GameplayLogs

local context = {
    Logs = Logs,
    DEFAULT_LANG = "EN",
    GLOBAL_TARGET_ID = "Global",
    STORAGE_KEYS = {
        Factions = "DynamicTrading_GameplayLogs_Factions",
        Radio = "DynamicTrading_GameplayLogs_Radio"
    },
    STORAGE_PREFIX = "DynamicTrading_GameplayLogs_",
    pendingLogs = {},
    pendingLocalLogs = {}
}

function context.warnLogIssue(message)
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "GameplayLogs", "Warn", tostring(message))
    end
end

function context.validateEventType(eventType, source)
    if eventType then
        return true
    end

    context.warnLogIssue((source or "GameplayLogs") .. " received a nil event ID")
    return false
end

function context.getChannelTargetList(logData, targetID)
    if targetID == context.GLOBAL_TARGET_ID then
        logData.list = logData.list or {}
        return logData.list, function(combined)
            logData.list = combined
        end
    end

    logData[targetID] = logData[targetID] or {}
    return logData[targetID], function(combined)
        logData[targetID] = combined
    end
end

function context.notifyLogUpdated(key)
    if triggerEvent then
        triggerEvent("OnDynamicTradingLogsUpdated", key)
    end
end

function context.getTimestamp()
    local month = getGameTime():getMonth() + 1
    local day = getGameTime():getDay() + 1
    local hour = getGameTime():getHour()
    local minute = getGameTime():getMinutes()
    return string.format("%02d/%02d %02d:%02d ", month, day, hour, minute)
end

function context.getMaxEvents()
    local maxCount = 30
    if SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.MaxGameplayLogs then
        maxCount = SandboxVars.DynamicTrading.MaxGameplayLogs
    end
    return maxCount
end

function Logs.GetStorageKey(channelType)
    local channelName = tostring(channelType or "")
    return context.STORAGE_KEYS[channelName] or (context.STORAGE_PREFIX .. channelName)
end

function Logs.GetLocalStorageKey(channelType, username)
    local channelName = tostring(channelType or "")
    local user = tostring(username or "Unknown")
    return context.STORAGE_PREFIX .. "Local_" .. user .. "_" .. channelName
end

function Logs.IsGameplayLogKey(key)
    local value = tostring(key or "")
    return string.sub(value, 1, string.len(context.STORAGE_PREFIX)) == context.STORAGE_PREFIX
end

return context

DynamicTrading = DynamicTrading or {}
DynamicTrading.NetworkLogManager = DynamicTrading.NetworkLogManager or {}

-- =============================================================================
-- SHARED NETWORK LOG MANAGER
-- =============================================================================

-- Main function to add logs. 
-- @param key: The unique ModData key for this log instance (e.g., "DynamicTrading_Logs_v1.0")
-- @param text: The log message
-- @param category: The category (e.g., "info", "trade", "error")
function DynamicTrading.NetworkLogManager.Append(key, text, category)
    if not key then return end

    local data = ModData.getOrCreate(key)
    
    -- Initialize if new
    if not data.list then data.list = {} end

    local gt = GameTime:getInstance()
    local timeStr = string.format("%02d/%02d %02d:%02d", gt:getDay()+1, gt:getMonth()+1, gt:getHour(), gt:getMinutes())
    
    table.insert(data.list, 1, { text = text, cat = category or "info", time = timeStr })
    
    -- Determine Max Logs from Sandbox or Default
    local maxLogs = 50
    if SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.MaxLogs then
        maxLogs = SandboxVars.DynamicTrading.MaxLogs
    end
    
    -- Keep only last N entries
    while #data.list > maxLogs do 
        table.remove(data.list) 
    end
    
    if isServer() or not isClient() then 
        ModData.transmit(key) 
    end
end

-- =============================================================================
-- CLIENT SYNC
-- =============================================================================
local function OnReceiveLogs(key, data)
    -- Verify the key starts with DynamicTrading_Logs to allow multiple versions
    if key and string.find(key, "DynamicTrading_Logs") then
       -- If we have a local UI that needs refreshing, it reads from ModData directly via getOrCreate
       -- so we just accept the data here.
       ModData.add(key, data)
       
       -- Trigger UI Refresh if window is open (Generic Hook)
       triggerEvent("OnDynamicTradingLogsUpdated", key)
    end
end
Events.OnReceiveGlobalModData.Add(OnReceiveLogs)

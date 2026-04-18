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
-- FACTION SPECIFIC EVENTS (Integrated with Faction Intelligence)
-- =============================================================================

function DynamicTrading.NetworkLogManager.AddFactionEvent(factionID, text, category)
    if not factionID then return end
    
    local factions = ModData.get("DynamicTrading_Factions")
    if not factions or not factions[factionID] then return end
    
    local faction = factions[factionID]
    if not faction.news then faction.news = {} end
    
    local gt = GameTime:getInstance()
    local timeStr = string.format("%02d/%02d %02d:%02d", gt:getDay()+1, gt:getMonth()+1, gt:getHour(), gt:getMinutes())
    
    -- Insert at top
    table.insert(faction.news, 1, { text = text, cat = category or "info", time = timeStr })
    
    -- Limit to 30 entries for bandwidth efficiency
    while #faction.news > 30 do
        table.remove(faction.news)
    end
    
    -- Transmit updated faction data if on server (or singleplayer)
    if isServer() or not isClient() then
        ModData.transmit("DynamicTrading_Factions")
        -- Signal UI update locally (not strictly needed as ModData.transmit handles it, but good for local)
        triggerEvent("OnDynamicTradingFactionNewsUpdated", factionID)
    end
end

-- =============================================================================
-- CLIENT SYNC
-- =============================================================================
local function OnReceiveLogs(key, data)
    -- Verify the key starts with DynamicTrading_Logs to allow multiple versions
    if key and string.find(key, "DynamicTrading_Logs") and type(data) == "table" then
       -- If we have a local UI that needs refreshing, it reads from ModData directly via getOrCreate
       -- so we just accept the data here.
       ModData.add(key, data)
       
       -- Trigger UI Refresh if window is open (Generic Hook)
       triggerEvent("OnDynamicTradingLogsUpdated", key)
    end
end
Events.OnReceiveGlobalModData.Add(OnReceiveLogs)

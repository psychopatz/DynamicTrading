DynamicTrading = DynamicTrading or {}
DynamicTrading.NetworkLogs = {}

-- Key for isolated storage
local LOGS_KEY = "DynamicTrading_Logs_v1.0"

-- =============================================================================
-- NETWORK LOGS MANAGER
-- =============================================================================

function DynamicTrading.NetworkLogs.AddLog(text, category)
    local data = ModData.getOrCreate(LOGS_KEY)
    
    -- Initialize if new
    if not data.list then data.list = {} end

    local gt = GameTime:getInstance()
    local timeStr = string.format("%02d/%02d %02d:%02d", gt:getDay()+1, gt:getMonth()+1, gt:getHour(), gt:getMinutes())
    
    table.insert(data.list, 1, { text = text, cat = category or "info", time = timeStr })
    
    -- Keep only last 12 entries
    while #data.list > 12 do 
        table.remove(data.list) 
    end
    
    if isServer() or not isClient() then 
        ModData.transmit(LOGS_KEY) 
    end
end

-- =============================================================================
-- CLIENT SYNC
-- =============================================================================
local function OnReceiveLogs(key, data)
    if key == LOGS_KEY then
       -- If we have a local UI that needs refreshing, it reads from ModData directly via getOrCreate
       -- so we just accept the data here.
       ModData.add(key, data)
       
       -- Trigger UI Refresh if window is open
       if DynamicTradingInfoUI and DynamicTradingInfoUI.instance and DynamicTradingInfoUI.instance:isVisible() then
           -- Ideally call a refresh method, but the UI likely polls ModData in render/prerender.
       end
    end
end
Events.OnReceiveGlobalModData.Add(OnReceiveLogs)

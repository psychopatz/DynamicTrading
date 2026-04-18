DynamicTrading = DynamicTrading or {}

---@class DT_GameplayLogs
DynamicTrading.GameplayLogs = {}

local Logs = DynamicTrading.GameplayLogs

-- =============================================================================
-- TEMPLATE REGISTRY
-- =============================================================================
Logs.Templates = {}

--- Registers a new template for the logging system
function Logs.RegisterTemplate(id, templateStr, category)
    if not id or not templateStr then return end
    Logs.Templates[id] = { tpl = templateStr, cat = category or "event" }
end

--- Resolves a serialized log entry into human-readable text and category
function Logs.ResolveText(entry)
    if not entry then return "", "event" end
    -- Backward compatibility for old format events (V1 string text)
    if entry.text then return entry.text, entry.cat or "event" end
    
    local templateData = Logs.Templates[entry.e]
    if not templateData then return "Unknown Event", "event" end
    
    local text = templateData.tpl
    local data = entry.d or {}
    
    for i=1, #data do
        text = string.gsub(text, "{"..i.."}", tostring(data[i]))
    end
    
    return text, templateData.cat
end

-- =============================================================================
-- LOGGING PIPELINE (CHANNELS)
-- =============================================================================

-- In-memory queue: pendingLogs[channelType][targetID] = { entries }
local pendingLogs = {}

local function getTimestamp()
    local month = getGameTime():getMonth() + 1
    local day = getGameTime():getDay() + 1
    local hour = getGameTime():getHour()
    local minute = getGameTime():getMinutes()
    return string.format("%02d/%02d %02d:%02d ", month, day, hour, minute)
end

local function getMaxEvents()
    local maxCount = 30
    if SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.MaxGameplayLogs then
        maxCount = SandboxVars.DynamicTrading.MaxGameplayLogs
    end
    return maxCount
end

--- Queues a log event in memory for a specific channel and target ID
-- @param channelType String: The grouping channel (e.g. "Factions", "Radio")
-- @param targetID String: The specific ID within the channel (e.g. "uuid123", "Global")
function Logs.Queue(channelType, targetID, eventType, dataArray)
    if not channelType or not targetID or not eventType then return end
    
    pendingLogs[channelType] = pendingLogs[channelType] or {}
    pendingLogs[channelType][targetID] = pendingLogs[channelType][targetID] or {}
    
    table.insert(pendingLogs[channelType][targetID], {
        t = getTimestamp(),
        e = eventType,
        d = dataArray
    })
end

--- Flushes all queued logs for a specific channel to ModData and transmits
function Logs.FlushChannel(channelType)
    if not channelType or not pendingLogs[channelType] then return end
    
    local hasChanges = false
    local modDataKey = "DynamicTrading_Logs_" .. channelType
    local logData = ModData.getOrCreate(modDataKey)
    local maxCount = getMaxEvents()
    
    for targetID, pendingBatch in pairs(pendingLogs[channelType]) do
        if #pendingBatch > 0 then
            hasChanges = true
            logData[targetID] = logData[targetID] or {}
            local list = logData[targetID]
            
            -- Keep old entries if within limit
            local keepCount = math.max(0, maxCount - #pendingBatch)
            
            -- Shift old array to fit new
            local combined = {}
            -- Prepend new items
            for i = #pendingBatch, 1, -1 do
                table.insert(combined, pendingBatch[i])
            end
            -- Add back old items
            for i = 1, math.min(#list, keepCount) do
                table.insert(combined, list[i])
            end
            
            logData[targetID] = combined
        end
    end
    
    if hasChanges then
        ModData.transmit(modDataKey)
        pendingLogs[channelType] = {}
    end
end

--- Flushes all active channels
function Logs.FlushAll()
    for channelType, _ in pairs(pendingLogs) do
        Logs.FlushChannel(channelType)
    end
end

--- Queues a log and immediately flushes its channel (useful for immediate, low-frequency logging)
function Logs.QueueAndFlush(channelType, targetID, eventType, dataArray)
    Logs.Queue(channelType, targetID, eventType, dataArray)
    Logs.FlushChannel(channelType)
end

return Logs

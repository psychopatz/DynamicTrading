DynamicTrading = DynamicTrading or {}

---@class DT_GameplayLogs
DynamicTrading.GameplayLogs = {}
local Logs = {}
DynamicTrading.GameplayLogs = Logs
DynamicTrading.Logging = DynamicTrading.Logging or {}
DynamicTrading.Logging.Registry = {}

local DEFAULT_LANG = "EN"

--- Registers a log template following Dialogue-style I18N patterns.
-- @param eventID Number
-- @param data Table { EN = "...", PH = "...", ... }
-- @param category String (Default: "event")
function DynamicTrading.RegisterLogTemplate(eventID, data, category)
    if not eventID or not data then return end
    
    DynamicTrading.Logging.Registry[eventID] = DynamicTrading.Logging.Registry[eventID] or {}
    local reg = DynamicTrading.Logging.Registry[eventID]
    
    reg.cat = category or reg.cat or "event"
    reg.tpl = reg.tpl or {}
    
    for lang, str in pairs(data) do
        reg.tpl[lang] = str
    end
end

-- Agnostic dispatch hooks
function Logs.AddEvent(channel, eventID, dataArray)
    Logs.QueueAndFlush(channel, "Global", eventID, dataArray)
end

function Logs.AddLocalEvent(playerObj, channel, eventID, dataArray)
    local username = playerObj and playerObj:getUsername() or "Unknown"
    Logs.QueueAndFlushLocal(channel, username, eventID, dataArray)
end

--- Resolves an entry into a human-readable string and category
function Logs.ResolveText(entry)
    if not entry or not entry.e then return "Invalid Entry", "event" end
    
    local reg = DynamicTrading.Logging.Registry[entry.e]
    if not reg or not reg.tpl then return "Unknown Event (" .. tostring(entry.e) .. ")", "event" end
    
    local lang = DynamicTrading.GetLanguage and DynamicTrading.GetLanguage() or DEFAULT_LANG
    local text = reg.tpl[lang] or reg.tpl[DEFAULT_LANG] or reg.tpl["EN"] or "Missing Translation (" .. tostring(entry.e) .. ")"
    
    local data = entry.d or {}
    for i=1, #data do
        text = string.gsub(text, "{"..i.."}", tostring(data[i]))
    end
    
    return text, reg.cat
end

-- =============================================================================
-- LOGGING PIPELINE (CHANNELS)
-- =============================================================================

-- In-memory queue: pendingLogs[channelType][targetID] = { entries }
local pendingLogs = {}
local pendingLocalLogs = {}

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

function Logs.QueueAndFlush(channelType, targetID, eventType, dataArray)
    Logs.Queue(channelType, targetID, eventType, dataArray)
    Logs.FlushChannel(channelType)
end

--- Queues a local log event (per-player, no broadcast transmit)
function Logs.QueueLocal(channelType, username, eventType, dataArray)
    if not channelType or not username or not eventType then return end
    
    pendingLocalLogs[channelType] = pendingLocalLogs[channelType] or {}
    pendingLocalLogs[channelType][username] = pendingLocalLogs[channelType][username] or {}
    
    table.insert(pendingLocalLogs[channelType][username], {
        t = getTimestamp(),
        e = eventType,
        d = dataArray
    })
end

--- Flushes all pending local logs for a channel. Does NOT transmit to avoid global broadcast.
-- To persist on the client or send from server to specifically one client, use a targeted network command.
function Logs.FlushLocal(channelType)
    if not channelType or not pendingLocalLogs[channelType] then return end
    
    local hasChanges = false
    local maxCount = getMaxEvents()
    
    for username, pendingBatch in pairs(pendingLocalLogs[channelType]) do
        if #pendingBatch > 0 then
            hasChanges = true
            local modDataKey = "DynamicTrading_LocalLogs_" .. username .. "_" .. channelType
            local logData = ModData.getOrCreate(modDataKey)
            
            -- Keep old entries if within limit
            local list = logData.list or {}
            local keepCount = math.max(0, maxCount - #pendingBatch)
            
            local combined = {}
            for i = #pendingBatch, 1, -1 do
                table.insert(combined, pendingBatch[i])
            end
            for i = 1, math.min(#list, keepCount) do
                table.insert(combined, list[i])
            end
            
            logData.list = combined
            
            -- If we are on the server, we need to send this data specifically to 'username'
            if isServer() then
                local playerObj = getPlayerFromUsername(username)
                if playerObj then
                    sendServerCommand(playerObj, "DTLogs", "SyncLocal", { key = modDataKey, data = logData })
                end
            end
        end
    end
    
    if hasChanges then
        pendingLocalLogs[channelType] = {}
    end
end

function Logs.QueueAndFlushLocal(channelType, username, eventType, dataArray)
    Logs.QueueLocal(channelType, username, eventType, dataArray)
    Logs.FlushLocal(channelType)
end

-- Hook for Client to receive local logs
if isClient() then
    local function OnServerCommand(module, command, args)
        if module == "DTLogs" and command == "SyncLocal" then
            if args.key and args.data then
                local logData = ModData.getOrCreate(args.key)
                logData.list = args.data.list
                -- trigger update on UI
                triggerEvent("OnDynamicTradingLogsUpdated", args.key)
            end
        end
    end
    Events.OnServerCommand.Add(OnServerCommand)
end

return Logs

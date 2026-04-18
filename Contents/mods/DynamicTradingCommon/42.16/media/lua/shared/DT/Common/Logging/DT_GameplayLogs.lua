DynamicTrading = DynamicTrading or {}

---@class DT_GameplayLogs
DynamicTrading.GameplayLogs = DynamicTrading.GameplayLogs or {}
local Logs = DynamicTrading.GameplayLogs
DynamicTrading.Logging = DynamicTrading.Logging or {}
DynamicTrading.GameplayLogDefinitions = DynamicTrading.GameplayLogDefinitions or {}
DynamicTrading.Logging.Registry = DynamicTrading.GameplayLogDefinitions

local DEFAULT_LANG = "EN"
local GLOBAL_TARGET_ID = "Global"
local STORAGE_KEYS = {
    Factions = "DynamicTrading_GameplayLogs_Factions",
    Radio = "DynamicTrading_GameplayLogs_Radio"
}
local STORAGE_PREFIX = "DynamicTrading_GameplayLogs_"

local function mergeNestedTables(target, source)
    if type(target) ~= "table" or type(source) ~= "table" then
        return source
    end

    for key, value in pairs(source) do
        local existing = target[key]
        if type(existing) == "table" and type(value) == "table" and not existing[1] and not value[1] then
            mergeNestedTables(existing, value)
        else
            target[key] = value
        end
    end

    return target
end

local function warnLogIssue(message)
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "GameplayLogs", "Warn", tostring(message))
    end
end

local function getLogDefinition(eventID)
    return DynamicTrading.GameplayLogDefinitions[tostring(eventID or "")]
end

local function getEntryData(entry)
    local data = entry and (entry.tokens or entry.p or entry.d)
    if type(data) == "table" then
        return data
    end
    return {}
end

local function getTemplateForLanguage(definition)
    local templates = definition and definition.tpl or nil
    if type(templates) ~= "table" then
        return nil
    end

    local lang = DynamicTrading.GetLanguage and DynamicTrading.GetLanguage() or DEFAULT_LANG
    return templates[lang] or templates[DEFAULT_LANG] or templates.EN
end

local function formatEntryText(template, data)
    local text = tostring(template or "")

    if type(data) == "table" and DynamicTrading.FormatInteractionString then
        text = DynamicTrading.FormatInteractionString(text, data)
    end

    if type(data) == "table" then
        for index, value in ipairs(data) do
            text = string.gsub(text, "{" .. tostring(index) .. "}", tostring(value))
        end
    end

    return text
end

local function upsertDefinition(eventID, definition)
    if not eventID or type(definition) ~= "table" then
        return nil
    end

    local key = tostring(eventID)
    local registry = DynamicTrading.GameplayLogDefinitions
    registry[key] = registry[key] or { cat = "event", tpl = {} }

    local target = registry[key]
    if definition.category then
        target.cat = tostring(definition.category)
    end

    local templates = definition.templates or definition.tpl or definition.text or definition.translations
    if type(templates) == "table" then
        mergeNestedTables(target.tpl, templates)
    end

    return target
end

local function validateEventType(eventType, source)
    if eventType then
        return true
    end

    warnLogIssue((source or "GameplayLogs") .. " received a nil event ID")
    return false
end

local function getChannelTargetList(logData, targetID)
    if targetID == GLOBAL_TARGET_ID then
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

local function notifyLogUpdated(key)
    if triggerEvent then
        triggerEvent("OnDynamicTradingLogsUpdated", key)
    end
end

function Logs.GetStorageKey(channelType)
    local channelName = tostring(channelType or "")
    return STORAGE_KEYS[channelName] or ("DynamicTrading_GameplayLogs_" .. channelName)
end

function Logs.GetLocalStorageKey(channelType, username)
    local channelName = tostring(channelType or "")
    local user = tostring(username or "Unknown")
    return STORAGE_PREFIX .. "Local_" .. user .. "_" .. channelName
end

function Logs.IsGameplayLogKey(key)
    local value = tostring(key or "")
    return string.sub(value, 1, string.len(STORAGE_PREFIX)) == STORAGE_PREFIX
end

--- Registers a gameplay-log event definition.
-- @param eventID Number
-- @param definition Table { category = "good", templates = { EN = "..." } }
function DynamicTrading.RegisterGameplayLogEvent(eventID, definition)
    return upsertDefinition(eventID, definition)
end

--- Compatibility wrapper for older template registrations.
-- @param eventID Number
-- @param data Table { EN = "...", PH = "...", ... }
-- @param category String (Default: "event")
function DynamicTrading.RegisterLogTemplate(eventID, data, category)
    if not eventID or type(data) ~= "table" then
        return nil
    end

    return upsertDefinition(eventID, {
        category = category or "event",
        templates = data
    })
end

function Logs.AddEvent(channel, eventID, dataArray)
    if channel == "Factions" then
        warnLogIssue("Deprecated AddEvent('Factions', ...) call detected. Use AddFactionEvent(factionID, eventID, data) instead.")
        return false
    end

    return Logs.AddChannelEvent(channel, eventID, dataArray)
end

function Logs.AddChannelEvent(channelType, eventID, dataArray)
    if not validateEventType(eventID, "AddChannelEvent") then
        return false
    end

    Logs.QueueAndFlush(channelType, GLOBAL_TARGET_ID, eventID, dataArray)
    return true
end

function Logs.AddFactionEvent(factionID, eventID, dataArray)
    if not factionID or tostring(factionID) == "" then
        warnLogIssue("AddFactionEvent received an invalid faction ID")
        return false
    end

    if DynamicTrading.Log then
        DynamicTrading.Log("DTLogs", "Gameplay", "Write", "AddFactionEvent called | Faction: " .. tostring(factionID) .. " | Event: " .. tostring(eventID) .. " | Context: " .. (isServer() and "Server" or (isClient() and "Client" or "SinglePlayer")))
    end

    if not validateEventType(eventID, "AddFactionEvent") then
        return false
    end

    Logs.QueueAndFlush("Factions", tostring(factionID), eventID, dataArray)
    return true
end

function Logs.AddRadioEvent(eventID, dataArray)
    if DynamicTrading.Log then
        DynamicTrading.Log("DTLogs", "Gameplay", "Write", "AddRadioEvent called | Event: " .. tostring(eventID) .. " | Context: " .. (isServer() and "Server" or (isClient() and "Client" or "SinglePlayer")))
    end
    return Logs.AddChannelEvent("Radio", eventID, dataArray)
end

function Logs.AddPlayerRadioEvent(playerObj, eventID, dataArray)
    if not validateEventType(eventID, "AddPlayerRadioEvent") then
        return false
    end

    local username = playerObj and playerObj:getUsername() or nil
    if not username or username == "" then
        warnLogIssue("AddPlayerRadioEvent could not resolve a username")
        return false
    end

    if DynamicTrading.Log then
        DynamicTrading.Log("DTLogs", "Gameplay", "Write", "AddPlayerRadioEvent called | User: " .. tostring(username) .. " | Event: " .. tostring(eventID) .. " | Context: " .. (isServer() and "Server" or (isClient() and "Client" or "SinglePlayer")))
    end

    Logs.QueueAndFlushLocal("Radio", username, eventID, dataArray)
    return true
end

function Logs.AddLocalEvent(playerObj, channel, eventID, dataArray)
    if channel == "Radio" then
        return Logs.AddPlayerRadioEvent(playerObj, eventID, dataArray)
    end
    if not validateEventType(eventID, "AddLocalEvent") then
        return false
    end

    local username = playerObj and playerObj:getUsername() or nil
    if not username or username == "" then
        warnLogIssue("AddLocalEvent could not resolve a username")
        return false
    end

    Logs.QueueAndFlushLocal(channel, username, eventID, dataArray)
    return true
end

--- Resolves an entry into a human-readable string and category
function Logs.ResolveText(entry)
    if not entry or not entry.e then return "Invalid Entry", "event" end

    local definition = getLogDefinition(entry.e)
    if not definition then
        return "Unknown Event (" .. tostring(entry.e) .. ")", "event"
    end

    local template = getTemplateForLanguage(definition)
    if not template then
        return "Missing Translation (" .. tostring(entry.e) .. ")", definition.cat or "event"
    end

    return formatEntryText(template, getEntryData(entry)), definition.cat or "event"
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
    if not channelType or not targetID or not validateEventType(eventType, "Queue") then return false end
    
    pendingLogs[channelType] = pendingLogs[channelType] or {}
    pendingLogs[channelType][targetID] = pendingLogs[channelType][targetID] or {}
    
    table.insert(pendingLogs[channelType][targetID], {
        t = getTimestamp(),
        e = eventType,
        d = dataArray
    })

    return true
end

--- Flushes all queued logs for a specific channel to ModData and transmits
function Logs.FlushChannel(channelType)
    if not channelType or not pendingLogs[channelType] then return end
    
    local hasChanges = false
    local modDataKey = Logs.GetStorageKey(channelType)
    local logData = ModData.getOrCreate(modDataKey)
    local maxCount = getMaxEvents()
    
    for targetID, pendingBatch in pairs(pendingLogs[channelType]) do
        if #pendingBatch > 0 then
            hasChanges = true
            local list, assignCombined = getChannelTargetList(logData, targetID)
            
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
            
            assignCombined(combined)
        end
    end
    
    if hasChanges then
        ModData.transmit(modDataKey)
        if not isClient() then
            notifyLogUpdated(modDataKey)
        end
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
    if not Logs.Queue(channelType, targetID, eventType, dataArray) then
        return false
    end
    Logs.FlushChannel(channelType)
    return true
end

--- Queues a local log event (per-player, no broadcast transmit)
function Logs.QueueLocal(channelType, username, eventType, dataArray)
    if not channelType or not username or not validateEventType(eventType, "QueueLocal") then return false end
    
    pendingLocalLogs[channelType] = pendingLocalLogs[channelType] or {}
    pendingLocalLogs[channelType][username] = pendingLocalLogs[channelType][username] or {}
    
    table.insert(pendingLocalLogs[channelType][username], {
        t = getTimestamp(),
        e = eventType,
        d = dataArray
    })

    return true
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
            local modDataKey = Logs.GetLocalStorageKey(channelType, username)
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
            else
                notifyLogUpdated(modDataKey)
            end
        end
    end
    
    if hasChanges then
        pendingLocalLogs[channelType] = {}
    end
end

function Logs.QueueAndFlushLocal(channelType, username, eventType, dataArray)
    if not Logs.QueueLocal(channelType, username, eventType, dataArray) then
        return false
    end
    Logs.FlushLocal(channelType)
    return true
end

-- Hook for Client to receive local logs
if isClient() then
    local function OnReceiveGlobalModData(key, data)
        if not Logs.IsGameplayLogKey(key) or type(data) ~= "table" then
            return
        end

        ModData.add(key, data)
        triggerEvent("OnDynamicTradingLogsUpdated", key)
    end

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
    Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)
    Events.OnServerCommand.Add(OnServerCommand)
end

return Logs

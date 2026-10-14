DTCommon = DTCommon or {}

local Audit = DTCommon.TradeAudit or {}
DTCommon.TradeAudit = Audit

local SETTING_ID = "DTCommon.TradeAudit"
local MAX_ENTRIES = 128
local MAX_PRINTS = 96
local MAX_STAGES = 16
local MAX_FIELDS = 16
local MAX_STRING = 160

Audit.SETTING_ID = SETTING_ID
Audit.Enabled = Audit.Enabled == true
Audit.entries = Audit.entries or {}
Audit.entryCursor = tonumber(Audit.entryCursor) or 0
Audit.entryCount = tonumber(Audit.entryCount) or 0
Audit.revision = tonumber(Audit.revision) or 0
Audit.sequence = tonumber(Audit.sequence) or 0
Audit.printCount = tonumber(Audit.printCount) or 0
Audit.printCapped = Audit.printCapped == true
Audit.counts = Audit.counts or {}
Audit.PerformanceEnabled = Audit.PerformanceEnabled == true
Audit.Profiler = Audit.Profiler

Audit.METRIC_PRICE = "DTCommon.Trade.Price"
Audit.METRIC_QUOTE = "DTCommon.Trade.Quote"
Audit.METRIC_MARKETSENSE_PRICE = "DTCommon.Trade.MarketSensePrice"
Audit.METRIC_SNAPSHOT_ITEMS = "DTCommon.Trade.SnapshotItems"
Audit.METRIC_SNAPSHOT_SELL_ROWS = "DTCommon.Trade.SnapshotSellRows"
Audit.METRIC_SNAPSHOT = "DTCommon.Trade.Snapshot"
Audit.METRIC_EXECUTE_BASKET = "DTCommon.Trade.ExecuteBasket"

local DISABLED_SNAPSHOT = {
    enabled = false,
    reason = "audit_disabled",
}

local function boundedString(value, limit)
    local text = tostring(value or "")
    limit = tonumber(limit) or MAX_STRING
    if #text <= limit then return text end
    return string.sub(text, 1, limit - 3) .. "..."
end

local function number(value)
    value = tonumber(value)
    if value == nil or value ~= value
        or value == math.huge or value == -math.huge
    then
        return nil
    end
    return value
end

local function nowMs()
    if type(getTimeInMillis) ~= "function" then return 0 end
    return tonumber(getTimeInMillis()) or 0
end

local function safeItemValue(item, method)
    local fn = item and item[method]
    local ok
    local value
    if type(fn) ~= "function" then return nil end
    ok, value = pcall(fn, item)
    return ok and value or nil
end

local function copyValue(value, depth, seen)
    local valueType = type(value)
    local output
    local count
    if value == nil then return nil end
    if valueType == "number" or valueType == "boolean" then return value end
    if valueType == "string" then return boundedString(value, MAX_STRING) end
    if valueType ~= "table" then return boundedString(value, 80) end
    if depth >= 3 then return "[depth-limit]" end
    if seen[value] then return "[cycle]" end

    seen[value] = true
    output = {}
    count = 0
    for key, child in pairs(value) do
        count = count + 1
        if count > MAX_FIELDS then
            output.truncated = true
            break
        end
        output[boundedString(key, 80)] = copyValue(child, depth + 1, seen)
    end
    seen[value] = nil
    return output
end

Audit.BoundedString = boundedString
Audit.Number = number
Audit.SafeItemValue = safeItemValue
Audit.CopyValue = copyValue

local function resetCapture()
    Audit.entries = {}
    Audit.entryCursor = 0
    Audit.entryCount = 0
    Audit.revision = Audit.revision + 1
    Audit.sequence = 0
    Audit.printCount = 0
    Audit.printCapped = false
    Audit.counts = {}
end

local function increment(key)
    Audit.counts[key] = (tonumber(Audit.counts[key]) or 0) + 1
end

Audit.Increment = increment

local function push(entry)
    local index
    Audit.entryCursor = Audit.entryCursor + 1
    index = ((Audit.entryCursor - 1) % MAX_ENTRIES) + 1
    Audit.entries[index] = entry
    Audit.entryCount = math.min(MAX_ENTRIES, Audit.entryCount + 1)
    Audit.revision = Audit.revision + 1
end

local function printEntry(event, data)
    local fields
    local function add(name, value)
        if value ~= nil then
            fields[#fields + 1] = name .. "=" .. boundedString(value, 120)
        end
    end
    if type(print) ~= "function" then return end
    if Audit.printCount >= MAX_PRINTS then
        if not Audit.printCapped then
            Audit.printCapped = true
            print("[DT][TRADE_AUDIT] output_capped=true limit="
                .. tostring(MAX_PRINTS))
        end
        return
    end
    Audit.printCount = Audit.printCount + 1
    fields = { "event=" .. boundedString(event, 80) }
    add("fullType", data and data.fullType)
    add("source", data and data.source)
    add("operation", data and data.operation)
    add("status", data and data.status)
    add("reason", data and data.reason)
    add("marketSensePrice", data and data.marketSensePrice)
    add("intrinsicPrice", data and data.intrinsicPrice)
    add("rawQuote", data and data.rawQuote)
    add("unitPrice", data and data.unitPrice)
    add("scanned", data and data.scanned)
    add("accepted", data and data.accepted)
    add("rows", data and data.rows)
    print("[DT][TRADE_AUDIT] " .. table.concat(fields, " "))
end

function Audit.IsEnabled()
    return Audit.Enabled == true
end

function Audit.SetEnabled(enabled)
    enabled = enabled == true
    if Audit.Enabled == enabled then return Audit.Enabled end
    Audit.Enabled = enabled
    resetCapture()
    return Audit.Enabled
end

function Audit.Clear()
    if not Audit.IsEnabled() then return false end
    resetCapture()
    return true
end

function Audit.Record(event, data)
    if not Audit.Enabled then return false end
    Audit.sequence = Audit.sequence + 1
    push({
        id = Audit.sequence,
        timestamp = nowMs(),
        source = "DTCommon",
        event = boundedString(event or "event", 80),
        data = copyValue(data or {}, 0, {}),
    })
    increment("records")
    printEntry(event, data or {})
    return true
end

function Audit.GetSnapshot()
    local recent = {}
    local count
    local start
    local counts
    if not Audit.Enabled then return DISABLED_SNAPSHOT end
    count = Audit.entryCount
    start = Audit.entryCursor - count + 1
    for offset = 0, count - 1 do
        local absolute = start + offset
        local index = ((absolute - 1) % MAX_ENTRIES) + 1
        if Audit.entries[index] then recent[#recent + 1] = Audit.entries[index] end
    end
    counts = {}
    for key, value in pairs(Audit.counts) do counts[key] = value end
    return {
        enabled = true,
        revision = Audit.revision,
        counts = counts,
        recent = recent,
    }
end

function Audit.BeginTimer(name)
    if not Audit.PerformanceEnabled then return nil end
    if not Audit.Profiler or type(Audit.Profiler.IsSectionEnabled) ~= "function"
        or not Audit.Profiler.IsSectionEnabled("performance")
    then
        return nil
    end
    return Audit.Profiler.Begin(name)
end

function Audit.FinishTimer(name, token)
    if not token or not Audit.PerformanceEnabled or not Audit.Profiler then
        return nil
    end
    return Audit.Profiler.Finish(name)
end

local function settingsObject()
    local settings = PsychopatzCore and PsychopatzCore.DebugSettings
    if settings and type(settings.Register) == "function" then return settings end
    if type(require) == "function" then
        pcall(require, "PsychopatzCore/Debug/PsychopatzDebugSettings")
    end
    return PsychopatzCore and PsychopatzCore.DebugSettings or nil
end

local function registerSetting()
    local settings = settingsObject()
    if not settings or type(settings.Register) ~= "function" then return end
    settings.Register({
        id = SETTING_ID,
        source = "Dynamic Trading",
        order = 180,
        title = "Dynamic Trading trade audit",
        description = "Captures bounded MarketSense price math and trade performance traces.",
        defaultEnabled = false,
        runtimeMutable = true,
        apply = function(enabled)
            Audit.SetEnabled(enabled)
        end,
    })
    if type(settings.IsEnabled) == "function" then
        Audit.SetEnabled(settings.IsEnabled(SETTING_ID) == true)
    end
end

registerSetting()

return Audit

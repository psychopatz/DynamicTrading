-- ==============================================================================
-- DTNPC_ProtectShared_Utils.lua
-- Shared utility helpers for DTNPC protect modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal

local function nowMillis()
    if getTimeInMillis then
        return getTimeInMillis()
    end
    return 0
end

local function protectLog(message)
    local line = "[DTNPC Protect] " .. tostring(message or "")
    if DTNPCProtect.CONFIG.ConsoleLogging == true then
        print(line)
    end

    if DynamicTrading and DynamicTrading.Log then
        pcall(function()
            DynamicTrading.Log("DTV2", "NPC", "Protect", tostring(message or ""))
        end)
    elseif DTNPCProtect.CONFIG.ConsoleLogging == true then
        print(line)
    end
end

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function clamp(value, minValue, maxValue)
    local numeric = tonumber(value) or minValue
    if numeric < minValue then
        return minValue
    end
    if numeric > maxValue then
        return maxValue
    end
    return numeric
end

local function getScriptItem(fullType)
    if not fullType or fullType == "" or not getScriptManager then
        return nil
    end

    local manager = getScriptManager()
    if manager and manager.FindItem then
        return manager:FindItem(fullType)
    end

    return nil
end

Internal.nowMillis = nowMillis
Internal.protectLog = protectLog
Internal.lower = lower
Internal.clamp = clamp
Internal.getScriptItem = getScriptItem

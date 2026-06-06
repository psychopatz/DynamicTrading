-- ==============================================================================
-- DT_DebugNetworkAdapter.lua
-- Version-Agnostic Network Command Adapter
-- Handles version detection and routing for debug commands
-- ==============================================================================

DT_DebugNetworkAdapter = DT_DebugNetworkAdapter or {}

-- ==========================================================
-- VERSION DETECTION
-- ==========================================================
local function detectVersion()
    -- Check if V2 is loaded
    if DynamicTrading and DynamicTrading.Version then
        if DynamicTrading.Version == "V2" then
            return "DynamicTradingV2"
        elseif DynamicTrading.Version == "V1" then
            return "DynamicTradingV1"
        end
        return DynamicTrading.Version
    end
    
    -- Check for V2-specific globals
    if DT_V2_Core then
        return "DynamicTradingV2"
    end
    
    -- Check for V1-specific globals
    if DT_V1_Core then
        return "DynamicTradingV1"
    end
    
    -- Default fallback
    return "DynamicTradingV2"
end

-- Cache the detected version
DT_DebugNetworkAdapter.detectedVersion = nil

function DT_DebugNetworkAdapter.getVersion()
    if not DT_DebugNetworkAdapter.detectedVersion then
        DT_DebugNetworkAdapter.detectedVersion = detectVersion()
    end
    return DT_DebugNetworkAdapter.detectedVersion
end

-- ==========================================================
-- MODULE NAME MAPPING
-- ==========================================================
local MODULE_NAMES = {
    DynamicTradingV1 = "DynamicTrading",
    DynamicTradingV2 = "DynamicTrading_V2"
}

function DT_DebugNetworkAdapter.getModuleName()
    local version = DT_DebugNetworkAdapter.getVersion()
    return MODULE_NAMES[version] or MODULE_NAMES.DynamicTradingV2
end

-- ==========================================================
-- COMMAND SENDER
-- ==========================================================
function DT_DebugNetworkAdapter.sendCommand(command, args)
    local moduleName = DT_DebugNetworkAdapter.getModuleName()
    local player = getPlayer()
    
    if not player then
        DynamicTrading.Log("DTCommons", "Debug", "UI", "ERROR: No player found for command: " .. tostring(command))
        return false
    end
    
    sendClientCommand(player, moduleName, command, args or {})
    return true
end

-- ==========================================================
-- SPECIALIZED DEBUG COMMANDS
-- ==========================================================
function DT_DebugNetworkAdapter.sendDebugAction(action, args)
    local payload = args or {}
    payload.action = action
    return DT_DebugNetworkAdapter.sendCommand("DebugCommand", payload)
end

function DT_DebugNetworkAdapter.requestFactionData(args)
    return DT_DebugNetworkAdapter.sendCommand("RequestFactionData", args or {})
end

function DT_DebugNetworkAdapter.requestFactionRoster(factionID, offset, limit)
    return DT_DebugNetworkAdapter.sendCommand("RequestFactionRoster", {
        factionID = factionID,
        offset = offset,
        limit = limit,
    })
end

function DT_DebugNetworkAdapter.generateStock(traderID)
    return DT_DebugNetworkAdapter.sendCommand("GenerateStock", { traderID = traderID })
end

function DT_DebugNetworkAdapter.forceTradeMission(uuid)
    return DT_DebugNetworkAdapter.sendCommand("ForceTradeMission", { uuid = uuid })
end

-- ==========================================================
-- EVENT HANDLER REGISTRATION
-- ==========================================================
function DT_DebugNetworkAdapter.registerServerCommandHandler(callback)
    local moduleName = DT_DebugNetworkAdapter.getModuleName()
    
    Events.OnServerCommand.Add(function(module, command, args)
        if module == moduleName then
            callback(command, args)
        end
    end)
end

DynamicTrading.Log("DTCommons", "Debug", "UI", "Network Adapter Loaded. Detected Version: " .. DT_DebugNetworkAdapter.getVersion())

DynamicTrading = DynamicTrading or {}

-- =============================================================================
-- DYNAMIC TRADING: CENTRALIZED LOGGER
-- =============================================================================
-- Supports standardized formatting: [DTVersion/System/Specific] message
-- Can be expanded to filter by System or Specific tags via mod options.
-- =============================================================================

DynamicTrading.LogConfig = DynamicTrading.LogConfig or {
    Enabled = true,
    -- Add more granular filters here if needed
}

--- Central logging function
--- @param version string: DTCommons, DTV1, or DTV2
--- @param system string: e.g., Factions, Events, NPC, Economy, Core, Network, UI
--- @param specific string: e.g., Initializing, Sync, Error, Debug
--- @param message any: The message to log
function DynamicTrading.Log(version, system, specific, message)
    -- Global enable/disable check
    if not DynamicTrading.LogConfig.Enabled then return end

    local systemTag = tostring(system or "General")
    local specificTag = tostring(specific or "None")

    -- Hide debug-tagged logs unless the debug option is enabled.
    if not DynamicTrading.Debug and (systemTag == "Debug" or specificTag == "Debug") then
        return
    end
    
    -- Future expansion: check SandboxVars for specific system/version toggles
    -- Example: if SandboxVars.DynamicTrading.DebugFactions == false and system == "Factions" then return end

    local formatted = string.format("[%s/%s/%s] %s", 
        tostring(version or "Unknown"), 
        systemTag, 
        specificTag, 
        tostring(message or ""))
        
    print(formatted)
end

-- Generic wrapper for cases where we don't have full context yet
function DynamicTrading.LogQuick(message)
    DynamicTrading.Log("DTCommons", "General", "Quick", message)
end

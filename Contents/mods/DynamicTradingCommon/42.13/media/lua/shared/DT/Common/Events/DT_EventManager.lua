-- =============================================================================
-- DT_EventManager.lua
-- =============================================================================
-- Main Event Manager module - routes to specialized sub-modules.
-- Shared across Dynamic Trading V1 and V2.
-- =============================================================================

-- Generic Global Initialization (Breaks circular dependency with Config.lua)
DynamicTrading = DynamicTrading or {}
DynamicTrading.Events = DynamicTrading.Events or {}
DynamicTrading.Events.Registry = DynamicTrading.Events.Registry or {}
DynamicTrading.Events.ActiveEvents = DynamicTrading.Events.ActiveEvents or {}

if DynamicTrading.Debug then
    print("[DynamicTrading] [Events] [Main] Initializing Event Manager...")
end

-- Load sub-modules in order
require "DT/Common/Events/DT_EventManager_Registry"
require "DT/Common/Events/DT_EventManager_GlobalEvents"
require "DT/Common/Events/DT_EventManager_FactionEvents"

print("[DynamicTrading] [Events] [Main] Event Manager Fully Initialized.")

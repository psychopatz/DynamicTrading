require "DT/Common/Config"
DynamicTrading = DynamicTrading or {}
DynamicTrading.V2 = {}
DynamicTrading.V2.Config = {}


-- =============================================================================
-- FACTION SYSTEM CONFIGURATION (LEGACY ALIAS)
-- =============================================================================
-- Move to Common/Config.lua for V1/V2 parity.
DynamicTrading.V2.Config = DynamicTrading.Config
DynamicTrading.V2.Config.Events = DynamicTrading.Config.FactionEvents

-- Ensure common events are reachable
require "DT/Common/Events/DT_EventManager"
require "DT/Common/Events/Seasonal/Negative/Winter"
-- future: add other base seasonal/flash events here if not auto-loaded

print("DynamicTrading: V2 Config Initialized.")

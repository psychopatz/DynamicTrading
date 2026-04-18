-- =============================================================================
-- DT_EventManager.lua
-- =============================================================================
-- Main Event Manager module - routes to specialized sub-modules.
-- Runtime logic lives in 42.16; shared registries and definitions remain in common.
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.Events = DynamicTrading.Events or {}
DynamicTrading.Events.Registry = DynamicTrading.Events.Registry or {}
DynamicTrading.Events.ActiveEvents = DynamicTrading.Events.ActiveEvents or {}

if DynamicTrading.Debug then
    DynamicTrading.Log("DTCommons", "Events", "Main", "Initializing Event Manager...")
end

require "DT/Common/Events/DT_EventManager_Registry"
require "DT/Common/Events/EventManagerGlobal/DT_EventManagerGlobal"
require "DT/Common/Events/EventManagerFaction/DT_EventManagerFaction"

DynamicTrading.Log("DTCommons", "Events", "Main", "Event Manager Fully Initialized.")
-- =============================================================================
-- DT_EventManagerFaction.lua
-- =============================================================================
-- Faction flash event processing and faction-specific modifier calculations.
-- Entry point for EventManagerFaction modules.
-- =============================================================================

require "DT/Common/Events/EventManagerFaction/DT_EventManagerFaction_Schema"
require "DT/Common/Events/EventManagerFaction/DT_EventManagerFaction_UpdateLogic"
require "DT/Common/Events/EventManagerFaction/DT_EventManagerFaction_Modifiers"

DynamicTrading.Log("DTCommons", "Event", "Logic", "DT_EventManagerFaction Module Loaded.")
-- ==============================================================================
-- Behavior_Departure.lua
-- Entry point for split NPC departure behavior modules.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}
DTNPCLogic.Internal.Departure = DTNPCLogic.Internal.Departure or {}

if DTNPCLogic.Internal.Departure.EntryLoaded then
    return
end

DTNPCLogic.Internal.Departure.EntryLoaded = true

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "DT/V2/NPC/Behaviors/Behavior_AntiStuck"

require "DT/V2/NPC/Behaviors/BehaviorDeparture/Behavior_Departure_Shared"
require "DT/V2/NPC/Behaviors/BehaviorDeparture/Behavior_Departure_Observer"
require "DT/V2/NPC/Behaviors/BehaviorDeparture/Behavior_Departure_Targeting"
require "DT/V2/NPC/Behaviors/BehaviorDeparture/Behavior_Departure_Completion"
require "DT/V2/NPC/Behaviors/BehaviorDeparture/Behavior_Departure_Execute"

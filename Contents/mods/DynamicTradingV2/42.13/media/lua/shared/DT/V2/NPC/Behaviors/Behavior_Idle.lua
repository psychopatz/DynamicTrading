-- ==============================================================================
-- Behavior_Idle.lua
-- Handles the dedicated idle/home state for NPCs.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

DTNPCLogic.Behaviors["Idle"] = function(zombie, npcData)
    DTNPCLogic.Stationary.Run(zombie, npcData)
end

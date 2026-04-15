-- ==============================================================================
-- Behavior_Stay.lua
-- Dedicated passive stay behavior.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

DTNPCLogic.Behaviors["Stay"] = function(zombie, npcData)
    DTNPCLogic.Stationary.Run(zombie, npcData)
end
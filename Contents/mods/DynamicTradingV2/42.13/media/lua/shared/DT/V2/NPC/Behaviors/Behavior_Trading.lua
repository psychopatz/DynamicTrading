-- ==============================================================================
-- Behavior_Trading.lua
-- Handles the live trading state while the NPC is available to interact with.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

DTNPCLogic.Behaviors["Trading"] = function(zombie, npcData)
    DTNPCLogic.Stationary.Run(zombie, npcData)
end

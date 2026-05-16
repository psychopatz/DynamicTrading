-- ==============================================================================
-- Behavior_PlayerZone.lua
-- Dedicated home-zone behavior for player-linked colony residents.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

DTNPCLogic.Behaviors["PlayerZone"] = function(zombie, npcData)
    DTNPCLogic.Stationary.Run(zombie, npcData)
end

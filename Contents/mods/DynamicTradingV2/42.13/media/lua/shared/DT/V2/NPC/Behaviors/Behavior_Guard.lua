-- ==============================================================================
-- Behavior_Guard.lua
-- Handles the logic for the "Stay" or "Guard" command.
-- Build 42 Compatible.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

local function stationaryGuardBehavior(zombie, npcData)
    DTNPCLogic.Stationary.Run(zombie, npcData)
end

DTNPCLogic.Behaviors["Stay"] = stationaryGuardBehavior
DTNPCLogic.Behaviors["Guard"] = stationaryGuardBehavior

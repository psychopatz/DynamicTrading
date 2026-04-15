-- ==============================================================================
-- Behavior_Trading.lua
-- Entry point for trading behavior modules.
-- Loads submodules in explicit order.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.BehaviorTrading = DTNPCLogic.BehaviorTrading or {}

if DTNPCLogic.BehaviorTrading.EntryLoaded then
    return
end

DTNPCLogic.BehaviorTrading.EntryLoaded = true

require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

require "DT/V2/NPC/Behaviors/BehaviorTrading/Behavior_Trading_Shared"
require "DT/V2/NPC/Behaviors/BehaviorTrading/Behavior_Trading_Movement"
require "DT/V2/NPC/Behaviors/BehaviorTrading/Behavior_Trading_State"
require "DT/V2/NPC/Behaviors/BehaviorTrading/Behavior_Trading_Trading"
require "DT/V2/NPC/Behaviors/BehaviorTrading/Behavior_Trading_Ranged"
require "DT/V2/NPC/Behaviors/BehaviorTrading/Behavior_Trading_Melee"

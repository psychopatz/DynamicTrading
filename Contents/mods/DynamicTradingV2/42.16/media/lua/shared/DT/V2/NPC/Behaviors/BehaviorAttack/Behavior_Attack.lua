-- ==============================================================================
-- Behavior_Attack.lua
-- Entry point for hostile melee attack behavior modules.
-- Loads submodules in explicit order.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.BehaviorAttack = DTNPCLogic.BehaviorAttack or {}

local BehaviorAttack = DTNPCLogic.BehaviorAttack

if BehaviorAttack.EntryLoaded then
    return
end

BehaviorAttack.EntryLoaded = true
BehaviorAttack.Modules = BehaviorAttack.Modules or {}
BehaviorAttack.Constants = BehaviorAttack.Constants or {}
BehaviorAttack.Internal = BehaviorAttack.Internal or {}

require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

require "DT/V2/NPC/Behaviors/BehaviorAttack/Behavior_Attack_Shared"
require "DT/V2/NPC/Behaviors/BehaviorAttack/Behavior_Attack_HostileState"
require "DT/V2/NPC/Behaviors/BehaviorAttack/Behavior_Attack_HostileSight"
require "DT/V2/NPC/Behaviors/BehaviorAttack/Behavior_Attack_Legacy"
require "DT/V2/NPC/Behaviors/BehaviorAttack/Behavior_Attack_Movement"
require "DT/V2/NPC/Behaviors/BehaviorAttack/Behavior_Attack_Behavior"

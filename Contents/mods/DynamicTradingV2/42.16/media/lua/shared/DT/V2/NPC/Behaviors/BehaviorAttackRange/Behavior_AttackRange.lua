-- ==============================================================================
-- Behavior_AttackRange.lua
-- Entry point for hostile ranged attack behavior modules.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.BehaviorAttackRange = DTNPCLogic.BehaviorAttackRange or {}

local BehaviorAttackRange = DTNPCLogic.BehaviorAttackRange

if BehaviorAttackRange.EntryLoaded then
    return
end

BehaviorAttackRange.EntryLoaded = true
BehaviorAttackRange.Modules = BehaviorAttackRange.Modules or {}
BehaviorAttackRange.Constants = BehaviorAttackRange.Constants or {}
BehaviorAttackRange.Internal = BehaviorAttackRange.Internal or {}

require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "Misc/DT_LightSystem"
require "DT/V2/Systems/Firearm/DT_FirearmSystem"
require "DT/V2/NPC/Behaviors/BehaviorAttack/Behavior_Attack"

require "DT/V2/NPC/Behaviors/BehaviorAttackRange/Behavior_AttackRange_Shared"
require "DT/V2/NPC/Behaviors/BehaviorAttackRange/Behavior_AttackRange_Animation"
require "DT/V2/NPC/Behaviors/BehaviorAttackRange/Behavior_AttackRange_Targeting"
require "DT/V2/NPC/Behaviors/BehaviorAttackRange/Behavior_AttackRange_Movement"
require "DT/V2/NPC/Behaviors/BehaviorAttackRange/Behavior_AttackRange_Behavior"

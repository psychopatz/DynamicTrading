-- ==============================================================================
-- DTNPC_Logic.lua
-- Entry point for shared NPC logic modules.
-- Loads dependencies and logic submodules in explicit order.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.Stationary = DTNPCLogic.Stationary or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}

if DTNPCLogic.EntryLoaded then
    return
end

DTNPCLogic.EntryLoaded = true

require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "DT/V2/NPC/Sys/Combat/DTNPC_Combat"
require "DT/V2/NPC/Sys/Data/DTNPC_Data"
require "DT/V2/NPC/Sys/Colony/DTNPC_ColonyRuntime"
require "DT/V2/NPC/Sys/Roles/DTNPC_Roles"
require "DT/V2/NPC/Sys/Needs/DTNPC_Needs"

require "DT/V2/NPC/Behaviors/Behavior_GoTo"
require "DT/V2/NPC/Behaviors/BehaviorAttack/Behavior_Attack"
require "DT/V2/NPC/Behaviors/BehaviorAttackRange/Behavior_AttackRange"
require "DT/V2/NPC/Behaviors/Behavior_Flee"
require "DT/V2/NPC/Behaviors/Behavior_Follow"
require "DT/V2/NPC/Behaviors/Behavior_ReturnHome"
require "DT/V2/NPC/Behaviors/Behavior_CorpseCleanup"
require "DT/V2/NPC/Behaviors/Behavior_Protect"
require "DT/V2/NPC/Behaviors/Behavior_Bandage"
require "DT/V2/NPC/Behaviors/Behavior_Stationary"
require "DT/V2/NPC/Behaviors/Behavior_Idle"
require "DT/V2/NPC/Behaviors/Behavior_PlayerZone"
require "DT/V2/NPC/Behaviors/Behavior_ColonyIdle"
require "DT/V2/NPC/Behaviors/Behavior_ColonyCower"
require "DT/V2/NPC/Behaviors/Behavior_ColonyWork"
require "DT/V2/NPC/Behaviors/Behavior_ColonyCorpseRemoval"
require "DT/V2/NPC/Behaviors/Behavior_Patrol"
require "DT/V2/NPC/Behaviors/Behavior_ReviveAlly"
require "DT/V2/NPC/Behaviors/Behavior_Stay"
require "DT/V2/NPC/Behaviors/Behavior_Guard"
require "DT/V2/NPC/Behaviors/BehaviorLootNearby/Behavior_LootNearby"
require "DT/V2/NPC/Behaviors/BehaviorTrading/Behavior_Trading"
require "DT/V2/NPC/Behaviors/BehaviorDeparture/Behavior_Departure"
require "DT/V2/NPC/Behaviors/Behavior_Incapacitated"

require "DT/V2/NPC/Sys/Logic/DTNPC_Logic_Core"
require "DT/V2/NPC/Sys/Logic/DTNPC_Logic_ActivePlayers"
require "DT/V2/NPC/Sys/Logic/DTNPC_Logic_IdleCycle"
require "DT/V2/NPC/Sys/Logic/DTNPC_Logic_Targeting"
require "DT/V2/NPC/Sys/Logic/DTNPC_Logic_Combat"
require "DT/V2/NPC/Sys/Logic/DTNPC_Logic_Anchor"
require "DT/V2/NPC/Sys/Logic/DTNPC_Logic_Processing"
require "DT/V2/NPC/Sys/Logic/DTNPC_Logic_Tick"

-- ==============================================================================
-- Behavior_LootNearby.lua
-- Entry point for split travel companion loot search behavior modules.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}
DTNPCLogic.Internal.LootNearby = DTNPCLogic.Internal.LootNearby or {}
DTNPCLootDebug = DTNPCLootDebug or {}

local LootNearby = DTNPCLogic.Internal.LootNearby

if LootNearby.EntryLoaded then
    return
end

LootNearby.EntryLoaded = true
LootNearby.Modules = LootNearby.Modules or {}
LootNearby.Constants = LootNearby.Constants or {}

require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "DT/V2/NPC/LootSearch/LootSearchShared/DTNPC_LootSearchShared"
require "DT/V2/NPC/Behaviors/Behavior_AntiStuck"

pcall(require, "DC/Common/Colony/ColonyRegistry/DC_ColonyRegistry")
pcall(require, "DC/Common/Colony/ColonyNetwork/DC_ColonyNetwork")

require "DT/V2/NPC/Behaviors/BehaviorLootNearby/Behavior_LootNearby_Shared"
require "DT/V2/NPC/Behaviors/BehaviorLootNearby/Behavior_LootNearby_Debug"
require "DT/V2/NPC/Behaviors/BehaviorLootNearby/Behavior_LootNearby_Combat"
require "DT/V2/NPC/Behaviors/BehaviorLootNearby/Behavior_LootNearby_Movement"
require "DT/V2/NPC/Behaviors/BehaviorLootNearby/Behavior_LootNearby_Behavior"

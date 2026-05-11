-- ==============================================================================
-- DTNPC_LifecycleFinalDeath.lua
-- Entry point for DT NPC final-death lifecycle modules.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/LifecycleFinalDeath/DTNPC_LifecycleFinalDeath_DeathMoney"
require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/LifecycleFinalDeath/DTNPC_LifecycleFinalDeath_IncapacitatedDamage"
require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/LifecycleFinalDeath/DTNPC_LifecycleFinalDeath_Finalize"
require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/LifecycleFinalDeath/DTNPC_LifecycleFinalDeath_Recovery"
require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/LifecycleFinalDeath/DTNPC_LifecycleFinalDeath_ZombieDead"

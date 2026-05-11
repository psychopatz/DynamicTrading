-- ==============================================================================
-- DTNPC_Lifecycle.lua
-- Entry point for DT NPC lifecycle modules.
-- Owns incapacitation, final death, corpse policy, and MP damage authority.
-- ==============================================================================

DTNPCLifecycle = DTNPCLifecycle or {}
DTNPCLifecycle.Internal = DTNPCLifecycle.Internal or {}

if DTNPCLifecycle.EntryLoaded then
    return
end

DTNPCLifecycle.EntryLoaded = true

require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/DTNPC_Lifecycle_Shared"
require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/DTNPC_Lifecycle_DamageAuthority"
require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/DTNPC_Lifecycle_Corpse"
require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/DTNPC_Lifecycle_Incapacitation"
require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/LifecycleFinalDeath/DTNPC_LifecycleFinalDeath"
require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/DTNPC_Lifecycle_Network"
require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle/DTNPC_Lifecycle_Events"

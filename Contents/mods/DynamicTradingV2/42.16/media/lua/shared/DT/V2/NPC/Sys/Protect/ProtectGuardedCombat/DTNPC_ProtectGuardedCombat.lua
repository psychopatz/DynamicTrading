-- ==============================================================================
-- DTNPC_ProtectGuardedCombat.lua
-- Entry point for split DTNPC guarded combat modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

if DTNPCProtect.GuardedCombatEntryLoaded then
    return
end

DTNPCProtect.GuardedCombatEntryLoaded = true

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"
require "Misc/DT_LightSystem"

require "DT/V2/NPC/Sys/Protect/ProtectGuardedCombat/DTNPC_ProtectGuardedCombat_Shared"
require "DT/V2/NPC/Sys/Protect/ProtectGuardedCombat/DTNPC_ProtectGuardedCombat_Control"
require "DT/V2/NPC/Sys/Protect/ProtectGuardedCombat/DTNPC_ProtectGuardedCombat_Companion"
require "DT/V2/NPC/Sys/Protect/ProtectGuardedCombat/DTNPC_ProtectGuardedCombat_Ranged"
require "DT/V2/NPC/Sys/Protect/ProtectGuardedCombat/DTNPC_ProtectGuardedCombat_Melee"

-- ==============================================================================
-- Protect.lua
-- Entry point for DTNPC protect modules.
-- Loads submodules in explicit order.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

if DTNPCProtect.EntryLoaded then
    return
end

DTNPCProtect.EntryLoaded = true

require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectShared_logic"
require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectProfile_logic"
require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectLoadout_logic"
require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectState_logic"
require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectNotice_logic"
require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectTargeting_logic"
require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectDurability_logic"
require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectRangedRuntime_logic"
require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectCombat_logic"
require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectMeleeArbiter_logic"
require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectGuardedCombat_logic"

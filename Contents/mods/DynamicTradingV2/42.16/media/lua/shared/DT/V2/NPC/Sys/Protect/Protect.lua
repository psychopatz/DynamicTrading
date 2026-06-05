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

require "DT/V2/NPC/Sys/Roles/DTNPC_Roles"
require "DT/V2/NPC/Sys/Protect/ProtectShared/DTNPC_ProtectShared"
require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectProfile_logic"
require "DT/V2/NPC/Sys/Protect/ProtectLoadout/DTNPC_ProtectLoadout"
require "DT/V2/NPC/Sys/Protect/ProtectState/DTNPC_ProtectState"
require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectNotice_logic"
require "DT/V2/NPC/Sys/Protect/ProtectTargeting/DTNPC_ProtectTargeting"
require "DT/V2/NPC/Sys/Protect/DTNPC_ProtectDurability_logic"
require "DT/V2/NPC/Sys/Protect/ProtectRangedRuntime/DTNPC_ProtectRangedRuntime"
require "DT/V2/NPC/Sys/Protect/ProtectCombat/DTNPC_ProtectCombat"
require "DT/V2/NPC/Sys/Protect/ProtectMeleeArbiter/DTNPC_ProtectMeleeArbiter"
require "DT/V2/NPC/Sys/Protect/ProtectGuardedCombat/DTNPC_ProtectGuardedCombat"

-- ==============================================================================
-- DTNPC_ProtectMeleeArbiter.lua
-- Entry point for split DTNPC melee arbiter modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

if DTNPCProtect.MeleeArbiterEntryLoaded then
    return
end

DTNPCProtect.MeleeArbiterEntryLoaded = true

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

require "DT/V2/NPC/Sys/Protect/ProtectMeleeArbiter/DTNPC_ProtectMeleeArbiter_Shared"
require "DT/V2/NPC/Sys/Protect/ProtectMeleeArbiter/DTNPC_ProtectMeleeArbiter_State"
require "DT/V2/NPC/Sys/Protect/ProtectMeleeArbiter/DTNPC_ProtectMeleeArbiter_Movement"
require "DT/V2/NPC/Sys/Protect/ProtectMeleeArbiter/DTNPC_ProtectMeleeArbiter_Attack"
require "DT/V2/NPC/Sys/Protect/ProtectMeleeArbiter/DTNPC_ProtectMeleeArbiter_Execute"

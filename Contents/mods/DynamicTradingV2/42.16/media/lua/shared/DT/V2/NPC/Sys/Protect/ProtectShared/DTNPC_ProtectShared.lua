-- ==============================================================================
-- DTNPC_ProtectShared.lua
-- Entry point for split DTNPC protect shared modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

if DTNPCProtect.SharedEntryLoaded then
    return
end

DTNPCProtect.SharedEntryLoaded = true

require "DT/V2/NPC/Sys/Protect/ProtectShared/DTNPC_ProtectShared_Config"
require "DT/V2/NPC/Sys/Protect/ProtectShared/DTNPC_ProtectShared_Utils"
require "DT/V2/NPC/Sys/Protect/ProtectShared/DTNPC_ProtectShared_Loadout"
require "DT/V2/NPC/Sys/Protect/ProtectShared/DTNPC_ProtectShared_Identity"
require "DT/V2/NPC/Sys/Protect/ProtectShared/DTNPC_ProtectShared_Authority"
require "DT/V2/NPC/Sys/Protect/ProtectShared/DTNPC_ProtectShared_CombatState"

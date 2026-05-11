-- ==============================================================================
-- DTNPC_ProtectState.lua
-- Entry point for split DTNPC protect state modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

if DTNPCProtect.StateEntryLoaded then
    return
end

DTNPCProtect.StateEntryLoaded = true

require "DT/V2/NPC/Sys/Protect/ProtectState/DTNPC_ProtectState_Defaults"
require "DT/V2/NPC/Sys/Protect/ProtectState/DTNPC_ProtectState_Anchor"
require "DT/V2/NPC/Sys/Protect/ProtectState/DTNPC_ProtectState_Pursuit"
require "DT/V2/NPC/Sys/Protect/ProtectState/DTNPC_ProtectState_Modes"

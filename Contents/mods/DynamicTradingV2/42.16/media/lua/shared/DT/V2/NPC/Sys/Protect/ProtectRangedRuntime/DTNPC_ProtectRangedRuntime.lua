-- ==============================================================================
-- DTNPC_ProtectRangedRuntime.lua
-- Entry point for split DTNPC ranged runtime modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

if DTNPCProtect.RangedRuntimeEntryLoaded then
    return
end

DTNPCProtect.RangedRuntimeEntryLoaded = true

require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_Combat"
require "DT/Common/FlavorText/DT_FlavorText_Stamina"

require "DT/V2/NPC/Sys/Protect/ProtectRangedRuntime/DTNPC_ProtectRangedRuntime_Flavor"
require "DT/V2/NPC/Sys/Protect/ProtectRangedRuntime/DTNPC_ProtectRangedRuntime_Weapon"
require "DT/V2/NPC/Sys/Protect/ProtectRangedRuntime/DTNPC_ProtectRangedRuntime_Runtime"
require "DT/V2/NPC/Sys/Protect/ProtectRangedRuntime/DTNPC_ProtectRangedRuntime_Reload"

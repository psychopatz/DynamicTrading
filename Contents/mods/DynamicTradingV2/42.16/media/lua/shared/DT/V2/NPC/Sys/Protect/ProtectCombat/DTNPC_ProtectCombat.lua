-- ==============================================================================
-- DTNPC_ProtectCombat.lua
-- Entry point for split DTNPC protect combat modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

if DTNPCProtect.CombatEntryLoaded then
    return
end

DTNPCProtect.CombatEntryLoaded = true

require "Misc/DT_LightSystem"
require "Misc/DT_DamageSystem"
require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_Combat"
require "DT/Common/FlavorText/DT_FlavorText_ProtectCombat"

require "DT/V2/NPC/Sys/Protect/ProtectCombat/DTNPC_ProtectCombat_Pressure"
require "DT/V2/NPC/Sys/Protect/ProtectCombat/DTNPC_ProtectCombat_Rhythm"
require "DT/V2/NPC/Sys/Protect/ProtectCombat/DTNPC_ProtectCombat_Stats"
require "DT/V2/NPC/Sys/Protect/ProtectCombat/DTNPC_ProtectCombat_Danger"
require "DT/V2/NPC/Sys/Protect/ProtectCombat/DTNPC_ProtectCombat_Hit"

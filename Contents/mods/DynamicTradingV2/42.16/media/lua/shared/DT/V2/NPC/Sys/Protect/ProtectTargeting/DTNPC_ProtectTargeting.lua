-- ==============================================================================
-- DTNPC_ProtectTargeting.lua
-- Entry point for split DTNPC protect targeting modules.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

if DTNPCProtect.TargetingEntryLoaded then
    return
end

DTNPCProtect.TargetingEntryLoaded = true

require "DT/V2/mod-patches/bandits/DTModPatches_Bandits"
require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_ProtectTargeting"

require "DT/V2/NPC/Sys/Protect/ProtectTargeting/DTNPC_ProtectTargeting_Cues"
require "DT/V2/NPC/Sys/Protect/ProtectTargeting/DTNPC_ProtectTargeting_Candidates"
require "DT/V2/NPC/Sys/Protect/ProtectTargeting/DTNPC_ProtectTargeting_Relations"
require "DT/V2/NPC/Sys/Protect/ProtectTargeting/DTNPC_ProtectTargeting_LineOfSight"
require "DT/V2/NPC/Sys/Protect/ProtectTargeting/DTNPC_ProtectTargeting_ThreatSelection"
require "DT/V2/NPC/Sys/Protect/ProtectTargeting/DTNPC_ProtectTargeting_ZombieSelection"

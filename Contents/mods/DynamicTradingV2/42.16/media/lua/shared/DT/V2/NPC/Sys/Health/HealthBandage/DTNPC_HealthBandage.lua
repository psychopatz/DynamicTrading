-- ==============================================================================
-- DTNPC_HealthBandage.lua
-- Entry point for split DT NPC health bandage modules.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

if DTNPCHealth.BandageEntryLoaded then
    return
end

DTNPCHealth.BandageEntryLoaded = true

require "DT/V2/NPC/Sys/Health/HealthBandage/DTNPC_HealthBandage_Flow"
require "DT/V2/NPC/Sys/Health/HealthBandage/DTNPC_HealthBandage_Visuals"
require "DT/V2/NPC/Sys/Health/HealthBandage/DTNPC_HealthBandage_Regen"
require "DT/V2/NPC/Sys/Health/HealthBandage/DTNPC_HealthBandage_Action"

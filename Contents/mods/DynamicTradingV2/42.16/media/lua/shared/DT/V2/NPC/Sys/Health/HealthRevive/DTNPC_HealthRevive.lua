-- ==============================================================================
-- DTNPC_HealthRevive.lua
-- Entry point for revive and weakened-state health helpers.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

if DTNPCHealth.ReviveEntryLoaded then
    return
end

DTNPCHealth.ReviveEntryLoaded = true

require "DT/V2/NPC/Sys/Health/HealthRevive/DTNPC_HealthRevive_Core"
require "DT/V2/NPC/Sys/Health/HealthRevive/DTNPC_HealthRevive_Items"
require "DT/V2/NPC/Sys/Health/HealthRevive/DTNPC_HealthRevive_Eligibility"
require "DT/V2/NPC/Sys/Health/HealthRevive/DTNPC_HealthRevive_State"
require "DT/V2/NPC/Sys/Health/HealthRevive/DTNPC_HealthRevive_Allies"

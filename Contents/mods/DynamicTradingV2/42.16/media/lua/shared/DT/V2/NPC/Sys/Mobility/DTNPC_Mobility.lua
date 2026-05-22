-- ==============================================================================
-- DTNPC_Mobility.lua
-- Entry point for shared NPC mobility modules.
-- Loads dependencies and submodules in explicit order.
-- ==============================================================================

require "DT/V2/NPC/Sys/Health/DTNPC_Health"
require "DT/V2/NPC/Sys/Stamina/DTNPC_Stamina"

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility

if Mobility.EntryLoaded then
    return
end

Mobility.EntryLoaded = true
Mobility.Constants = Mobility.Constants or {}
Mobility.Internal = Mobility.Internal or {}

require "DT/V2/NPC/Sys/Mobility/MobilityCommon/DTNPC_MobilityCommon"
require "DT/V2/NPC/Sys/Mobility/DTNPC_MobilityProfiles"
require "DT/V2/NPC/Sys/Mobility/DTNPC_MobilityLocomotion"
require "DT/V2/NPC/Sys/Mobility/MobilityPassages/DTNPC_MobilityPassages"
require "DT/V2/NPC/Sys/Mobility/MobilityNavigation/DTNPC_MobilityNavigation"
require "DT/V2/NPC/Sys/Mobility/DTNPC_MobilityPressure"
require "DT/V2/NPC/Sys/Mobility/DTNPC_MobilitySteering"
require "DT/V2/NPC/Sys/Mobility/MobilityMovement/DTNPC_MobilityMovement"

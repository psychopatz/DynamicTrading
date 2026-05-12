-- ==============================================================================
-- DTNPC_Hostility.lua
-- Loader for DTNPC hostility modules.
-- ==============================================================================

DTNPCHostility = DTNPCHostility or {}
DTNPCHostility.Internal = DTNPCHostility.Internal or {}

require "DT/V2/NPC/Sys/Spatial/DTNPC_SpatialCache"
require "DT/V2/NPC/Sys/Hostility/DTNPC_Hostility_ZombieTargeting"
require "DT/V2/NPC/Sys/Hostility/DTNPC_Hostility_AttackSimulation"
require "DT/V2/NPC/Sys/Hostility/DTNPC_Hostility_Sounds"

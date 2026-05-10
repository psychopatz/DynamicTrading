-- ==============================================================================
-- DTNPC_Data.lua
-- Entry point for NPC data modules.
-- Loads dependencies and data submodules in the required order.
-- ==============================================================================

DTNPC = DTNPC or {}

require "DT/Common/NPC/DT_NPC_Wardrobe"
require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Health/DTNPC_Health"
require "DT/V2/NPC/Sys/Stamina/DTNPC_Stamina"
require "DT/V2/NPC/Sys/EquipmentVisuals/DTNPC_EquipmentVisuals"
require "DT/V2/mod-patches/bandits/DTModPatches_Bandits"

require "DT/V2/NPC/Sys/Data/DTNPC_Data_DataAccess"
require "DT/V2/NPC/Sys/Data/DTNPC_Data_EngineState"
require "DT/V2/NPC/Sys/Data/DTNPC_Data_EquipmentBridge"
require "DT/V2/NPC/Sys/Data/DTNPC_Data_Visuals"
require "DT/V2/NPC/Sys/Data/DTNPC_Data_Events"

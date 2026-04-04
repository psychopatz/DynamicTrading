-- ==============================================================================
-- DTNPC_EquipmentVisuals.lua
-- Entry point for shared NPC equipment visuals.
-- Loads modules in explicit dependency order.
-- ==============================================================================

require "DT/Common/NPC/DT_NPC_Wardrobe"
require "DT/V2/NPC/Sys/DTNPC_Protect"

DTNPCEquipmentVisuals = DTNPCEquipmentVisuals or {}

local EquipmentVisuals = DTNPCEquipmentVisuals

if EquipmentVisuals.EntryLoaded then
    return
end

EquipmentVisuals.EntryLoaded = true
EquipmentVisuals.Constants = EquipmentVisuals.Constants or {}
EquipmentVisuals.Helpers = EquipmentVisuals.Helpers or {}
EquipmentVisuals.Internal = EquipmentVisuals.Internal or {}

require "DT/V2/NPC/Sys/EquipmentVisuals/DTNPC_EquipmentVisuals_Core"
require "DT/V2/NPC/Sys/EquipmentVisuals/DTNPC_EquipmentVisuals_Bag"
require "DT/V2/NPC/Sys/EquipmentVisuals/DTNPC_EquipmentVisuals_Families"
require "DT/V2/NPC/Sys/EquipmentVisuals/DTNPC_EquipmentVisuals_Loadout"
require "DT/V2/NPC/Sys/EquipmentVisuals/DTNPC_EquipmentVisuals_Apply"
require "DT/V2/NPC/Sys/EquipmentVisuals/DTNPC_EquipmentVisuals_Combat"

-- ==============================================================================
-- DTNPC_LootSearchShared.lua
-- Entry point for shared loot search helpers for travel companions.
-- ==============================================================================

DTNPCLootSearch = DTNPCLootSearch or {}

if DTNPCLootSearch.SharedLoaded then
    return
end

DTNPCLootSearch.SharedLoaded = true
DTNPCLootSearch.Internal = DTNPCLootSearch.Internal or {}
DTNPCLootSearch.Modules = DTNPCLootSearch.Modules or {}

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

pcall(require, "DC/Common/Colony/ColonyRegistry/DC_ColonyRegistry")
pcall(require, "DC/Common/Colony/ColonyNetwork/DC_ColonyNetwork")

require "DT/V2/NPC/LootSearch/LootSearchShared/DTNPC_LootSearchShared_Core"
require "DT/V2/NPC/LootSearch/LootSearchShared/DTNPC_LootSearchShared_Colony"
require "DT/V2/NPC/LootSearch/LootSearchShared/DTNPC_LootSearchShared_State"
require "DT/V2/NPC/LootSearch/LootSearchShared/DTNPC_LootSearchShared_Movement"
require "DT/V2/NPC/LootSearch/LootSearchShared/DTNPC_LootSearchShared_Scan"
require "DT/V2/NPC/LootSearch/LootSearchShared/DTNPC_LootSearchShared_Sync"
require "DT/V2/NPC/LootSearch/LootSearchShared/DTNPC_LootSearchShared_Collect"

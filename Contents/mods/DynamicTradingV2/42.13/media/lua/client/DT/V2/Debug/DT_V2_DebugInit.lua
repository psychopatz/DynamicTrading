-- ==============================================================================
-- DT_V2_DebugInit.lua
-- V2-Specific Debug Tool Initialization
-- Loads Common debug tools and sets up V2-specific context
-- ==============================================================================

-- Set version identifier for Network Adapter
if not DynamicTrading then DynamicTrading = {} end
DynamicTrading.Version = "V2"

-- Load Common Debug Tools
require "DT/Common/UI/Debug/Shared/DT_DebugNetworkAdapter"
require "DT/Common/UI/Debug/Shared/DT_NPCLocator"
require "DT/Common/UI/Debug/Factions/AdminManager/DT_FactionDebugMenu"
require "DT/Common/UI/Debug/Merchants/StockManager/DT_MerchantDebugWindow"

print("[DT-V2] Debug Tools Initialized (Version: V2)")
print("[DT-V2] Network Module: " .. DT_DebugNetworkAdapter.getModuleName())
print("[DT-V2] - Faction Debug: Available via context menu")
print("[DT-V2] - Merchant Debug: Available via context menu")
print("[DT-V2] - NPC Locator: Integrated into Faction Debug")

-- =============================================================================
-- DYNAMIC TRADING COMMON: SERVER HELPERS
-- =============================================================================
-- Centralized utility functions for server-side inventory, money, and world
-- interactions. Compatible with Singleplayer, MP Hosted, and MP Dedicated.
--
-- USAGE: require "DT/Common/ServerHelpers/ServerHelpers"
--        DynamicTrading.ServerHelpers.RemoveItem(item)
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.ServerHelpers = {}

-- 1. Base network utilities
require "DT/Common/ServerHelpers/ServerHelpers_NetworkLogic"

-- 2. Inventory methods (Requires Network to determine packet sending)
require "DT/Common/ServerHelpers/ServerHelpers_InventoryLogic"

-- 3. World Interactions (Requires Network)
require "DT/Common/ServerHelpers/ServerHelpers_WorldLogic"

-- 4. Wealth Management (Requires Inventory methods to Add/Remove cash)
require "DT/Common/ServerHelpers/ServerHelpers_WealthLogic"

DynamicTrading.Log("DTCommons", "Init", "Server", "DT/Common/ServerHelpers loaded")

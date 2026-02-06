-- ==========================================================
-- DYNAMIC TRADING: CORE MANIFEST
-- ==========================================================
-- This file ensures all modules load in the correct order.
DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

-- 1. CONFIGURATION & RULES (Shared)
require "DT/Common/Config"
require "DT/Common/Tags"
require "DT/Common/Archetypes"
require "DT/V1/Events"

-- 2. LOGIC ENGINE (Shared)
require "DT/V1/Manager"
require "DT/V1/Economy"
require "DT/V1/NetworkLogs"
require "DT/V1/CooldownManager"
require "DT/V1/PortraitConfig"

-- 3. CLIENT-ONLY SYSTEMS
if isClient() then
    -- INTERACTION SYSTEMS
    require "DT/V1/RadioInteraction"  -- Radio Scanning Logic

    -- USER INTERFACE
    require "DT/V1/UI/DynamicTradingUI"     -- The Shop Window
    require "DT/V1/UI/DynamicTradingInfoUI" -- The Market Info Window
    require "DT/V1/UI/DT_SidebarButton"     -- The Sidebar Button
end

-- 4. ITEM DEFINITIONS (Shared - From Common)
-- Basics & Survival
require "DT/Common/Items/DT_Food"
require "DT/Common/Items/DT_Cooking"
require "DT/Common/Items/DT_Camping"
require "DT/Common/Items/DT_Traps"             
require "DT/Common/Items/DT_AnimalProducts"  
-- Equipment
require "DT/Common/Items/DT_Clothing"
require "DT/Common/Items/DT_Appearance"        
require "DT/Common/Items/DT_Weapons"
require "DT/Common/Items/DT_Ammo"
require "DT/Common/Items/DT_Tools"
-- Medical & Tech
require "DT/Common/Items/DT_Medical"
require "DT/Common/Items/DT_Electronics"
-- Storage & Materials
require "DT/Common/Items/DT_Containers"        
require "DT/Common/Items/DT_ContainersFluid"   
require "DT/Common/Items/DT_Materials"
require "DT/Common/Items/DT_Fuel"             
-- Misc & Loot
require "DT/Common/Items/DT_Junk"
require "DT/Common/Items/DT_Luxury"
require "DT/Common/Items/DT_Household"
require "DT/Common/Items/DT_Literature"
require "DT/Common/Items/DT_Vehicle"

-- 5. TRAITS
-- require "DT/V1/TraitItems"

print("[DynamicTrading] Radio Trading System Fully Loaded.")
-- ==========================================================
-- DYNAMIC TRADING: CORE MANIFEST
-- ==========================================================
-- This file ensures all modules load in the correct order.
DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

-- 1. CONFIGURATION & RULES
require "01_DynamicTrading_Config"
require "01a_DynamicTrading_Tags"
require "DynamicTradingCommon/03_DynamicTrading_Archetypes"
require "02b_DynamicTrading_Events"

-- 2. LOGIC ENGINE
require "02_DynamicTrading_Manager"
require "02a_DynamicTrading_Economy"

-- 3. INTERACTION SYSTEMS
require "DT_RadioInteraction"  -- Radio Scanning Logic

-- 4. USER INTERFACE
require "DynamicTradingUI"     -- The Shop Window
require "DynamicTradingInfoUI" -- The Market Info Window
require "DT_SidebarButton"     -- The Sidebar Button

-- 5. ITEM DEFINITIONS
-- Basics & Survival
require "DynamicTradingCommon/04_DTItems/DT_Food"
require "DynamicTradingCommon/04_DTItems/DT_Cooking"
require "DynamicTradingCommon/04_DTItems/DT_Camping"
require "DynamicTradingCommon/04_DTItems/DT_Traps"             
require "DynamicTradingCommon/04_DTItems/DT_AnimalProducts"  
-- Equipment
require "DynamicTradingCommon/04_DTItems/DT_Clothing"
require "DynamicTradingCommon/04_DTItems/DT_Appearance"        
require "DynamicTradingCommon/04_DTItems/DT_Weapons"
require "DynamicTradingCommon/04_DTItems/DT_Ammo"
require "DynamicTradingCommon/04_DTItems/DT_Tools"
-- Medical & Tech
require "DynamicTradingCommon/04_DTItems/DT_Medical"
require "DynamicTradingCommon/04_DTItems/DT_Electronics"
-- Storage & Materials
require "DynamicTradingCommon/04_DTItems/DT_Containers"        
require "DynamicTradingCommon/04_DTItems/DT_ContainersFluid"   
require "DynamicTradingCommon/04_DTItems/DT_Materials"
require "DynamicTradingCommon/04_DTItems/DT_Fuel"             
-- Misc & Loot
require "DynamicTradingCommon/04_DTItems/DT_Junk"
require "DynamicTradingCommon/04_DTItems/DT_Luxury"
require "DynamicTradingCommon/04_DTItems/DT_Household"
require "DynamicTradingCommon/04_DTItems/DT_Literature"
require "DynamicTradingCommon/04_DTItems/DT_Vehicle"
-- 6. TRAITS

-- require "DT_TraitItems"

print("[DynamicTrading] Radio Trading System Fully Loaded.")
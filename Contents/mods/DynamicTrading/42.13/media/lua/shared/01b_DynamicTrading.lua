-- ==========================================================
-- DYNAMIC TRADING: CORE MANIFEST
-- ==========================================================
-- This file ensures all modules load in the correct order.

-- 1. CONFIGURATION & RULES
require "01_DynamicTrading_Config"
require "01a_DynamicTrading_Tags"
require "03_DynamicTrading_Archetypes"
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
require "04_DTItems/DT_Food"
require "04_DTItems/DT_Cooking"
require "04_DTItems/DT_Camping"
require "04_DTItems/DT_Traps"             
require "04_DTItems/DT_AnimalProducts"  
-- Equipment
require "04_DTItems/DT_Clothing"
require "04_DTItems/DT_Appearance"        
require "04_DTItems/DT_Weapons"
require "04_DTItems/DT_Ammo"
require "04_DTItems/DT_Tools"
-- Medical & Tech
require "04_DTItems/DT_Medical"
require "04_DTItems/DT_Electronics"
-- Storage & Materials
require "04_DTItems/DT_Containers"        
require "04_DTItems/DT_ContainersFluid"   
require "04_DTItems/DT_Materials"
require "04_DTItems/DT_Fuel"             
-- Misc & Loot
require "04_DTItems/DT_Junk"
require "04_DTItems/DT_Luxury"
require "04_DTItems/DT_Household"
require "04_DTItems/DT_Literature"
require "04_DTItems/DT_Vehicle"
-- 6. TRAITS

-- require "DT_TraitItems"

print("[DynamicTrading] Radio Trading System Fully Loaded.")
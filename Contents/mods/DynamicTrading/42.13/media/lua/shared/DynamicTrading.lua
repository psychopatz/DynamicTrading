-- ==========================================================
-- DYNAMIC TRADING: CORE MANIFEST
-- ==========================================================
-- This file ensures all modules load in the correct order.

-- 1. CONFIGURATION & RULES
require "DynamicTrading_Config"
require "DynamicTrading_Tags"
require "DynamicTrading_Archetypes"
require "DynamicTrading_Events"

-- 2. LOGIC ENGINE
require "DynamicTrading_Manager"
require "DynamicTrading_Economy"

-- 3. INTERACTION SYSTEMS
require "DT_RadioInteraction"  -- Radio Scanning Logic

-- 4. USER INTERFACE
require "DynamicTradingUI"     -- The Shop Window
require "DynamicTradingInfoUI" -- The Market Info Window

-- 5. ITEM DEFINITIONS
-- Basics & Survival
require "DTItems/DT_Food"
require "DTItems/DT_Cooking"
require "DTItems/DT_Camping"
require "DTItems/DT_Traps"             
require "DTItems/DT_AnimalProducts"  
-- Equipment
require "DTItems/DT_Clothing"
require "DTItems/DT_Appearance"        
require "DTItems/DT_Weapons"
require "DTItems/DT_Ammo"
require "DTItems/DT_Tools"
-- Medical & Tech
require "DTItems/DT_Medical"
require "DTItems/DT_Electronics"
-- Storage & Materials
require "DTItems/DT_Containers"        
require "DTItems/DT_ContainersFluid"   
require "DTItems/DT_Materials"
require "DTItems/DT_Fuel"             
-- Misc & Loot
require "DTItems/DT_Junk"
require "DTItems/DT_Luxury"
require "DTItems/DT_Household"
require "DTItems/DT_Literature"
require "DTItems/DT_Vehicle"
-- 6. TRAITS

-- require "DT_TraitItems"

print("[DynamicTrading] Radio Trading System Fully Loaded.")
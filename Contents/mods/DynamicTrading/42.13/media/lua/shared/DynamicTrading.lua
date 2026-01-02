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
require "DT_RadioInteraction"  -- [NEW] Radio Scanning Logic

-- 4. USER INTERFACE
require "DynamicTradingUI"     -- The Shop Window
require "DynamicTradingInfoUI" -- The Info/Debug Window
require "DT_Debug"             -- Debug Tool (Press T)

-- 5. ITEM DEFINITIONS
-- (Loads your custom items into the MasterList)
require "DTItems/DT_Food"
require "DTItems/DT_Tools"
require "DTItems/DT_Weapons"
require "DTItems/DT_Medical"
require "DTItems/DT_Materials"
require "DTItems/DT_Junk"
require "DTItems/DT_Household"
require "DTItems/DT_Electronics"
require "DTItems/DT_Clothing"
require "DTItems/DT_Ammo"

print("[DynamicTrading] Radio Trading System Fully Loaded.")
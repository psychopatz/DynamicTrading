-- ==========================================================
-- DYNAMIC TRADING: CORE MANIFEST
-- ==========================================================
-- This file ensures all modules load in the correct order.
DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

-- 1. CONFIGURATION & RULES (Shared)
require "DT/Common/Config"
require "DT/Common/Tags"
require "DT/V1/Events"

-- 2. LOGIC ENGINE (Shared)
require "DT/V1/Manager"
require "DT/V1/Economy"
require "DT/V1/NetworkLogs"
require "DT/V1/CooldownManager"
require "03b_DynamicTrading_PortraitConfig"

-- 3. CLIENT-ONLY SYSTEMS
if isClient() then
    -- INTERACTION SYSTEMS
    require "DT/V1/RadioInteraction"  -- Radio Scanning Logic

    -- USER INTERFACE
    require "DT/V1/UI/DT_TradingWindow_Wrapper"     -- The Shop Window (Wrapper)
    require "DT/V1/DynamicTradingInfoUI"            -- The Market Info Window
    require "DT/V1/UI/DT_SidebarButton"     -- The Sidebar Button
end

-- 4. TRAITS
-- require "DT/V1/TraitItems"

print("[DynamicTrading] Radio Trading System Fully Loaded.")
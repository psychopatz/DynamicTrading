-- ==========================================================
-- DYNAMIC TRADING: CORE MANIFEST
-- ==========================================================
-- This file ensures all modules load in the correct order.
-- V1 and V2 share the same engine/economy/faction system.
-- V1 only differs in interaction method (Radio vs NPC).
DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

if DynamicTrading.Manuals and DynamicTrading.Manuals.MarkAudienceActive then
    DynamicTrading.Manuals.MarkAudienceActive("v1", true)
end

-- 1. CONFIGURATION & RULES (Shared)
require "DT/Common/Config"
require "DT/Common/Tags"

-- 2. SHARED ENGINE & FACTION SYSTEM (Common)
require "DT/Common/Events/DT_EventManager"
require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/Faction/TradingSys/DynamicTrading_Factions"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"
require "DT/Common/Faction/TradingSys/DynamicTrading_Stock"
require "DT/Common/Faction/TradingSys/DynamicTrading_Economy"

-- 3. V1-SPECIFIC LOGIC (Radio Only)
require "DT/V1/Manager"
require "DT/V1/NetworkLogs"
require "DT/V1/CooldownManager"
require "03b_DynamicTrading_PortraitConfig"

-- 4. CLIENT-ONLY SYSTEMS
if isClient() then
    -- INTERACTION SYSTEMS
    require "DT/V1/RadioInteraction"  -- Radio Scanning Logic

    -- USER INTERFACE
    require "DT/V1/Radio/DT_V1_TradingWrapper"      -- Radio Trading Window (Wrapper)
    require "DT/V1/UI/DT_SidebarButton"     -- The Sidebar Button
end

-- 5. TRAITS
-- require "DT/V1/TraitItems"

DynamicTrading.Log("DTV1", "Init", "Manifest", "Radio Trading System Fully Loaded")

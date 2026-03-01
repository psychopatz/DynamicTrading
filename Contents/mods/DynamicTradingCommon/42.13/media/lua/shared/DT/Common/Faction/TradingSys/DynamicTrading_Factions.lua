-- ==============================================================================
-- DynamicTrading_Factions.lua
-- Logic: Facade — loads sub-modules and exposes unified API.
-- Build 42 Compatible.
-- ==============================================================================

-- if isClient() and not isServer() then return end -- Server Side Only (Allow SP & Host)

-- =============================================================================
-- 1. LOAD SUB-MODULES
-- =============================================================================
local Lifecycle   = require "DT/Common/Faction/TradingSys/Factions/Lifecycle"
local Simulation  = require "DT/Common/Faction/TradingSys/Factions/Simulation"
local Interaction = require "DT/Common/Faction/TradingSys/Factions/Interaction"

-- =============================================================================
-- 2. MERGE INTO GLOBAL API
-- =============================================================================
DynamicTrading_Factions = {}

-- Lifecycle
DynamicTrading_Factions.Init              = Lifecycle.Init
DynamicTrading_Factions.RepopulateTowns   = Lifecycle.RepopulateTowns
DynamicTrading_Factions.CreateFaction     = Lifecycle.CreateFaction
DynamicTrading_Factions.GenerateRoster    = Lifecycle.GenerateRoster

-- Simulation
DynamicTrading_Factions.UpdateDaily       = Simulation.UpdateDaily

-- Interaction
DynamicTrading_Factions.GetFaction        = Interaction.GetFaction
DynamicTrading_Factions.ModifyStockpile   = Interaction.ModifyStockpile
DynamicTrading_Factions.ModifyWealth      = Interaction.ModifyWealth
DynamicTrading_Factions.ModifyReputation  = Interaction.ModifyReputation

-- ==========================================================
-- 4. MP SYNC LISTENER
-- ==========================================================
local function OnReceiveGlobalModData(key, data)
    if key == "DynamicTrading_Factions" then
        ModData.add(key, data)
    end
end
Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)

if not isClient() or isServer() then
    Events.OnInitGlobalModData.Add(DynamicTrading_Factions.Init)
    Events.OnDynamicTradingDailySimulation.Add(DynamicTrading_Factions.UpdateDaily)
end

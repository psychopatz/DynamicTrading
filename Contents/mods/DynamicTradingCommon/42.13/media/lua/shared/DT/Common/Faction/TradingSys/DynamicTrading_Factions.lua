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
local DT_SimulationLogic  = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/DT_SimulationLogic"
local Interaction = require "DT/Common/Faction/TradingSys/Factions/Interaction"
local PlayerOwnership = require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnership"

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
DynamicTrading_Factions.UpdateDaily       = DT_SimulationLogic.UpdateDaily

-- Interaction
DynamicTrading_Factions.GetFaction        = Interaction.GetFaction
DynamicTrading_Factions.ModifyStockpile   = Interaction.ModifyStockpile
DynamicTrading_Factions.ModifyWealth      = Interaction.ModifyWealth
DynamicTrading_Factions.ModifyReputation  = Interaction.ModifyReputation

-- Player-owned factions
DynamicTrading_Factions.CreatePlayerFaction         = PlayerOwnership.CreatePlayerFaction
DynamicTrading_Factions.GetPlayerFaction            = PlayerOwnership.GetPlayerFaction
DynamicTrading_Factions.GetPlayerFactionID          = PlayerOwnership.GetPlayerFactionID
DynamicTrading_Factions.GetOwnedFactionStatus       = PlayerOwnership.BuildOwnedFactionStatus
DynamicTrading_Factions.RefreshPlayerFaction        = PlayerOwnership.RefreshPlayerFaction
DynamicTrading_Factions.RefreshAllPlayerFactions    = PlayerOwnership.RefreshAllPlayerFactions
DynamicTrading_Factions.GetPlayerFactionWorkers     = PlayerOwnership.GetLivingWorkersForFaction
DynamicTrading_Factions.GetPlayerFactionWorkerData  = PlayerOwnership.BuildOwnedFactionStatus
DynamicTrading_Factions.ApplyPlayerFactionCasualties = PlayerOwnership.ApplyCasualties
DynamicTrading_Factions.OnLabourWorkerCreated       = PlayerOwnership.OnLabourWorkerCreated
DynamicTrading_Factions.OnLabourWorkerRemoved       = PlayerOwnership.OnLabourWorkerRemoved
DynamicTrading_Factions.SetWorkerTradeEligibility   = PlayerOwnership.SetWorkerTradeEligibility
DynamicTrading_Factions.DispatchTrade               = PlayerOwnership.DispatchTrade
DynamicTrading_Factions.RecallTrade                 = PlayerOwnership.RecallTrade
DynamicTrading_Factions.EnterRegency                = PlayerOwnership.EnterRegency
DynamicTrading_Factions.ResumeLeadership            = PlayerOwnership.ResumeLeadership
DynamicTrading_Factions.IsPlayerFaction             = PlayerOwnership.IsPlayerFaction

-- ==========================================================
-- 4. MP SYNC LISTENER
-- ==========================================================
local function OnReceiveGlobalModData(key, data)
    if key == "DynamicTrading_Factions" and type(data) == "table" then
        ModData.add(key, data)
    end
end
Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)

if not isClient() or isServer() then
    Events.OnInitGlobalModData.Add(DynamicTrading_Factions.Init)
    Events.OnDynamicTradingDailySimulation.Add(DynamicTrading_Factions.UpdateDaily)
end

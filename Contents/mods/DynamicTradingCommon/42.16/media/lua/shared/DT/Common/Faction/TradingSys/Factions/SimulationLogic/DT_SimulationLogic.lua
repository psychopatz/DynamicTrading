-- ==============================================================================
-- Simulation/Simulation.lua
-- Logic: Daily Faction Simulation (Production, Consumption, Growth, Death).
-- Build 42 Compatible.
-- ==============================================================================

require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/Config"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"
require "DT/Common/Events/DT_EventManager"
require "DT/Common/Logging/GameplayLogs/DT_GameplayLogs"
require "DT/Common/Logging/Registry/DT_FactionLogEvents"

local DT_SimulationLogic = {}
local MOD_DATA_KEY = "DynamicTrading_Factions"

-- Submodules
local ProductionLogic = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/DT_SimulationLogic_Production_logic"
local FlashEventsLogic = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/DT_SimulationLogic_FlashEvents_logic"
local ConsumptionLogic = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/DT_SimulationLogic_Consumption_logic"
local RespawnLogic = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/DT_SimulationLogic_Respawn_logic"
local TownSim = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/FactionTypes/DT_SimLogic_Town"
local IndependentSim = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/FactionTypes/DT_SimLogic_Independent"
local PlayerSim = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/FactionTypes/DT_SimLogic_Player"
local VirtualStore = require "DT/Common/ColonyEconomy/VirtualStore/DT_VirtualStore"
local FactionCollapse = require "DT/Common/Faction/TradingSys/Factions/DT_FactionCollapse"

-- ==========================================================
-- DAILY SIMULATION
-- ==========================================================
function DT_SimulationLogic.UpdateDaily()
    local gameTime = getGameTime()
    local currentHour = math.floor(gameTime:getWorldAgeHours())

    local data = ModData.get(MOD_DATA_KEY)
    local engineData = DynamicTrading_Engine.GetEngineData()
    local Sandbox = SandboxVars.DynamicTrading
    
    VirtualStore.Prices.RecalculatePrices()
    
    local consumptionMult = Sandbox.FactionDailyConsumption or 1.0
    local deathThreshold = Sandbox.FactionDeathThreshold or 3
    local growthChance = Sandbox.FactionGrowthChance or 50
    
    local factionsToRemove = {}

    for id, faction in pairs(data) do
        if faction and faction.playerOwned then
            faction = PlayerSim.PreProcess(faction, id)
        end

        local factionActive = faction ~= nil

        if factionActive then
            if FactionCollapse.AuditFactionExtinction(id, { reason = "roster_extinction" }) then
                faction = data[id]
                factionActive = false
            end
        end

        if factionActive then
            if DynamicTrading.Events and DynamicTrading.Events.UpdateFaction then
                DynamicTrading.Events.UpdateFaction(faction)
            end

            -- 1. Town-specific Pre-Production (Infrastructure & Hordes)
            local buildingProd = nil
            local globalMults = nil
            if factionActive and faction.factionType == "town" then
                local tRes = { TownSim.Process(faction, id, data) }
                faction = tRes[1]
                factionActive = tRes[2]
                if tRes[3] then
                    buildingProd = tRes[3].buildingProd
                    globalMults = tRes[3].mults
                end
            end

            -- 2. Production Logic (Soul/Worker + Buildings + Multipliers)
            if factionActive then
                ProductionLogic.Process(faction, id, buildingProd, globalMults)
            end

            -- 3. Flash Events Logic
            if factionActive then
                faction, factionActive = FlashEventsLogic.Process(faction, id, data, currentHour)
            end

            -- 4. Consumption Logic & Generic Simulation
            if factionActive then
                if faction.factionType == "independent" then
                    faction, factionActive = IndependentSim.Process(faction, id, data)
                else
                    faction, factionActive = ConsumptionLogic.Process(faction, id, data, consumptionMult, deathThreshold, growthChance)
                end

                -- 5. Death Check
                if factionActive and faction.memberCount <= 0 then
                    local playerHandled = false
                    if faction.playerOwned then
                        playerHandled = PlayerSim.DeathCheck(faction, id)
                    end
                    if not playerHandled then
                        DynamicTrading.Log("Colony", "Faction", "Logic", "Faction ["..(faction.name or id).."] has DIED OUT")
                        FactionCollapse.CollapseFaction(id, faction, { reason = "population_depleted" })
                        factionActive = false
                    end
                end
            end
        end
    end
    
    -- Cleanup Dead Factions & Respawn Logic
    RespawnLogic.Process(data, factionsToRemove, Sandbox)

    ModData.transmit(MOD_DATA_KEY)
    
    if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.FlushChannel then
        DynamicTrading.GameplayLogs.FlushChannel("Factions")
    end
    
    DynamicTrading.Log("Colony", "Faction", "Sim", "Daily Faction Simulation Updated.")
end

return DT_SimulationLogic

-- ==============================================================================
-- Simulation/Simulation.lua
-- Logic: Daily Faction Simulation (Production, Consumption, Growth, Death).
-- Build 42 Compatible.
-- ==============================================================================

require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/Config"
require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"
require "DT/Common/Events/DT_EventManager"

local DT_SimulationLogic = {}
local MOD_DATA_KEY = "DynamicTrading_Factions"

-- Submodules
local ProductionLogic = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/DT_SimulationLogic_Production_logic"
local FlashEventsLogic = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/DT_SimulationLogic_FlashEvents_logic"
local ConsumptionLogic = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/DT_SimulationLogic_Consumption_logic"
local RespawnLogic = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/DT_SimulationLogic_Respawn_logic"
local TownFactionSim = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/DT_SimulationLogic_TownFaction"
local IndependentFactionSim = require "DT/Common/Faction/TradingSys/Factions/SimulationLogic/DT_SimulationLogic_IndependentFaction"

-- ==========================================================
-- DAILY SIMULATION
-- ==========================================================
function DT_SimulationLogic.UpdateDaily()
    local gameTime = getGameTime()
    local currentHour = math.floor(gameTime:getWorldAgeHours())

    local data = ModData.get(MOD_DATA_KEY)
    local engineData = DynamicTrading_Engine.GetEngineData()
    local Sandbox = SandboxVars.DynamicTrading
    
    local consumptionMult = Sandbox.FactionDailyConsumption or 1.0
    local deathThreshold = Sandbox.FactionDeathThreshold or 3
    local growthChance = Sandbox.FactionGrowthChance or 50
    
    local factionsToRemove = {}

    for id, faction in pairs(data) do
        if faction and faction.playerOwned
            and (tostring(faction.leadershipState or "") == "AdminReview"
                or (DynamicTrading_Factions.IsDynamicColoniesEnabled and not DynamicTrading_Factions.IsDynamicColoniesEnabled())) then
            faction = nil
        end

        if faction and faction.playerOwned and DynamicTrading_Factions.RefreshPlayerFaction then
            faction = DynamicTrading_Factions.RefreshPlayerFaction(id)
        end

        local factionActive = faction ~= nil

        if factionActive then
            if DynamicTrading.Events and DynamicTrading.Events.UpdateFaction then
                DynamicTrading.Events.UpdateFaction(faction)
            end

            -- 1. Production Logic
            ProductionLogic.Process(faction, id)

            -- 2. Flash Events Logic
            faction, factionActive = FlashEventsLogic.Process(faction, id, data, currentHour)

            -- 3. Consumption Logic & Modular Simulation
            if factionActive then
                if faction.factionType == "independent" then
                    faction, factionActive = IndependentFactionSim.Process(faction, id, data)
                else
                    faction, factionActive = ConsumptionLogic.Process(faction, id, data, consumptionMult, deathThreshold, growthChance)
                    if factionActive and faction.factionType == "town" then
                        faction, factionActive = TownFactionSim.Process(faction, id, data)
                    end
                end

                -- 4. Death Check
                if factionActive and faction.memberCount <= 0 then
                    if faction.playerOwned and DynamicTrading_Factions.MarkFactionAdminReview then
                        DynamicTrading_Factions.MarkFactionAdminReview(id, "no_linked_workers")
                        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Player faction ["..(faction.name or id).."] moved to admin review")
                    else
                        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Faction ["..(faction.name or id).."] has DIED OUT")
                        table.insert(factionsToRemove, id)
                    end
                end
            end
        end
    end
    
    -- Cleanup Dead Factions & Respawn Logic
    RespawnLogic.Process(data, factionsToRemove, Sandbox)

    ModData.transmit(MOD_DATA_KEY)
    DynamicTrading.Log("DTCommons", "Faction", "Sim", "Daily Faction Simulation Updated.")
end

return DT_SimulationLogic

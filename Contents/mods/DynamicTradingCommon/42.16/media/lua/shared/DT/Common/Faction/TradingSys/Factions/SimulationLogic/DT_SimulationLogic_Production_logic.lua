-- ==============================================================================
-- Simulation/Simulation_Production_logic.lua
-- Logic: Handles daily resource production for workers and souls.
-- ==============================================================================

local ProductionLogic = {}

function ProductionLogic.buildProductionFromArchetype(production, archetypeID)
    local archData = DynamicTrading.Archetypes and DynamicTrading.Archetypes[archetypeID] or nil
    if not archData or not archData.allocations then
        return
    end

    for tag, score in pairs(archData.allocations) do
        local resourceType = DynamicTrading.Config.ResourceMap[tag]
        if resourceType then
            production[resourceType] = production[resourceType] + (score * DynamicTrading.Config.Sim.ProductionMultiplier)
        end
    end
end

function ProductionLogic.Process(faction, id)
    local production = { food=0, ammo=0, meds=0, fuel=0 }
    if faction.playerOwned and DynamicTrading_Factions.GetPlayerFactionWorkers then
        local livingWorkers = DynamicTrading_Factions.GetPlayerFactionWorkers(id) or {}
        faction.memberCount = #livingWorkers
        for _, worker in ipairs(livingWorkers) do
            ProductionLogic.buildProductionFromArchetype(production, worker.archetypeID or worker.profession or "General")
        end
    else
        local soulUUIDs = DynamicTrading_Roster.GetSouls(id)
        for _, uuid in ipairs(soulUUIDs) do
            local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
            if soul then
                ProductionLogic.buildProductionFromArchetype(production, soul.archetypeID)
            end
        end
    end

    if not faction.stockpile then
        faction.stockpile = { food=0, ammo=0, meds=0, fuel=0 }
    end
    for res, amt in pairs(production) do
        faction.stockpile[res] = (faction.stockpile[res] or 0) + amt
    end
end

return ProductionLogic

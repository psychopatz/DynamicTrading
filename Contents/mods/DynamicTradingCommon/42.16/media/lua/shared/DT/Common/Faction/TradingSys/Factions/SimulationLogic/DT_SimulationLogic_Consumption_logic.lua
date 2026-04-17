-- ==============================================================================
-- Simulation/Simulation_Consumption_logic.lua
-- Logic: Handles daily resource consumption, starvation consequences, and recruitment.
-- ==============================================================================

local ConsumptionLogic = {}

function ConsumptionLogic.Process(faction, id, data, consumptionMult, deathThreshold, growthChance)
    local factionActive = faction ~= nil
    if not factionActive then return nil, false end

    local consumes = DynamicTrading.Config.Sim.BaseConsumption
    if consumes then
        local foodBurnMod = 1.0
        local medsBurnMod = 1.0
        if DynamicTrading_Engine and DynamicTrading_Engine.GetConsumptionModifier then
            foodBurnMod = DynamicTrading_Engine.GetConsumptionModifier("food")
            medsBurnMod = DynamicTrading_Engine.GetConsumptionModifier("meds")
        end

        local foodBurn = faction.memberCount * (consumes.food or 1) * consumptionMult * foodBurnMod
        local medsBurn = faction.memberCount * (consumes.meds or 0.1) * consumptionMult * medsBurnMod

        faction.stockpile.food = (faction.stockpile.food or 0) - foodBurn
        faction.stockpile.meds = (faction.stockpile.meds or 0) - medsBurn

        if faction.stockpile.food < 0 then
            faction.stockpile.food = 0
            faction.starvationDays = (faction.starvationDays or 0) + 1

            if faction.starvationDays >= deathThreshold then
                local deaths = math.ceil(faction.memberCount * DynamicTrading.Config.Sim.DeathRate)
                deaths = math.max(1, deaths)
                if faction.playerOwned and DynamicTrading_Factions.ApplyPlayerFactionCasualties then
                    deaths = DynamicTrading_Factions.ApplyPlayerFactionCasualties(id, deaths, "Starvation")
                    faction = data[id]
                    factionActive = faction ~= nil
                else
                    faction.memberCount = faction.memberCount - deaths
                    DynamicTrading_Roster.RemoveSoul(id, deaths)
                end

                if factionActive then
                    DynamicTrading.Log("DTCommons", "Faction", "Starving", "Faction " .. faction.name .. " is STARVING! Lost " .. deaths .. " souls.")
                end
            end
        else
            faction.starvationDays = 0
        end

        if factionActive then
            if faction.memberCount > 0 then
                local surplusFood = (faction.stockpile.food or 0) > (faction.memberCount * (consumes.food or 1) * 7)

                if not faction.playerOwned and surplusFood and ZombRand(100) < growthChance then
                    local archetypes = {}
                    for aid, _ in pairs(DynamicTrading.Archetypes) do
                        table.insert(archetypes, aid)
                    end

                    if #archetypes > 0 and DynamicTrading_Engine.ConsumeRecruit() then
                        faction.memberCount = faction.memberCount + 1
                        local newRecruit = archetypes[ZombRand(#archetypes)+1]
                        local home = faction.homeCoords
                        local scatteredHome = nil
                        if home and home.x then
                            local scatterRange = 10
                            scatteredHome = {
                                x = home.x + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                                y = home.y + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                                z = home.z or 0
                            }
                        end
                        DynamicTrading_Roster.AddSoul(id, newRecruit, scatteredHome)
                        faction.stockpile.food = faction.stockpile.food - DynamicTrading.Config.Sim.RecruitCost.food
                        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Faction ["..faction.name.."] RECRUITED a new " .. tostring(newRecruit))
                    end
                end

                if faction.starvationDays > 0 then
                    faction.state = "Starving"
                elseif (faction.stockpile.food or 0) < (faction.memberCount * 5) then
                    faction.state = "Vulnerable"
                else
                    faction.state = "Stable"
                end
            end

            if faction.memberCount > 0 then
                if DynamicTrading.Events and DynamicTrading.Events.GetDemographicsModifier then
                    local attritionAdd = DynamicTrading.Events.GetDemographicsModifier("attritionAdd")
                    if attritionAdd and attritionAdd > 0 then
                        local passiveDeaths = math.floor(faction.memberCount * attritionAdd)
                        if passiveDeaths > 0 then
                            if faction.playerOwned and DynamicTrading_Factions.ApplyPlayerFactionCasualties then
                                passiveDeaths = DynamicTrading_Factions.ApplyPlayerFactionCasualties(id, passiveDeaths, "Global attrition")
                                faction = data[id]
                                factionActive = faction ~= nil
                            else
                                faction.memberCount = math.max(0, faction.memberCount - passiveDeaths)
                                DynamicTrading_Roster.RemoveSoul(id, passiveDeaths)
                            end

                            if factionActive then
                                DynamicTrading.Log("DTCommons", "Faction", "Sim", "Global Attrition hit faction [" .. faction.name .. "] | Casualties: " .. passiveDeaths)
                            end
                        end
                    end
                end
            end
        end
    else
        DynamicTrading.Log("DTCommons", "Error", "Faction", "BaseConsumption not found in config for simulation!")
    end

    return faction, factionActive
end

return ConsumptionLogic

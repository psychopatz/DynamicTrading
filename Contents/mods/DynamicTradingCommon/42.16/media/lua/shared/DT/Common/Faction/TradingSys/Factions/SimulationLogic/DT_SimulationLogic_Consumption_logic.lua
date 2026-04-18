-- ==============================================================================
-- Simulation/Simulation_Consumption_logic.lua
-- Logic: Handles daily resource consumption, starvation consequences, and recruitment.
-- ==============================================================================

local ConsumptionLogic = {}

function ConsumptionLogic.Process(faction, id, data, consumptionMult, deathThreshold, growthChance)
    local factionActive = faction ~= nil
    if not factionActive then return nil, false end

    local simConfig = DynamicTrading.Config.Sim
    local consumes = simConfig.BaseConsumption
    local thresholds = simConfig.ShortageThresholds or { water = 1, meds = 2, ammo = 1, fuel = 1, materials = 3 }
    
    local sandboxConsumptionMult = DynamicTrading.Config.GetSandboxMult("FactionConsumptionMult")
    consumptionMult = consumptionMult * sandboxConsumptionMult

    if consumes then
        faction.shortageDays = faction.shortageDays or { water = 0, meds = 0, ammo = 0, fuel = 0, materials = 0 }
        faction.penalties = faction.penalties or { dehydrated = false, sick = false, vulnerable = false, isolated = false, decaying = false }
        faction.stockpile = faction.stockpile or { food = 0, meds = 0, ammo = 0, fuel = 0, water = 0, materials = 0 }

        -- 1. Consumption calculation
        local mods = { food = 1.0, water = 1.0, meds = 1.0, ammo = 1.0, fuel = 1.0, materials = 1.0 }
        if DynamicTrading_Engine and DynamicTrading_Engine.GetConsumptionModifier then
            for r, _ in pairs(mods) do
                mods[r] = DynamicTrading_Engine.GetConsumptionModifier(r) or 1.0
            end
        end

        local resList = { "food", "water", "meds", "ammo", "fuel", "materials" }
        for _, r in ipairs(resList) do
            local rate = consumes[r] or 0
            local burn = 0
            
            -- Some are per-member, some are flat
            if r == "fuel" or r == "materials" then
                burn = rate * consumptionMult * mods[r]
            else
                burn = faction.memberCount * rate * consumptionMult * mods[r]
            end

            faction.stockpile[r] = (faction.stockpile[r] or 0) - burn

            -- Check shortage
            if (faction.stockpile[r] or 0) < 0 then
                faction.stockpile[r] = 0
                if r == "food" then
                    faction.starvationDays = (faction.starvationDays or 0) + 1
                else
                    faction.shortageDays[r] = (faction.shortageDays[r] or 0) + 1
                end
            else
                if r == "food" then
                    faction.starvationDays = 0
                else
                    faction.shortageDays[r] = 0
                end
            end
        end

        -- 2. Penalty Updates
        faction.penalties.dehydrated = (faction.shortageDays.water or 0) >= (thresholds.water or 1)
        faction.penalties.sick       = (faction.shortageDays.meds or 0)  >= (thresholds.meds or 2)
        faction.penalties.vulnerable = (faction.shortageDays.ammo or 0)  >= (thresholds.ammo or 1)
        faction.penalties.isolated   = (faction.shortageDays.fuel or 0)  >= (thresholds.fuel or 1)
        faction.penalties.decaying   = (faction.shortageDays.materials or 0) >= (thresholds.materials or 3)

        -- 3. Penalty Effects
        
        -- Dehydration accelerates starvation
        if faction.penalties.dehydrated then
            faction.starvationDays = faction.starvationDays + 1
            DynamicTrading.Log("Colony", "Penalty", "Dehydration", faction.name .. " is DEHYDRATED! Starvation accelerating.")
        end

        -- Starvation leading to deaths
        if faction.starvationDays >= deathThreshold then
            local deaths = math.ceil(faction.memberCount * simConfig.DeathRate)
            deaths = math.max(1, deaths)
            if faction.playerOwned and DynamicTrading_Factions.ApplyPlayerFactionCasualties then
                deaths = DynamicTrading_Factions.ApplyPlayerFactionCasualties(id, deaths, "Starvation/Dehydration")
                faction = data[id]
                factionActive = faction ~= nil
            else
                faction.memberCount = faction.memberCount - deaths
                DynamicTrading_Roster.RemoveSoul(id, deaths)
            end

            if factionActive then
                DynamicTrading.Log("Colony", "Faction", "Starving", "Faction " .. faction.name .. " is STARVING! Lost " .. deaths .. " souls.")
                if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
                    DynamicTrading.GameplayLogs.AddFactionEvent(id, DynamicTrading.GameplayEvents.STARVATION_DEATHS, {deaths})
                end
            end
        end

        -- Passive Attrition (includes Sick penalty)
        if factionActive and faction.memberCount > 0 then
            local attritionBase = 0
            if faction.penalties.sick then
                attritionBase = 0.02 -- Hardcoded sick attrition
                DynamicTrading.Log("Colony", "Penalty", "Sickness", faction.name .. " is SICK! Passive attrition active.")
            end

            if DynamicTrading.Events and DynamicTrading.Events.GetDemographicsModifier then
                local eventAttrition = DynamicTrading.Events.GetDemographicsModifier("attritionAdd") or 0
                attritionBase = attritionBase + eventAttrition
            end

            if attritionBase > 0 then
                local passiveDeaths = math.floor(faction.memberCount * attritionBase)
                if passiveDeaths > 0 then
                    if faction.playerOwned and DynamicTrading_Factions.ApplyPlayerFactionCasualties then
                        passiveDeaths = DynamicTrading_Factions.ApplyPlayerFactionCasualties(id, passiveDeaths, "Illness/Attrition")
                        faction = data[id]
                        factionActive = faction ~= nil
                    else
                        faction.memberCount = math.max(0, faction.memberCount - passiveDeaths)
                        DynamicTrading_Roster.RemoveSoul(id, passiveDeaths)
                    end

                    if factionActive then
                        DynamicTrading.Log("Colony", "Faction", "Sim", "Attrition hit faction [" .. faction.name .. "] | Casualties: " .. passiveDeaths)
                        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
                            DynamicTrading.GameplayLogs.AddFactionEvent(id, DynamicTrading.GameplayEvents.ATTRITION_DEATHS, {passiveDeaths})
                        end
                    end
                end
            end
        end

        -- 4. Recruitment Logic (Surplus Food)
        if factionActive and faction.memberCount > 0 then
            -- Recruitment is disabled if sick
            local canRecruit = not faction.penalties.sick
            
            local surplusFood = (faction.stockpile.food or 0) > (faction.memberCount * (consumes.food or 1) * 7)

            if canRecruit and not faction.playerOwned and surplusFood and ZombRand(100) < growthChance then
                -- Barracks check
                local recruitMult = 1.0
                if faction.buildings and faction.buildings.Barracks and faction.buildings.Barracks.level > 0 and faction.buildings.Barracks.hp > 0 then
                    recruitMult = 2.0 -- Plan: Barracks doubles recruitment speed
                end

                if ZombRand(100) < (growthChance * recruitMult) then
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
                        faction.stockpile.food = faction.stockpile.food - simConfig.RecruitCost.food
                        DynamicTrading.Log("Colony", "Faction", "Logic", "Faction ["..faction.name.."] RECRUITED a new " .. tostring(newRecruit))
                    end
                end
            end
        end

        -- 5. Final State Update (Simplified, TownSim will do the 5-tier logic)
        if factionActive then
            if faction.starvationDays > 0 then
                faction.state = "Starving"
            elseif faction.penalties.dehydrated or faction.penalties.sick then
                faction.state = "Vulnerable"
            else
                faction.state = "Stable"
            end
        end
    else
        DynamicTrading.Log("DTCommons", "Error", "Faction", "BaseConsumption not found in config for simulation!")
    end

    return faction, factionActive
end

return ConsumptionLogic

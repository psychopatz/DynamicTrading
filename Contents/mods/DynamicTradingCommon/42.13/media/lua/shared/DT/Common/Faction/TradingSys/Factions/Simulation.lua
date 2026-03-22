-- ==============================================================================
-- Factions/Simulation.lua
-- Logic: Daily Faction Simulation (Production, Consumption, Growth, Death).
-- Build 42 Compatible.
-- ==============================================================================

require "DT/Common/Faction/TradingSys/DynamicTrading_Engine"
require "DT/Common/Config"
require "DT/Common/Faction/TradingSys/DynamicTrading_Roster"
-- require "DT/Common/Faction/TradingSys/Factions/DynamicTrading_Director" -- Deprecated
require "DT/Common/Events/DT_EventManager"

local Simulation = {}
local MOD_DATA_KEY = "DynamicTrading_Factions"

local function buildProductionFromArchetype(production, archetypeID)
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

-- ==========================================================
-- DAILY SIMULATION
-- ==========================================================
function Simulation.UpdateDaily()
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
        if faction and faction.playerOwned and DynamicTrading_Factions.RefreshPlayerFaction then
            faction = DynamicTrading_Factions.RefreshPlayerFaction(id)
        end

        local factionActive = faction ~= nil

        if factionActive then
            if DynamicTrading.Events and DynamicTrading.Events.UpdateFaction then
                DynamicTrading.Events.UpdateFaction(faction)
            end

            local production = { food=0, ammo=0, meds=0, fuel=0 }
            if faction.playerOwned and DynamicTrading_Factions.GetPlayerFactionWorkers then
                local livingWorkers = DynamicTrading_Factions.GetPlayerFactionWorkers(id) or {}
                faction.memberCount = #livingWorkers
                for _, worker in ipairs(livingWorkers) do
                    buildProductionFromArchetype(production, worker.archetypeID or worker.profession or "General")
                end
            else
                local soulUUIDs = DynamicTrading_Roster.GetSouls(id)
                for _, uuid in ipairs(soulUUIDs) do
                    local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
                    if soul then
                        buildProductionFromArchetype(production, soul.archetypeID)
                    end
                end
            end

            if not faction.stockpile then
                faction.stockpile = { food=0, ammo=0, meds=0, fuel=0 }
            end
            for res, amt in pairs(production) do
                faction.stockpile[res] = (faction.stockpile[res] or 0) + amt
            end

            faction.ActiveFlashEvents = faction.ActiveFlashEvents or {}
            if #faction.ActiveFlashEvents == 0 and faction.ActiveFlashEvent and faction.ActiveFlashEvent.id then
                table.insert(faction.ActiveFlashEvents, {
                    id = faction.ActiveFlashEvent.id,
                    expires = faction.ActiveFlashEvent.expires or 0,
                    targetCasualties = faction.ActiveFlashEvent.targetCasualties or 0
                })
            end

            for _, afe in ipairs(faction.ActiveFlashEvents) do
                if factionActive and afe and afe.id then
                    if afe.targetCasualties and afe.targetCasualties > 0 then
                        local hoursLeft = (afe.expires or currentHour) - currentHour
                        local daysLeft = math.ceil(hoursLeft / 24)
                        if daysLeft < 1 then
                            daysLeft = 1
                        end

                        local killToday = math.ceil(afe.targetCasualties / daysLeft)
                        if killToday > 1 and ZombRand(100) < 30 then
                            killToday = killToday - 1
                        end
                        if killToday > afe.targetCasualties then
                            killToday = afe.targetCasualties
                        end

                        if killToday > 0 then
                            if faction.playerOwned and DynamicTrading_Factions.ApplyPlayerFactionCasualties then
                                killToday = DynamicTrading_Factions.ApplyPlayerFactionCasualties(id, killToday, "Faction event casualties")
                                faction = data[id]
                                factionActive = faction ~= nil
                            else
                                faction.memberCount = math.max(0, faction.memberCount - killToday)
                                DynamicTrading_Roster.RemoveSoul(id, killToday)
                            end

                            if factionActive then
                                afe.targetCasualties = afe.targetCasualties - killToday
                                DynamicTrading.Log("DTCommons", "Faction", "Sim", "Event casualty hit for faction [" .. faction.name .. "] [" .. tostring(afe.id) .. "] | Killed: " .. killToday .. " | Remaining Targets: " .. tostring(afe.targetCasualties))
                            end
                        end
                    end

                    if factionActive then
                        local def = DynamicTrading.Events.Registry[afe.id]
                        if def and def.attrition then
                            local attr = def.attrition
                            local resource = attr.resource or "meds"
                            local affectedPct = attr.pct or attr.sickPct or 0
                            local costPerHead = attr.cost or attr.medsPerSick or 1.0

                            local affectedCount = math.floor(faction.memberCount * affectedPct)
                            if affectedCount > 0 then
                                local totalNeeded = affectedCount * costPerHead
                                local stockpile = (faction.stockpile[resource] or 0)

                                if stockpile >= totalNeeded then
                                    faction.stockpile[resource] = stockpile - totalNeeded
                                    DynamicTrading.Log("DTCommons", "Faction", "Sim", "Faction [" .. faction.name .. "] met " .. resource .. " requirements for " .. affectedCount .. " souls.")
                                else
                                    local casualties = math.ceil(affectedCount * 0.2)
                                    if faction.playerOwned and DynamicTrading_Factions.ApplyPlayerFactionCasualties then
                                        casualties = DynamicTrading_Factions.ApplyPlayerFactionCasualties(id, casualties, "Faction attrition")
                                        faction = data[id]
                                        factionActive = faction ~= nil
                                    else
                                        faction.memberCount = math.max(0, faction.memberCount - casualties)
                                        DynamicTrading_Roster.RemoveSoul(id, casualties)
                                    end

                                    if factionActive then
                                        DynamicTrading.Log("DTCommons", "Faction", "Sim", "Faction [" .. faction.name .. "] " .. resource:upper() .. " SHORTAGE! Lost " .. casualties .. " souls.")
                                        faction.state = "Starving"
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if factionActive then
                local firstFlash = faction.ActiveFlashEvents[1]
                faction.ActiveFlashEvent = {
                    id = firstFlash and firstFlash.id or nil,
                    expires = firstFlash and (firstFlash.expires or 0) or 0,
                    targetCasualties = firstFlash and (firstFlash.targetCasualties or 0) or 0
                }

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
                        faction.starvationDays = faction.starvationDays + 1

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
                        if faction.memberCount <= 0 then
                            DynamicTrading.Log("DTCommons", "Faction", "Logic", "Faction ["..faction.name.."] has DIED OUT")
                            table.insert(factionsToRemove, id)
                        else
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

                        if id == "Independent" then
                            faction.memberCount = math.max(faction.memberCount, 10)
                            faction.state = "Stable"
                            faction.stockpile.food = math.max(faction.stockpile.food or 0, 500)
                            faction.wealth = math.max(faction.wealth or 0, 5000)
                        else
                            if DynamicTrading.Events and DynamicTrading.Events.GetDemographicsModifier then
                                local attritionAdd = DynamicTrading.Events.GetDemographicsModifier("attritionAdd")
                                if attritionAdd > 0 then
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

                            if factionActive then
                                local dailyEarn = faction.memberCount * 50
                                faction.wealth = (faction.wealth or 0) + dailyEarn
                            end
                        end
                    end
                else
                    DynamicTrading.Log("DTCommons", "Error", "Faction", "BaseConsumption not found in config for simulation!")
                end
            end
        end
    end
    
    -- Cleanup Dead Factions
    for _, deadID in ipairs(factionsToRemove) do
        data[deadID] = nil
        DynamicTrading_Roster.ClearSouls(deadID) -- Remove their souls from Roster too
    end

    -- DYNAMIC RESPAWNING (Long game stability)
    if DT_FactionLocations then
        local respawnChance = Sandbox.FactionRespawnChance or 10
        local maxFactions = Sandbox.MaxFactionsPerTown or 2
        
        for townName, _ in pairs(DT_FactionLocations) do
            -- Count existing factions in this town
            local count = 0
            for _, f in pairs(data) do
                if f.town == townName then count = count + 1 end
            end
            
            if count < maxFactions and ZombRand(100) < respawnChance then
                -- New faction arrives!
                local factionID = townName .. "_" .. tostring(100000 + ZombRand(900000))
                DynamicTrading_Factions.CreateFaction(factionID, {
                    town = townName,
                    memberCount = SandboxVars.DynamicTrading.FactionStartPop or 10
                })
                DynamicTrading.Log("DTCommons", "Faction", "Sim", "A new faction has moved into " .. townName)
            end
        end
    end
    
    ModData.transmit(MOD_DATA_KEY)
    DynamicTrading.Log("DTCommons", "Faction", "Sim", "Daily Faction Simulation Updated.")
end

return Simulation

-- ==============================================================================
-- Factions/Simulation.lua
-- Logic: Daily Faction Simulation (Production, Consumption, Growth, Death).
-- Build 42 Compatible.
-- ==============================================================================

require "DT/V2/Faction/TradingSys/DynamicTrading_Engine"
require "DT/V2/Config"
require "DT/V2/Faction/TradingSys/DynamicTrading_Roster"
require "DT/V2/Faction/TradingSys/Factions/DynamicTrading_Director"

local Simulation = {}
local MOD_DATA_KEY = "DynamicTrading_Factions"

-- ==========================================================
-- DAILY SIMULATION
-- ==========================================================
function Simulation.UpdateDaily()
    local data = ModData.get(MOD_DATA_KEY)
    local engineData = DynamicTrading_Engine.GetEngineData()
    local Sandbox = SandboxVars.DynamicTrading
    
    local consumptionMult = Sandbox.FactionDailyConsumption or 1.0
    local deathThreshold = Sandbox.FactionDeathThreshold or 3
    local growthChance = Sandbox.FactionGrowthChance or 50
    
    local factionsToRemove = {}

    for id, faction in pairs(data) do
        -- 0. DIRECTORS CUT (Trigger Events & Wildcards)
        if DynamicTrading.V2.Director then
            DynamicTrading.V2.Director.Update(faction)
        end

        -- 0.1 CALCULATE PRODUCTION (Based on Roster)
        local production = { food=0, ammo=0, meds=0, fuel=0 }
        local soulUUIDs = DynamicTrading_Roster.GetSouls(id)
        
        for _, uuid in ipairs(soulUUIDs) do
            local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
            if soul then
                local archID = soul.archetypeID
                local archData = DynamicTrading.Archetypes[archID]
                if archData and archData.allocations then
                    for tag, score in pairs(archData.allocations) do
                        local resourceType = DynamicTrading.V2.Config.ResourceMap[tag]
                        if resourceType then
                             -- Score * Multiplier (e.g., 6 * 2.0 = 12 units)
                            production[resourceType] = production[resourceType] + (score * DynamicTrading.V2.Config.Sim.ProductionMultiplier)
                        end
                    end
                end
            end
        end
        
        -- Add Production to Stockpile
        if not faction.stockpile then faction.stockpile = { food=0, ammo=0, meds=0, fuel=0 } end
        for res, amt in pairs(production) do
            faction.stockpile[res] = (faction.stockpile[res] or 0) + amt
        end

        -- 1. CONSUMPTION
        local consumes = DynamicTrading.V2.Config.Sim.BaseConsumption
        if consumes then
            local foodBurn = faction.memberCount * (consumes.food or 1) * consumptionMult
            local medsBurn = faction.memberCount * (consumes.meds or 0.1) * consumptionMult
            
            faction.stockpile.food = (faction.stockpile.food or 0) - foodBurn
            faction.stockpile.meds = (faction.stockpile.meds or 0) - medsBurn
            -- Ammo/Fuel are consumed less reliably, maybe only if "At War" (future), for now base burn
            
            -- 2. STARVATION & DEATH
            if faction.stockpile.food < 0 then
                faction.stockpile.food = 0 -- Clamp
                faction.starvationDays = faction.starvationDays + 1
                
                if faction.starvationDays >= deathThreshold then
                    -- Kill people
                    local deaths = math.ceil(faction.memberCount * DynamicTrading.V2.Config.Sim.DeathRate)
                    deaths = math.max(1, deaths) -- At least 1 dies
                    faction.memberCount = faction.memberCount - deaths
                    
                    -- Remove from roster in Roster module
                    DynamicTrading_Roster.RemoveSoul(id, deaths)
                    
                    print("DT Faction ["..faction.name.."] is STARVING! Lost " .. deaths .. " souls.")
                end
            else
                faction.starvationDays = 0 -- Reset if they have food
            end
            
            -- CHECK FACTION DEATH
            if faction.memberCount <= 0 then
                print("DT Faction ["..faction.name.."] has DIED OUT.")
                table.insert(factionsToRemove, id)
            else
                -- 3. GROWTH (If not starving and has surplus)
                -- Surplus check: Enough food for X days?
                local surplusFood = (faction.stockpile.food or 0) > (faction.memberCount * (consumes.food or 1) * 7) -- 1 Week buffer
                
                if surplusFood and ZombRand(100) < growthChance then
                    -- Assign random class
                    local archetypes = {}
                    for aid, _ in pairs(DynamicTrading.Archetypes) do table.insert(archetypes, aid) end
                    
                    if #archetypes > 0 and DynamicTrading_Engine.ConsumeRecruit() then
                        faction.memberCount = faction.memberCount + 1
                        local newRecruit = archetypes[ZombRand(#archetypes)+1]
                        
                        -- Add to roster in Roster module
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
                        
                        -- Growth Cost (Initial Setup)
                        faction.stockpile.food = faction.stockpile.food - DynamicTrading.V2.Config.Sim.RecruitCost.food
                        
                        print("DT Faction ["..faction.name.."] RECRUITED a new " .. tostring(newRecruit))
                    end
                end
                
                -- Update State Label
                if faction.starvationDays > 0 then
                    faction.state = "Starving"
                elseif (faction.stockpile.food or 0) < (faction.memberCount * 5) then
                    faction.state = "Vulnerable"
                else
                    faction.state = "Stable"
                end
            end
            
            -- Nomadic Failsafe Adjustment
            if id == "Independent" then
                faction.memberCount = math.max(faction.memberCount, 10) -- Nomads replenish mysteriously
                faction.state = "Stable"
                faction.stockpile.food = math.max(faction.stockpile.food or 0, 500)
                faction.wealth = math.max(faction.wealth or 0, 5000) -- Nomads are wealthy
            else
                -- Basic Wealth Simulation: Factions earn small revenue from internal trading/scavenging
                -- We can scale this based on member count
                local dailyEarn = faction.memberCount * 50
                faction.wealth = (faction.wealth or 0) + dailyEarn
            end
        else
            print("DT ERROR: BaseConsumption not found in config for simulation!")
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
                print("DT: A new faction has moved into " .. townName)
            end
        end
    end
    
    ModData.transmit(MOD_DATA_KEY)
    print("DT: Daily Faction Simulation Updated.")
end

return Simulation

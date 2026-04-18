-- ==============================================================================
-- ColonyEconomy/Buildings/DT_BuildingLogic.lua
-- Logic: Daily processing for Buildings, construction wait times, and degradations.
-- ==============================================================================

local BuildingDefs = require "DT/Common/ColonyEconomy/Buildings/DT_BuildingDefs"
local BuildingSkills = require "DT/Common/ColonyEconomy/Buildings/DT_BuildingSkills"

local BuildingLogic = {}

--- Calculates global multiplier buffs from buildings in a town
function BuildingLogic.GetGlobalMultipliers(faction)
    local prodMult = 1.0
    local recruitMult = 1.0
    local popCapAdd = 0
    local healBuff = 0
    
    local buildings = faction.buildings or {}
    
    if buildings.Workshop and buildings.Workshop.level > 0 and buildings.Workshop.hp > 0 then
        prodMult = prodMult + 0.2 -- Workshop global prod boost
    end
    
    if buildings.Barracks and buildings.Barracks.level > 0 and buildings.Barracks.hp > 0 then
        recruitMult = 2.0
        popCapAdd = 2 * buildings.Barracks.level
    end
    
    if buildings.Infirmary and buildings.Infirmary.level > 0 and buildings.Infirmary.hp > 0 then
        healBuff = 0.5 * buildings.Infirmary.level -- Passive abstract heal
    end
    
    return {
        prodMult = prodMult,
        recruitMult = recruitMult,
        popCapAdd = popCapAdd,
        healBuff = healBuff
    }
end

--- Processes the day tick for buildings (Construction, Production, Degradation)
function BuildingLogic.ProcessBuildings(faction, factionID)
    if not faction or not faction.buildings then return end
    
    local outProduction = { food = 0, water = 0, meds = 0, ammo = 0, fuel = 0, materials = 0 }
    local isDecaying = faction.penalties and faction.penalties.decaying
    
    for bName, bData in pairs(faction.buildings) do
        local def = BuildingDefs[bName]
        if def then
            -- Construction Phase (Requires a Carpenter to progress)
            if bData.level == 0 and (bData.constructionDaysLeft or 0) > 0 then
                local hasCarpenter = false
                if bData.workers then
                    for _, uuid in ipairs(bData.workers) do
                        local soul = BuildingSkills.GetWorkerSoul(uuid)
                        if soul and (soul.archetypeID == "Carpenter" or soul.profession == "Carpenter") then
                            hasCarpenter = true
                            break
                        end
                    end
                end

                if hasCarpenter then
                    -- Daily construction cost
                    local materialCostMult = DynamicTrading.Config.GetSandboxMult("BuildingMaterialMult")
                    local dailyCost = math.ceil((def.materialsCost or 0) / (def.buildDays or 3) * materialCostMult)
                    
                    if (faction.stockpile.materials or 0) >= dailyCost then
                        faction.stockpile.materials = faction.stockpile.materials - dailyCost
                        bData.constructionDaysLeft = bData.constructionDaysLeft - 1
                        if bData.constructionDaysLeft <= 0 then
                            bData.level = 1
                            bData.hp = def.baseHp
                            bData.maxHp = def.baseHp
                            DynamicTrading.Log("Colony", "Infrastructure", "Build", faction.name .. " finished constructing " .. def.name)
                            if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
                                DynamicTrading.GameplayLogs.AddFactionEvent(factionID, DynamicTrading.GameplayEvents.CONSTRUCTED, {def.name})
                            end
                        end
                    else
                        DynamicTrading.Log("Colony", "Infrastructure", "Build", faction.name .. " construction STALLED (no materials) for " .. def.name)
                    end
                end
            end
            
            -- Degradation from Materials Shortage
            if bData.level > 0 and isDecaying then
                local dmg = math.floor(bData.maxHp * 0.05)
                bData.hp = math.max(0, bData.hp - dmg)
            end
            
            -- Operational Production
            if bData.level > 0 and bData.hp > 0 then
                -- Determine worker proficiency multiplier
                local workerProficiency = 0
                if bName == "Headquarters" then
                    workerProficiency = 1.0 -- HQ doesn't produce, no proficiency needed
                elseif bData.workers and #bData.workers > 0 then
                    workerProficiency = BuildingSkills.GetWorkerListProficiency(bData.workers, def.archetype)
                end
                
                -- NOTE: If building requires workers (def.capacity > 0) but workerProficiency is 0, it operates at 0% efficiency.
                -- Base structures like Infirmary and Barricade are passive, but Water, Fuel, Ammo, Food are active.
                
                -- Greenhouse: Water -> Food conversion
                if bName == "Greenhouse" and workerProficiency > 0 then
                    local waterReq = 10 * #bData.workers
                    if (faction.stockpile.water or 0) >= waterReq then
                        faction.stockpile.water = faction.stockpile.water - waterReq
                        outProduction.food = outProduction.food + (1 * workerProficiency * bData.level)
                    end
                end
                
                -- Water Generator
                if bName == "WaterGenerator" and workerProficiency > 0 then
                    outProduction.water = outProduction.water + (2 * workerProficiency * bData.level)
                end
                
                -- Electricity Generator
                if bName == "ElectricityGenerator" and workerProficiency > 0 then
                    outProduction.fuel = outProduction.fuel + (2 * workerProficiency * bData.level)
                end
                
                -- Workshop
                if bName == "Workshop" and workerProficiency > 0 then
                    outProduction.ammo = outProduction.ammo + (2 * workerProficiency * bData.level)
                end
                
                -- Laboratory
                if bName == "Laboratory" and workerProficiency > 0 then
                    outProduction.meds = outProduction.meds + (2 * workerProficiency * bData.level)
                end
            end
        end
    end
    
    -- Apply Global Production Multiplier from Sandbox
    local sandboxProdMult = DynamicTrading.Config.GetSandboxMult("ProductionMult")
    for k, v in pairs(outProduction) do
        outProduction[k] = v * sandboxProdMult
    end
    
    return outProduction
end

return BuildingLogic

local VirtualStore = require "DT/Common/ColonyEconomy/VirtualStore/DT_VirtualStore"
local BuildingLogic = require "DT/Common/ColonyEconomy/Buildings/DT_BuildingLogic"
local HordeLogic = require "DT/Common/ColonyEconomy/Horde/DT_HordeLogic"
local FactionCollapse = require "DT/Common/Faction/TradingSys/Factions/DT_FactionCollapse"

local TownSim = {}

function TownSim.Process(faction, id, data)
    if not faction then return nil, false end
    local previousState = faction.state

    -- 1. Building Multipliers & Production
    local mults = BuildingLogic.GetGlobalMultipliers(faction)
    local buildingProd = BuildingLogic.ProcessBuildings(faction, id)
    
    -- 2. Horde Attack
    local attacked, casualties = HordeLogic.ProcessHorde(faction, id, data)

    -- 3. Passive Income (Wealth)
    local dailyRate = 50
    local stateMult = 1.0
    if faction.state == "Thriving" then stateMult = 1.2
    elseif faction.state == "Strained" then stateMult = 0.8
    elseif faction.state == "Struggling" then stateMult = 0.5
    elseif faction.state == "Collapsing" then stateMult = 0.1
    end
    
    -- Isolation Penalty (Fuel shortage)
    local isolatedMult = 1.0
    if faction.penalties and faction.penalties.isolated then
        isolatedMult = 0.5
        DynamicTrading.Log("Colony", "Penalty", "Isolation", faction.name .. " is ISOLATED! Income halved.")
    end

    local eventMult = 1.0
    if DynamicTrading.Events and DynamicTrading.Events.getPassiveIncomeMult then
        eventMult = DynamicTrading.Events.getPassiveIncomeMult(faction)
    end
    
    -- Note: mults.prodMult (Workshop bonus) affects resource production in ProductionLogic, 
    -- but here we apply it to wealth income as well if it's a "production multiplier".
    local totalIncomeMult = stateMult * eventMult * isolatedMult * mults.prodMult
    
    local income = math.floor(faction.memberCount * dailyRate * totalIncomeMult)
    faction.ColonyWealth = math.max(0, (faction.ColonyWealth or 0) + income)

    -- Phase 5: Resilience Bonus (Emergency Reserve)
    faction.emergencyReserve = faction.emergencyReserve or 0
    if (faction.consecutiveStableDays or 0) >= 30 and faction.ColonyWealth > 0 then
        local reserveAdd = math.floor(income * 0.1)
        local reserveCap = math.floor(faction.ColonyWealth * 0.2)
        if faction.emergencyReserve < reserveCap then
            faction.emergencyReserve = math.min(reserveCap, faction.emergencyReserve + reserveAdd)
        end
    end

    -- 4. Prioritized Auto-buy (Food > Water > Meds > Ammo > Fuel > Materials)
    if faction.ColonyWealth > 1000 and (faction.state == "Stable" or faction.state == "Thriving" or faction.state == "Strained") then
        local consumes = DynamicTrading.Config.Sim.BaseConsumption
        local resources = { "food", "water", "meds", "ammo", "fuel", "materials" }
        local buffers = { food = 7, water = 5, meds = 5, ammo = 5, fuel = 3, materials = 3 }

        for _, res in ipairs(resources) do
            local rate = consumes[res] or 0
            local target = 0
            if res == "fuel" or res == "materials" then
                target = rate * (buffers[res] or 3)
            else
                target = faction.memberCount * rate * (buffers[res] or 5)
            end

            if (faction.stockpile[res] or 0) < target then
                local missing = target - (faction.stockpile[res] or 0)
                local bought = VirtualStore.AutoBuy.AutoBuy(faction, res, missing)
                if (faction.ColonyWealth or 0) < 500 then break end -- Stop if wealth gets too low
            end
        end
    end

    -- 5. 5-Tier State Machine (Nuanced)
    local consumes = DynamicTrading.Config.Sim.BaseConsumption
    local daysOfFood = (faction.stockpile.food or 0) / math.max(1, (faction.memberCount * (consumes.food or 1)))
    
    local penaltyCount = 0
    if faction.penalties then
        for k, v in pairs(faction.penalties) do
            if v == true then penaltyCount = penaltyCount + 1 end
        end
    end

    if faction.starvationDays > 3 or (faction.buildings and faction.buildings.Barricade and faction.buildings.Barricade.hp <= 0 and (faction.stockpile.ammo or 0) <= 0) then
        faction.state = "Collapsing"
        faction.CollapseDays = (faction.CollapseDays or 0) + 1
        
        -- Burn emergency reserve to survive
        if faction.emergencyReserve > 0 and faction.ColonyWealth > 0 then
            local emergencySpend = math.min(faction.emergencyReserve, VirtualStore.Prices.GetPrice("food") * faction.memberCount)
            faction.emergencyReserve = math.max(0, faction.emergencyReserve - emergencySpend)
            faction.ColonyWealth = math.max(0, faction.ColonyWealth - emergencySpend)
            faction.starvationDays = math.max(0, faction.starvationDays - 1)
        end
    elseif faction.starvationDays > 0 or penaltyCount >= 3 then
        faction.state = "Struggling"
        faction.CollapseDays = 0
    elseif daysOfFood < 3 or penaltyCount >= 1 or (faction.ColonyWealth or 0) < 500 then
        faction.state = "Strained"
        faction.CollapseDays = 0
    elseif daysOfFood > 7 and penaltyCount == 0 and (faction.ColonyWealth or 0) > 5000 then
        faction.state = "Thriving"
        faction.CollapseDays = 0
    else
        faction.state = "Stable"
        faction.CollapseDays = 0
    end

    if faction.state == "Stable" or faction.state == "Thriving" then
        faction.consecutiveStableDays = (faction.consecutiveStableDays or 0) + 1
    else
        faction.consecutiveStableDays = 0
    end

    if faction.state ~= previousState then
        DynamicTrading.Log("Colony", "TownLogic", "State", faction.name .. " changed state: " .. tostring(previousState) .. " -> " .. faction.state)
        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            DynamicTrading.GameplayLogs.AddFactionEvent(id, DynamicTrading.GameplayEvents.STATE_CHANGED, {faction.state, tostring(previousState)})
        end
    end

    if faction.CollapseDays and faction.CollapseDays >= 3 then
        DynamicTrading.Log("Colony", "TownLogic", "Danger", faction.name .. " is on the VERGE OF COLLAPSE!")
        local cMult = 1.0
        if DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
            cMult = DynamicTrading.Events.GetFactionSystemModifier(faction, "townCollapseDamageMult") or 1.0
        end
        local collapseDamage = math.ceil(faction.memberCount * 0.15 * cMult)
        if collapseDamage < 1 then collapseDamage = 1 end
        
        local factionActive = true
        if faction.playerOwned and DynamicTrading_Factions.ApplyPlayerFactionCasualties then
            collapseDamage = DynamicTrading_Factions.ApplyPlayerFactionCasualties(id, collapseDamage, "Colony Collapse")
            faction = data[id]
            factionActive = faction ~= nil
        else
            faction.memberCount = math.max(0, faction.memberCount - collapseDamage)
            DynamicTrading_Roster.RemoveSoul(id, collapseDamage)
        end
        
        if factionActive and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            DynamicTrading.GameplayLogs.AddFactionEvent(id, DynamicTrading.GameplayEvents.FACTION_DYING, {})
        end

        if factionActive and (tonumber(faction.memberCount) or 0) <= 0 then
            FactionCollapse.CollapseFaction(id, faction, { reason = "town_collapse" })
            return faction, false, { mults = mults, buildingProd = buildingProd }
        end
    end

    return faction, true, { mults = mults, buildingProd = buildingProd }
end

return TownSim

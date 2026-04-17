-- ==============================================================================
-- Simulation/Simulation_TownFaction.lua
-- Logic: Auto town survival interactions, state machine, passive income.
-- ==============================================================================

local TownFactionSim = {}

function TownFactionSim.Process(faction, id, data)
    if not faction then return nil, false end

    -- 1. Passive Income
    local dailyRate = 50
    local stateMult = 1.0
    if faction.state == "Thriving" then stateMult = 1.2
    elseif faction.state == "Strained" then stateMult = 0.8
    elseif faction.state == "Struggling" then stateMult = 0.5
    elseif faction.state == "Collapsing" then stateMult = 0.1
    end
    
    local eventMult = 1.0
    if DynamicTrading.Events and DynamicTrading.Events.getPassiveIncomeMult then
        eventMult = DynamicTrading.Events.getPassiveIncomeMult(faction)
    end
    
    local income = math.floor(faction.memberCount * dailyRate * stateMult * eventMult)
    faction.ColonyWealth = math.max(0, (faction.ColonyWealth or 0) + income)

    -- 2. Auto-buy missing resources using ColonyWealth
    if faction.ColonyWealth > 1000 and (faction.state == "Stable" or faction.state == "Thriving" or faction.state == "Strained") then
        local consumes = DynamicTrading.Config.Sim.BaseConsumption
        local targetFood = faction.memberCount * (consumes.food or 1) * 7 -- 7 days buffer
        if (faction.stockpile.food or 0) < targetFood then
            local missing = targetFood - faction.stockpile.food
            local costPerFood = 10 -- Base auto-buy cost
            local eventCostMult = 1.0
            if DynamicTrading.Events and DynamicTrading.Events.getAutoBuyPriceModifier then
                eventCostMult = DynamicTrading.Events.getAutoBuyPriceModifier(faction)
            end
            local autoCost = costPerFood * eventCostMult
            local affordable = math.floor(faction.ColonyWealth / autoCost)
            local bought = math.min(missing, affordable)
            if bought > 0 then
                faction.ColonyWealth = math.floor(faction.ColonyWealth - (bought * autoCost))
                faction.stockpile.food = math.floor(faction.stockpile.food + bought)
                DynamicTrading.Log("Colony", "Economy", "Sim", "Town " .. faction.name .. " auto-bought " .. bought .. " food for $" .. math.floor(bought * autoCost))
            end
        end
    end

    -- 3. 5-Tier State Machine
    local consumes = DynamicTrading.Config.Sim.BaseConsumption
    local daysOfFood = (faction.stockpile.food or 0) / math.max(1, (faction.memberCount * (consumes.food or 1)))

    if faction.starvationDays > 3 then
        faction.state = "Collapsing"
        faction.CollapseDays = (faction.CollapseDays or 0) + 1
    elseif faction.starvationDays > 0 then
        faction.state = "Struggling"
        faction.CollapseDays = 0
    elseif daysOfFood < 3 or (faction.ColonyWealth or 0) < 500 then
        faction.state = "Strained"
        faction.CollapseDays = 0
    elseif daysOfFood > 7 and (faction.ColonyWealth or 0) > 5000 then
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

    return faction, true
end

return TownFactionSim

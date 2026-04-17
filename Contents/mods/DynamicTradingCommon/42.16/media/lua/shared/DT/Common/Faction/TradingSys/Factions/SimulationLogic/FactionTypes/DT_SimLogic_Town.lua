-- ==============================================================================
-- Simulation/Simulation_TownFaction.lua
-- Logic: Auto town survival interactions, state machine, passive income.
-- ==============================================================================

local VirtualStore = require "DT/Common/ColonyEconomy/VirtualStore/DT_VirtualStore"
local TownSim = {}

function TownSim.Process(faction, id, data)
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

    -- Phase 5: Resilience Bonus (Emergency Reserve)
    faction.emergencyReserve = faction.emergencyReserve or 0
    if (faction.consecutiveStableDays or 0) >= 30 and faction.ColonyWealth > 0 then
        local reserveAdd = math.floor(income * 0.1)
        local reserveCap = math.floor(faction.ColonyWealth * 0.2)
        if faction.emergencyReserve < reserveCap then
            faction.emergencyReserve = math.min(reserveCap, faction.emergencyReserve + reserveAdd)
        end
    end

    -- 2. Auto-buy missing resources using ColonyWealth
    if faction.ColonyWealth > 1000 and (faction.state == "Stable" or faction.state == "Thriving" or faction.state == "Strained") then
        local consumes = DynamicTrading.Config.Sim.BaseConsumption
        local targetFood = faction.memberCount * (consumes.food or 1) * 7 -- 7 days buffer
        if (faction.stockpile.food or 0) < targetFood then
            local missing = targetFood - faction.stockpile.food
            VirtualStore.AutoBuy.AutoBuy(faction, "food", missing)
        end
    end

    -- 3. 5-Tier State Machine
    local consumes = DynamicTrading.Config.Sim.BaseConsumption
    local daysOfFood = (faction.stockpile.food or 0) / math.max(1, (faction.memberCount * (consumes.food or 1)))

    if faction.starvationDays > 3 then
        faction.state = "Collapsing"
        faction.CollapseDays = (faction.CollapseDays or 0) + 1
        
        -- Burn emergency reserve to survive
        if faction.emergencyReserve > 0 and faction.ColonyWealth > 0 then
            local emergencySpend = math.min(faction.emergencyReserve, VirtualStore.Prices.GetPrice("food") * faction.memberCount)
            faction.emergencyReserve = math.max(0, faction.emergencyReserve - emergencySpend)
            faction.ColonyWealth = math.max(0, faction.ColonyWealth - emergencySpend)
            -- Reset starvation partially since they spent reserves
            faction.starvationDays = math.max(0, faction.starvationDays - 1)
        end
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

return TownSim

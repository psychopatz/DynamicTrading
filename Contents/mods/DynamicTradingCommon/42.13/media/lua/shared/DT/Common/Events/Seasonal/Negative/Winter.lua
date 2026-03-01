require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- SEASONAL NEGATIVE: WINTER
-- =============================================================================

DynamicTrading.Events.Register("Winter", {
    name = "Winter Scarcity",
    sentiment = "Negative",
    type = "seasonal", 
    description = "It's freezing. Warm clothes and heat sources are essential.",
    condition = function() 
        if not (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.AllowSeasonalEvents) then return false end
        return ClimateManager:getInstance():getSeasonName() == "Winter" 
    end,
    effects = {
        ["Fresh"] = { price = 3.0, vol = 0.1 },
        ["Fuel"] = { price = 1.5 }, 
        ["Winter"] = { price = 2.5, vol = 1.0 },
        ["Material"] = { price = 1.5 },
        ["Camping"] = { price = 1.2 }
    },
    inject = { ["Winter"] = 3, ["Survival"] = 2 },
    factionImpact = {
        stockpileAdd = { food = -200, fuel = -200 }
    }
})

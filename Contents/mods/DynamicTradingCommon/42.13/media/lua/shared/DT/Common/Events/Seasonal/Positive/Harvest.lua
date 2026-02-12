require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- SEASONAL POSITIVE: HARVEST
-- =============================================================================

DynamicTrading.Events.Register("Harvest", {
    name = "Great Harvest",
    sentiment = "Positive",
    type = "seasonal",
    description = "Farms are overflowing. Produce is cheap.",
    condition = function() 
        if not (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.AllowSeasonalEvents) then return false end
        return ClimateManager:getInstance():getSeasonName() == "Autumn" 
    end,
    effects = {
        ["Vegetable"] = { price = 0.4, vol = 3.0 },
        ["Fruit"] = { price = 0.5, vol = 2.0 },
        ["Farming"] = { price = 1.5, vol = 0.5 },
        ["Pickle"] = { price = 0.8, vol = 2.0 }
    },
    inject = { ["Vegetable"] = 5, ["Pickle"] = 2 },
    factionImpact = {
        stockpileAdd = { food = 1000 }
    }
})

require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- SEASONAL NEGATIVE: HEATWAVE
-- =============================================================================

DynamicTrading.Events.Register("Heatwave", {
    name = "Heatwave",
    sentiment = "Negative",
    type = "seasonal",
    description = "A scorching heatwave. Hydration is key.",
    condition = function()
        if not (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.AllowSeasonalEvents) then return false end
        return ClimateManager:getInstance():getSeasonName() == "Summer"
    end,
    effects = {
        ["Container.Liquid"] = { price = 2.0 }, 
        ["Food.Drink.NonAlcoholic"] = { price = 1.5 },
        ["Clothing"] = { price = 0.5 },
        ["Theme.Winter"] = { price = 0.1, vol = 0.0 }
    },
    factionImpact = {
        stabilityAdd = -2,
        stockpileAdd = { meds = -50 }
    }
})

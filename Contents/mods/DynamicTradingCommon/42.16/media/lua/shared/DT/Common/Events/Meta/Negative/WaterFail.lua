require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META NEGATIVE: WATER SHUTOFF
-- =============================================================================

DynamicTrading.Events.Register("WaterFail", {
    name = "Drought (Water Shutoff)",
    sentiment = "Negative",
    type = "meta", 
    description = "Municipal water is gone. Bottled water is liquid gold.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > (SandboxVars.WaterShutModifier or 14)
    end,
    effects = {
        ["Container.Liquid"] = { price = 5.0, vol = 0.2 },
        ["Food.Drink.NonAlcoholic"] = { price = 2.0 },
        ["Medical.Healthcare"] = { price = 1.5 }
    },
    factionImpact = {
        stabilityAdd = -3
    }
})

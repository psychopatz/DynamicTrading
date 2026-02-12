require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META NEGATIVE: WATER SHUTOFF
-- =============================================================================

DynamicTrading.Events.Register("WaterFail", {
    name = "Drought (Water Shutoff)",
    type = "meta", 
    description = "Municipal water is gone. Bottled water is liquid gold.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > (SandboxVars.WaterShutModifier or 14)
    end,
    effects = {
        ["Water"] = { price = 5.0, vol = 0.2 },
        ["Drink"] = { price = 2.0 },
        ["Hygiene"] = { price = 1.5 }
    }
})

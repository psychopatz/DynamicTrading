require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META NEGATIVE: SANITATION FAILURE
-- =============================================================================

DynamicTrading.Events.Register("HygieneCollapse", {
    name = "Sanitation Failure",
    type = "meta",
    description = "Soap supplies are exhausted. Infection risks are rising.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 60
    end,
    effects = {
        ["Hygiene"] = { price = 4.0, vol = 0.1 },   -- Soap is incredibly expensive
        ["Clean"] = { price = 3.0 },                -- Bleach
        ["Medical"] = { price = 1.2 },              -- Antibiotics demand up
        ["Chemical"] = { price = 2.0 }              -- To make homemade soap
    }
})

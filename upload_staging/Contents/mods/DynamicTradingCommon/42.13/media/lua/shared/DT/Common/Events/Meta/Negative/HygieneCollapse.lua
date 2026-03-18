require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META NEGATIVE: SANITATION FAILURE
-- =============================================================================

DynamicTrading.Events.Register("HygieneCollapse", {
    name = "Sanitation Failure",
    sentiment = "Negative",
    type = "meta",
    description = "Soap supplies are exhausted. Infection risks are rising.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 60
    end,
    effects = {
        ["Medical.Healthcare"] = { price = 4.0, vol = 0.1 },   -- Soap is incredibly expensive
        ["Container.Liquid"] = { price = 3.0 },                -- Bleach
        ["Medical"] = { price = 1.2 },              -- Antibiotics demand up
        ["Resource.Material.Adhesive"] = { price = 2.0 }              -- To make homemade soap
    },
    factionImpact = {
        stockpileAdd = { meds = -200 },
        stabilityAdd = -5
    }
})

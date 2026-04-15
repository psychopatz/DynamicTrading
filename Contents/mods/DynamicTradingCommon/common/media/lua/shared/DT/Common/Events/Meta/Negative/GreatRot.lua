require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META NEGATIVE: THE GREAT ROT
-- =============================================================================

DynamicTrading.Events.Register("GreatRot", {
    name = "The Great Rot",
    sentiment = "Negative",
    type = "meta",
    description = "Refrigeration is a memory. Scavenging fresh food is no longer possible.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 30
    end,
    effects = {
        ["Food.Perishable"] = { price = 5.0, vol = 0.05 },    -- Traders almost never have it
        ["Quality.Waste"] = { price = 0.0 },               -- Worthless
        ["Food.Cooking.Spice"] = { price = 2.0 },                 -- If item exists (Spice)
        ["Food.Cooking.Ingredient"] = { price = 1.5 }                 -- To mask the taste of bad meat
    },
    factionImpact = {
        stockpileAdd = { food = -1000 }
    }
})

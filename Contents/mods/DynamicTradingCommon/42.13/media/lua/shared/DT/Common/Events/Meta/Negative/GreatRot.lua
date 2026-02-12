-- =============================================================================
-- META NEGATIVE: THE GREAT ROT
-- =============================================================================

DynamicTrading.Events.Register("GreatRot", {
    name = "The Great Rot",
    type = "meta",
    description = "Refrigeration is a memory. Scavenging fresh food is no longer possible.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 30
    end,
    effects = {
        ["Fresh"] = { price = 5.0, vol = 0.05 },    -- Traders almost never have it
        ["Rotten"] = { price = 0.0 },               -- Worthless
        ["Salt"] = { price = 2.0 },                 -- If item exists (Spice)
        ["Spice"] = { price = 1.5 }                 -- To mask the taste of bad meat
    }
})

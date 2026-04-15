require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META NEGATIVE: SUPPLY CHAIN COLLAPSE
-- =============================================================================

DynamicTrading.Events.Register("ManufacturingHalt", {
    name = "Manufacturing Halt",
    sentiment = "Negative",
    type = "meta",
    description = "Canned goods are no longer 'common'. Preservation supplies are vital.",
    condition = function()
        return GameTime:getInstance():getNightsSurvived() > 120
    end,
    effects = {
        ["Food.NonPerishable.Canned"] = { price = 2.5, vol = 0.4 },    -- Rare luxury
        ["Building.Garden"] = { price = 0.8, vol = 2.0 },   -- Everyone is farming now
        ["Food.Cooking.Spice"] = { price = 3.0 },                -- Salt/Vinegar for jars
        ["Resource.Material.Packaging"] = { price = 3.0, vol = 0.5 }, -- Jars/Lids
        ["Food.Perishable"] = { price = 1.0 }                 -- Normal price, but demand is high
    },
    inject = { ["Building.Garden"] = 4 }, -- Traders stock seeds to survive
    factionImpact = {
        stockpileAdd = { food = -200 }
    }
})

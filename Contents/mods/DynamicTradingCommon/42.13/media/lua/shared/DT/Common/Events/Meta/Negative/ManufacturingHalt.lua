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
        ["Canned"] = { price = 2.5, vol = 0.4 },    -- Rare luxury
        ["Farming"] = { price = 0.8, vol = 2.0 },   -- Everyone is farming now
        ["Spice"] = { price = 3.0 },                -- Salt/Vinegar for jars
        ["Preservation"] = { price = 3.0, vol = 0.5 }, -- Jars/Lids
        ["Fresh"] = { price = 1.0 }                 -- Normal price, but demand is high
    },
    inject = { ["Farming"] = 4 } -- Traders stock seeds to survive
})

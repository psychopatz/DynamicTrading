require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- META POSITIVE: NATURE'S RECLAMATION
-- =============================================================================

DynamicTrading.Events.Register("NatureReclamation", {
    name = "Overgrowth",
    sentiment = "Positive",
    type = "meta",
    description = "Vegetation is reclaiming the cities. Wood is abundant; clear paths are not.",
    condition = function() 
        return GameTime:getInstance():getNightsSurvived() > 100
    end,
    effects = {
        ["Resource.Material.Wood"] = { price = 0.2, vol = 5.0 },      -- Trees are everywhere
        ["Weapon.Melee.Blade"] = { price = 1.5 },                -- Machetes needed to clear vines
        ["Medical.Healthcare.Botanical"] = { price = 0.5, vol = 3.0 },      -- Foraging is easier
        ["Food.Perishable.Meat"] = { vol = 1.5 }                    -- Animals entering cities
    },
    factionImpact = {
        stockpileAdd = { food = 200 }
    }
})

require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: FORTIFICATION EFFORT
-- =============================================================================

DynamicTrading.Events.Register("ConstructionBoom", {
    name = "Construction Boom",
    sentiment = "Positive",
    type = "flash",
    description = "Everyone is reinforcing their bases.",
    canSpawn = function() return true end,
    system = { passiveIncomeMult = 1.2, traderBudgetMult = 1.1 },
    effects = {
        ["Resource.Material"] = { price = 2.0, vol = 0.5 },
        ["Resource.Material.Wood"] = { price = 1.8 },
        ["Resource.Material.Hardware"] = { price = 1.8 },
        ["Tool"] = { price = 1.5 },
        ["Clothing.Armor.Heavy"] = { price = 1.5 }
    },
    factionImpact = {
        wealthAdd = 200,
        stabilityAdd = 2
    }
})

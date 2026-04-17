require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: MILITARY SURPLUS
-- =============================================================================

DynamicTrading.Events.Register("MilitarySurplus", {
    name = "Military Surplus",
    sentiment = "Positive",
    type = "flash",
    description = "A military bunker was raided. Gear is everywhere.",
    canSpawn = function() return true end,
    system = { globalStock = 1.5 , traderBudgetMult = 1.2, autoBuyPriceMult = 0.8},
    effects = {
        ["Weapon.Ranged.Firearm"] = { price = 0.6, vol = 2.0 },
        ["Weapon.Ranged.Ammo"] = { price = 0.5, vol = 3.0 },
        ["Theme.Militia"] = { price = 0.7, vol = 2.0 },
        ["Clothing.Tactical"] = { price = 0.7 }
    },
    inject = { ["Weapon.Ranged.Ammo"] = 5, ["Theme.Militia"] = 3 },
    factionImpact = {
        stockpileAdd = { food = 200, ammo = 50, meds = 50 }
    }
})

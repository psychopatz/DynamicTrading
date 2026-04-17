require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH NEGATIVE: FACTION CONFLICT
-- =============================================================================

DynamicTrading.Events.Register("Warzone", {
    name = "Active Warzone",
    sentiment = "Negative",
    type = "flash",
    description = "War has broken out. Traders are hiding, ammo is scarce.",
    canSpawn = function() return (SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.AllowHardcoreEvents) end,
    system = { traderLimit = 0.5 , traderBudgetMult = 0.5, passiveIncomeMult = 0.5, autoBuyPriceMult = 1.5},
    effects = {
        ["Weapon.Ranged.Firearm"] = { price = 2.5, vol = 0.5 },
        ["Weapon.Ranged.Ammo"] = { price = 3.0, vol = 0.2 },
        ["Medical"] = { price = 1.5 },
        ["Clothing.Armor"] = { price = 2.0 }
    },
    factionImpact = {
        memberCountPct = -0.10,
        stockpileAdd = { ammo = -100, meds = -50 },
        stabilityAdd = -10
    }
})

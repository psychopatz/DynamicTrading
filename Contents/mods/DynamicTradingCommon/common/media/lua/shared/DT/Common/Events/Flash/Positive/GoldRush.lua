require "DT/Common/Events/DT_EventManager"

-- =============================================================================
-- FLASH POSITIVE: GOLD PANIC
-- =============================================================================

DynamicTrading.Events.Register("GoldRush", {
    name = "Gold Panic",
    sentiment = "Positive",
    type = "flash",
    description = "Survivors are hoarding precious metals.",
    canSpawn = function() return true end,
    system = { passiveIncomeMult = 1.4, traderBudgetMult = 1.3 },
    effects = {
        ["Resource.Material.MetalFamily.Gold"] = { price = 3.0 },
        ["Resource.Material.MetalFamily.Silver"] = { price = 2.5 },
        ["Clothing.Accessory.Jewelry"] = { price = 2.0 },
        ["Quality.Luxury"] = { price = 1.5 }
    },
    factionImpact = {
        wealthAdd = 2000,
        stabilityAdd = -1
    }
})

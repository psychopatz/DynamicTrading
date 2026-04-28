require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then
    DynamicTrading.RegisterArchetype("Bandit", {
    module = "DynamicTradingCommon",
        name = "Bandit",
        preferredFactionID = "Bandits",
        allowedFactions = { "Bandits" },
        disableBuyTab = true,
        disableSellTab = true,
        allocations = {
            { tags = { "Weapon.Melee" }, count = 4 },
            { tags = { "Weapon.Ammo" }, count = 2 },
            { tags = { "Medical.General" }, count = 2 },
            { tags = { "Food.Preserved" }, count = 2 },
            { tags = { "Container" }, count = 1 },
            { module = "DynamicTradingCommon",  item = "Base.MoneyBundle", count = 1 },
        },
        expertTags = { "Weapon.Melee", "Weapon.Ranged", "Medical.General", "Container" },
        wants = {
            ["Weapon.Melee"] = 1.35,
            ["Weapon.Ranged"] = 1.3,
            ["Medical.General"] = 1.25,
            ["Food.Preserved"] = 1.15,
            ["Clothing.Accessory.Utility"] = 1.15,
        },
        forbid = { "Building.Furniture.General", "Building.Garden", "Tool.Farming" }
    })
end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Smuggler", {
    module = "DynamicTradingCommon",
    name = "Night Trader",
    allocations = {
        { tags={"Medical.General.Drug"}, count = 8 },
        { tags={"Food.Drink.Alcohol"}, count = 8 },
        { tags={"Quality.Luxury"}, count = 5 },
        { tags={"Rarity.Rare"}, count = 4 },
        { tags={"Weapon.Ranged"}, count = 3 },
        { module = "DynamicTradingCommon",  item = "Base.CigarettePack", count = 5 }
    },
    expertTags = { "Quality.Luxury", "Quality.Luxury", "Rarity.Rare", "Rarity.Rare", "Weapon.Ranged" },
    wants = {
        ["Medical.General.Drug"] = 1.4,
        ["Food.Drink.Alcohol"] = 1.35,
        ["Weapon.Part"] = 1.3,
        ["Electronics"] = 1.25,
        ["Weapon.Ranged.Ammo"] = 1.2
    },
    forbid = { "Quality.Waste", "Resource.Material.General", "Building.Garden", "Food.LowQuality", "Clothing" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Smuggler", {
    name = "Night Trader",
    allocations = {
        { tags={"Food.Drink.Alcohol"}, count = 5 },
        { tags={"Medical.General.Drug"}, count = 5 },
        { tags={"Quality.Luxury"}, count = 3 },
        { tags={"Rarity.Rare"}, count = 3 }
    },
    wants = {
        ["Weapon.Ranged.Firearm"] = 1.5,
        ["Weapon.Ranged.Ammo"] = 1.3,
        ["Clothing.Accessory.Jewelry"] = 1.4
    },
    forbid = { "Quality.Waste", "Resource.Material.General", "Building.Garden" }
})

end

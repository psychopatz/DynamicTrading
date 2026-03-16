require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Chef", {
    name = "Chef",
    allocations = {
        { tags={"Food.Cooking"}, count = 6 },
        { tags={"Food"}, count = 6 },
        { tags={"Food.Perishable"}, count = 4 },
        { tags={"Food.Cooking.Spice"}, count = 3 },
        { tags={"Food.Cooking.Ingredient"}, count = 3 }
    },
    expertTags = { "Food", "Food.Cooking.Spice", "Food.Cooking" },
    wants = {
        ["Resource.Material.Packaging"] = 1.5,
        ["Resource.Fuel"] = 1.2,
        ["Container.Liquid"] = 1.2
    },
    forbid = { "Weapon", "Weapon.Ranged.Ammo", "Quality.Waste" }
})

end

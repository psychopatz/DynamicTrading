require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Chef", {
    name = "Chef",
    allocations = {
        { tags={"Food.Cooking"}, count = 6 },
        { tags={"Food"}, count = 6 },
        { tags={"Food.Perishable"}, count = 4 },
        { tags={"Food.NonPerishable.Spice"}, count = 3 },
        { tags={"Food.Cooking.Ingredient"}, count = 3 }
    },
    expertTags = { "Food", "Spice" },
    wants = {
        ["Resource.Storage.Preservation"] = 1.5,
        ["Fuel"] = 1.2,
        ["Container.Fluid"] = 1.2
    },
    forbid = { "Weapon", "Weapon.Ranged.Ammo", "Quality.Junk" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Chef", {
    name = "Chef",
    allocations = {
        { tags={"Food.Cooking"}, count = 6 },
        { tags={"Food.General"}, count = 6 },
        { tags={"Food.Perishable"}, count = 4 },
        { tags={"Food.Spice"}, count = 3 },
        { tags={"Food.Cooking.Ingredient"}, count = 3 }
    },
    expertTags = { "Food.General", "Food.Spice", "Food.Cooking" },
    wants = {
        ["Resource.Storage.Preservation"] = 1.5,
        ["Resource.Fuel"] = 1.2,
        ["Container.Fluid"] = 1.2
    },
    forbid = { "Weapon.General", "Weapon.Ranged.Ammo", "Quality.Waste" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Farmer", {
    name = "Farmer",
    allocations = {
        { tags={"Food.Perishable.Vegetable"}, count = 6 },
        { tags={"Food.Perishable.Fruit"}, count = 4 },
        { tags={"Food.Perishable.Grain"}, count = 4 },
        { tags={"Theme.Farming"}, count = 3 },
        { tags={"Tool.Farming"}, count = 2 }
    },
    expertTags = { "Vegetable", "Fruit", "Grain", "Farming" },
    wants = {
        ["Tool"] = 1.3,
        ["Container.Fluid"] = 1.2,
        ["Fuel"] = 1.2
    },
    forbid = { "Weapon.Ranged.Firearm", "Weapon.Ranged.Ammo", "Electronics" }
})

end

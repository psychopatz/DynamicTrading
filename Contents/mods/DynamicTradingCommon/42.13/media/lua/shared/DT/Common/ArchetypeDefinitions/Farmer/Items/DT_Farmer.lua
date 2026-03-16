require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Farmer", {
    name = "Farmer",
    allocations = {
        { tags={"Food.Perishable.Vegetable"}, count = 6 },
        { tags={"Food.Perishable.Fruit"}, count = 4 },
        { tags={"Food.Perishable.Grain"}, count = 4 },
        { tags={"Building.Garden"}, count = 3 },
        { tags={"Tool.Farming"}, count = 2 }
    },
    expertTags = { "Food.Perishable.Vegetable", "Food.Perishable.Fruit", "Food.Perishable.Grain", "Tool.Farming" },
    wants = {
        ["Tool.General"] = 1.3,
        ["Container.Liquid"] = 1.2,
        ["Resource.Fuel"] = 1.2
    },
    forbid = { "Weapon.Ranged.Firearm", "Weapon.Ranged.Ammo", "Electronics" }
})

end

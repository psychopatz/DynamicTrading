require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("RoadWarrior", {
    name = "Road Warrior",
    allocations = {
        { tags={"Theme.Primitive"}, count = 6 },
        { tags={"Resource.Parts"}, count = 5 },
        { tags={"Resource.Fuel"}, count = 5 },
        { tags={"Clothing.Protective"}, count = 3 }
    },
    wants = {
        ["Tool.General"] = 1.4,
        ["Weapon.Ranged.Firearm"] = 1.3,
        ["Food.NonPerishable.Canned"] = 1.2
    },
    forbid = { "Building.Furniture.Decor", "Misc.General", "Tool.Fragile" }
})

end

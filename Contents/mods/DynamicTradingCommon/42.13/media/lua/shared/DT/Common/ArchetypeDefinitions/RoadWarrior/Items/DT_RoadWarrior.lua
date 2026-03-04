require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("RoadWarrior", {
    name = "Road Warrior",
    allocations = {
        { tags={"Quality.Primitive"}, count = 6 },
        { tags={"Vehicle.Part"}, count = 5 },
        { tags={"Resource.Fuel"}, count = 5 },
        { tags={"Clothing.Armor"}, count = 3 }
    },
    wants = {
        ["Tool.Crafting.Mechanic"] = 1.4,
        ["Weapon.Ranged.Firearm"] = 1.3,
        ["Food.Perishable.Canned"] = 1.2
    },
    forbid = { "Luxury.Decor", "Junk.Toy", "Fragile" }
})

end

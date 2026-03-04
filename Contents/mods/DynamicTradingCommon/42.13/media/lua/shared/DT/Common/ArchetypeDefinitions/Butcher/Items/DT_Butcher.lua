require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Butcher", {
    name = "Butcher",
    allocations = {
        { tags={"Food.Meat"}, count = 8 },
        { tags={"Tool.Resource.Butcher"}, count = 4 },
        { tags={"Container"}, count = 2 }
    },
    wants = {
        ["Weapon.Ranged.Ammo"] = 1.4,
        ["Blade"] = 1.3,
        ["Spice"] = 1.2
    },
    forbid = { "Vegetable", "Fruit", "Literature.Book" }
})

end

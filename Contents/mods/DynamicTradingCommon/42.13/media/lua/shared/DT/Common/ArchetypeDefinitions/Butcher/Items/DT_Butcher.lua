require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Butcher", {
    name = "Butcher",
    allocations = {
        { tags={"Food.Perishable.Meat"}, count = 8 },
        { tags={"Tool.Cookware"}, count = 4 },
        { tags={"Container.Bag.Cooler"}, count = 2 },
        { tags={"Weapon.Melee.Blade"}, count = 1 }
    },
    wants = {
        ["Weapon.Ranged.Ammo"] = 1.4,
        ["Weapon.Melee.Blade"] = 1.3,
        ["Food.Cooking.Spice"] = 1.2
    },
    forbid = { "Food.Perishable.Vegetable", "Food.Perishable.Fruit", "Literature.Book" }
})

end

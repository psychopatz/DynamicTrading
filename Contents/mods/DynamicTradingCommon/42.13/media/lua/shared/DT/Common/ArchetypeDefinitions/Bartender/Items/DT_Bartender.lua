require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Bartender", {
    name = "Barkeep",
    allocations = {
        { tags={"Food.Drink.Alcohol"}, count = 8 },
        { tags={"Food.Drink"}, count = 6 },
        { tags={"Resource.Material.Glass"}, count = 4 },
        { tags={"Luxury.Fun"}, count = 2 }
    },
    wants = {
        ["Fruit"] = 1.3,
        ["Tool.Cleaning"] = 1.2,
        ["Quality.Junk"] = 1.1
    },
    forbid = { "Weapon", "Weapon.Ranged.Ammo" }
})

end

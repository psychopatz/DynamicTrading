require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Bartender", {
    name = "Barkeep",
    allocations = {
        { tags={"Food.Drink.Alcohol"}, count = 8 },
        { tags={"Food.Drink.NonAlcoholic"}, count = 6 },
        { tags={"Resource.Material.Glass"}, count = 4 },
        { tags={"Misc.General"}, count = 2 }
    },
    wants = {
        ["Food.Perishable.Fruit"] = 1.3,
        ["Tool.Cleaning.General"] = 1.2,
        ["Quality.Waste"] = 1.1
    },
    forbid = { "Weapon.General", "Weapon.Ranged.Ammo" }
})

end

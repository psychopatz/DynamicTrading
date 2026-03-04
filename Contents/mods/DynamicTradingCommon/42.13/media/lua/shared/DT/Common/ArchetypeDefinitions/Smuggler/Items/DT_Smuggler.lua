require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Smuggler", {
    name = "Night Trader",
    allocations = {
        { tags={"Food.Drink.Alcohol"}, count = 5 },
        { tags={"Medical.Tobacco"}, count = 5 },
        { tags={"Luxury"}, count = 3 },
        { tags={"Quality.Illegal"}, count = 3 }
    },
    wants = {
        ["Weapon.Ranged.Firearm"] = 1.5,
        ["Weapon.Ranged.Ammo"] = 1.3,
        ["Jewelry"] = 1.4
    },
    forbid = { "Quality.Junk", "Resource.Material", "Theme.Farming" }
})

end

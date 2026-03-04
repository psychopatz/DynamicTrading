require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Survivalist", {
    name = "Prepper",
    allocations = {
        { tags={"Food.Perishable.Canned"}, count = 6 },
        { tags={"Theme.Survival"}, count = 5 },
        { tags={"Weapon.Ranged.Ammo"}, count = 4 },
        { tags={"Electronics.Battery"}, count = 2 }
    },
    wants = {
        ["Weapon"] = 1.3,
        ["Fuel"] = 1.5,
        ["Electronics.Generator"] = 1.4
    },
    forbid = { "Food.Perishable", "Luxury", "Junk.Toy" }
})

end

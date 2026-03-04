require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Survivalist", {
    name = "Prepper",
    allocations = {
        { tags={"Food.NonPerishable.Canned"}, count = 6 },
        { tags={"Theme.Survival"}, count = 5 },
        { tags={"Weapon.Ranged.Ammo"}, count = 4 },
        { tags={"Resource.Material.Utility"}, count = 2 }
    },
    wants = {
        ["Weapon.General"] = 1.3,
        ["Resource.Fuel"] = 1.5,
        ["Appliance.Generator"] = 1.4
    },
    forbid = { "Food.Perishable", "Quality.Luxury", "Misc.General" }
})

end

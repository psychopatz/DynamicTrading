require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Musician", {
    name = "DJ / Musician",
    allocations = {
        { tags={"Literature.Media"}, count = 10 },
        { tags={"Electronics.General"}, count = 4 },
        { tags={"Misc.General"}, count = 4 },
        { tags={"Theme.Leisure"}, count = 2 }
    },
    wants = {
        ["Resource.Material.Utility"] = 1.5,
        ["Appliance.Generator"] = 1.2,
        ["Food.Drink.Alcohol"] = 1.2
    },
    forbid = { "Weapon.General", "Medical.General", "Theme.Farming" }
})

end

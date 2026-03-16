require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Musician", {
    name = "DJ / Musician",
    allocations = {
        { tags={"Literature.Media"}, count = 10 },
        { tags={"Electronics"}, count = 4 },
        { tags={"Misc.General"}, count = 4 },
        { tags={"Electronics.Gadget.Audio"}, count = 2 }
    },
    wants = {
        ["Resource.Craftable"] = 1.5,
        ["Electronics.PowerGenerator"] = 1.2,
        ["Food.Drink.Alcohol"] = 1.2
    },
    forbid = { "Weapon", "Medical.General", "Building.Garden" }
})

end

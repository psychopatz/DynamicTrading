require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Designer", {
    name = "Home Stager",
    allocations = {
        { tags={"Luxury.Decor"}, count = 10 },
        { tags={"Resource.Material.Build"}, count = 4 },
        { tags={"Electronics.Component.Light"}, count = 4 },
        { tags={"Container.Organizer"}, count = 3 }
    },
    wants = {
        ["Tool.Cleaning"] = 1.3,
        ["Resource.Textile"] = 1.2,
        ["Paint"] = 1.1
    },
    forbid = { "Weapon", "Junk.Trash", "Quality.Junk" }
})

end

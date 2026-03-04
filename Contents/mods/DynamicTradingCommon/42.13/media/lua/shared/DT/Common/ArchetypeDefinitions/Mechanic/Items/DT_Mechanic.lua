require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Mechanic", {
    name = "Mechanic",
    allocations = {
        { tags={"Vehicle.Part"}, count = 8 },
        { tags={"Tool.Crafting.Mechanic"}, count = 5 },
        { tags={"Resource.Fuel"}, count = 3 },
        { tags={"Tool"}, count = 4 }
    },
    expertTags = { "CarPart", "Mechanic" },
    wants = {
        ["Electronics"] = 1.3,
        ["Quality.Junk"] = 1.1,
        ["Drink"] = 1.2
    },
    forbid = { "Clothing", "Medical", "Theme.Farming" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Mechanic", {
    name = "Mechanic",
    allocations = {
        { tags={"Vehicle.Part"}, count = 8 },
        { tags={"Tool.Crafting.Mechanic"}, count = 5 },
        { tags={"Resource.Fuel"}, count = 3 },
        { tags={"Tool.General"}, count = 4 }
    },
    expertTags = { "Vehicle.Part", "Tool.Crafting.Mechanic" },
    wants = {
        ["Electronics.General"] = 1.3,
        ["Quality.Waste"] = 1.1,
        ["Food.Drink"] = 1.2
    },
    forbid = { "Clothing.General", "Medical.General", "Theme.Farming" }
})

end

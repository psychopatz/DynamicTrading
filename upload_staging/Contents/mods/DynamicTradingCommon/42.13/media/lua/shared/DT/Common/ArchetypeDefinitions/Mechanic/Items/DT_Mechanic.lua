require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Mechanic", {
    name = "Mechanic",
    allocations = {
        { tags={"Resource.Parts"}, count = 8 },
        { tags={"Tool.General"}, count = 5 },
        { tags={"Resource.Fuel"}, count = 3 },
        { tags={"Tool.General"}, count = 4 }
    },
    expertTags = { "Resource.Parts", "Tool.General" },
    wants = {
        ["Electronics"] = 1.3,
        ["Quality.Waste"] = 1.1,
        ["Food.Drink"] = 1.2
    },
    forbid = { "Clothing", "Medical.General", "Building.Garden" }
})

end

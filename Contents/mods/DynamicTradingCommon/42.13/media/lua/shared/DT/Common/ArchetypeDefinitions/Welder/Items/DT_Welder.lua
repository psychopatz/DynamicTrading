require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Welder", {
    name = "Metalworker",
    allocations = {
        { tags={"Resource.Material.Metal"}, count = 8 },
        { tags={"Tool.Smithing"}, count = 6 },
        { tags={"Tool.General"}, count = 4 }
    },
    wants = {
        ["Resource.Fuel"] = 2.0,
        ["Electronics.General"] = 1.2,
        ["Quality.Heavy"] = 1.3
    },
    forbid = { "Theme.Farming", "Bedding" }
})

end

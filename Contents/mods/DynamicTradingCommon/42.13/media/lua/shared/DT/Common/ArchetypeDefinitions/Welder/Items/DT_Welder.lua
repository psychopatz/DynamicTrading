require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Welder", {
    name = "Metalworker",
    allocations = {
        { tags={"Resource.Material.Metal"}, count = 8 },
        { tags={"Tool.Smithing"}, count = 6 },
        { tags={"Tool"}, count = 4 }
    },
    wants = {
        ["Fuel"] = 2.0,
        ["Electronics"] = 1.2,
        ["Quality.Heavy"] = 1.3
    },
    forbid = { "Theme.Farming", "Bedding" }
})

end

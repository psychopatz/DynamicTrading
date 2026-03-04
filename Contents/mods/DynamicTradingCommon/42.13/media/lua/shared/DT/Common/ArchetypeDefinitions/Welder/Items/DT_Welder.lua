require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Welder", {
    name = "Metalworker",
    allocations = {
        { tags = {"Metal"}, count = 8 },
        { tags = {"Smithing"}, count = 6 },
        { tags = {"Tool"}, count = 4 }
    },
    wants = {
        ["Fuel"] = 2.0,
        ["Electronics"] = 1.2,
        ["Heavy"] = 1.3
    },
    forbid = { "Farming", "Bedding" }
})

end

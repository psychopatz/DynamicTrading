require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Welder", {
    name = "Metalworker",
    allocations = {
        { tags={"Resource.Material.Metal"}, count = 8 },
        { tags={"Tool.General"}, count = 6 },
        { tags={"Tool.General"}, count = 4 }
    },
    wants = {
        ["Resource.Fuel"] = 2.0,
        ["Electronics"] = 1.2,
        ["Clothing.Armor.Heavy"] = 1.3
    },
    forbid = { "Building.Garden", "Building.Furniture.Bed" }
})

end

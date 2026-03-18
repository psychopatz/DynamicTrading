require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then
DynamicTrading.RegisterArchetype("Blacksmith", {
    name = "Blacksmith",
    allocations = {
        { tags={"Resource.Material.Metal"}, count = 8 },
        { tags={"Resource.Material.MetalForm"}, count = 4 },
        { tags={"Resource.Fuel.Solid"}, count = 3 },
        { tags={"Resource.Material.Glass"}, count = 1 },
        { tags={"Resource.Material.Hardware"}, count = 1 },
        { tags={"Resource.Material.MetalFamily"}, count = 1 }
    },
    wants = {
        ["Resource.Fuel"] = 1.4,
        ["Container.Liquid"] = 1.2,
        ["Resource.Material.Textile"] = 1.2
    },
    forbid = { "Building.Furniture.Bed", "Tool.Fishing", "Resource.Material.Paper" }
})

end

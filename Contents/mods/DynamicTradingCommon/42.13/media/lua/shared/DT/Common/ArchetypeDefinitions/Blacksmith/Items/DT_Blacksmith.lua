require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then
DynamicTrading.RegisterArchetype("Blacksmith", {
    name = "Blacksmith",
    allocations = {
        { tags={"Tool.Smithing"}, count = 8 },
        { tags={"Resource.Material.Metal"}, count = 6 },
        { tags={"Quality.Heavy"}, count = 4 },
        { tags={"Resource.Fuel.Solid"}, count = 3 }
    },
    wants = {
        ["Fuel"] = 1.4,
        ["Container.Fluid"] = 1.2,
        ["Resource.Material.Leather"] = 1.2
    },
    forbid = { "Plastic", "Electronics", "Junk.Paper" }
})

end

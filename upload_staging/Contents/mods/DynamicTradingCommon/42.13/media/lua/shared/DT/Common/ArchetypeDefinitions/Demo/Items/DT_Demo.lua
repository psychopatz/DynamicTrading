require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Demo", {
    name = "Demo Expert",
    allocations = {
        { tags={"Resource.Material.Metal"}, count = 6 },
        { tags={"Weapon.Explosive"}, count = 4 },
        { tags={"Resource.Fuel"}, count = 4 },
        { tags={"Electronics"}, count = 3 }
    },
    wants = {
        ["Resource.Material.General"] = 2.0,
        ["Resource.Craftable"] = 1.5,
        ["Medical.General"] = 1.2
    },
    forbid = { "Tool.Fragile", "Resource.Material.Glass", "Building.Furniture.Decor" }
})

end

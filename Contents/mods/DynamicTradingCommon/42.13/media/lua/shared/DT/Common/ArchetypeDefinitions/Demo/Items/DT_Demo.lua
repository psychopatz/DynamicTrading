require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Demo", {
    name = "Demo Expert",
    allocations = {
        { tags={"Quality.Heavy"}, count = 6 },
        { tags={"Tool.Camping.Fire"}, count = 4 },
        { tags={"Resource.Fuel"}, count = 4 },
        { tags={"Electronics.General"}, count = 3 }
    },
    wants = {
        ["Resource.Material.Chemical"] = 2.0,
        ["Resource.Material.Utility"] = 1.5,
        ["Medical.General"] = 1.2
    },
    forbid = { "Fragile", "Resource.Material.Glass", "Misc.Decor" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Demo", {
    name = "Demo Expert",
    allocations = {
        { tags={"Quality.Heavy"}, count = 6 },
        { tags={"Tool.Camping.Fire"}, count = 4 },
        { tags={"Resource.Fuel"}, count = 4 },
        { tags={"Electronics"}, count = 3 }
    },
    wants = {
        ["Gunpowder"] = 2.0,
        ["Wire"] = 1.5,
        ["Medical"] = 1.2
    },
    forbid = { "Fragile", "Resource.Material.Glass", "Luxury.Decor" }
})

end

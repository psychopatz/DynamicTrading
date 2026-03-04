require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Demo", {
    name = "Demo Expert",
    allocations = {
        { tags = {"Heavy"}, count = 6 },
        { tags = {"Fire"}, count = 4 },
        { tags = {"Fuel"}, count = 4 },
        { tags = {"Electronics"}, count = 3 }
    },
    wants = {
        ["Gunpowder"] = 2.0,
        ["Wire"] = 1.5,
        ["Medical"] = 1.2
    },
    forbid = { "Fragile", "Glass", "Decor" }
})

end

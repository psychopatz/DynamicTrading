require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Demo", {
    name = "Demo Expert",
    allocations = {
        ["Heavy"] = 6,
        ["Fire"] = 4,
        ["Fuel"] = 4,
        ["Electronics"] = 3
    },
    wants = {
        ["Gunpowder"] = 2.0,
        ["Wire"] = 1.5,
        ["Medical"] = 1.2
    },
    forbid = { "Fragile", "Glass", "Decor" }
})

end

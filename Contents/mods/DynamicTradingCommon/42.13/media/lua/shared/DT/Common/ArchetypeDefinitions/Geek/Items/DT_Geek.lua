require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Geek", {
    name = "Collector",
    allocations = {
        ["Toy"] = 6,
        ["Fun"] = 5,
        ["Electronics"] = 5,
        ["Literature"] = 4
    },
    wants = {
        ["Battery"] = 1.5,
        ["Sweets"] = 1.4,
        ["Drink"] = 1.2
    },
    forbid = { "Alcohol", "Farm", "Tool" }
})

end

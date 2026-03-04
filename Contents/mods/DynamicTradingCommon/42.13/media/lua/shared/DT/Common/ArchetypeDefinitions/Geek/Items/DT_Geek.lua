require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Geek", {
    name = "Collector",
    allocations = {
        { tags = {"Toy"}, count = 6 },
        { tags = {"Fun"}, count = 5 },
        { tags = {"Electronics"}, count = 5 },
        { tags = {"Literature"}, count = 4 }
    },
    wants = {
        ["Battery"] = 1.5,
        ["Sweets"] = 1.4,
        ["Drink"] = 1.2
    },
    forbid = { "Alcohol", "Farm", "Tool" }
})

end

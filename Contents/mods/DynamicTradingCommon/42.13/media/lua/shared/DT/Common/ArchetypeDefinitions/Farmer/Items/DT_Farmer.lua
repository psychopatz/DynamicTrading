require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Farmer", {
    name = "Farmer",
    allocations = {
        { tags = {"Vegetable"}, count = 6 },
        { tags = {"Fruit"}, count = 4 },
        { tags = {"Grain"}, count = 4 },
        { tags = {"Farming"}, count = 3 },
        { tags = {"Farmer"}, count = 2 }
    },
    expertTags = { "Vegetable", "Fruit", "Grain", "Farming" },
    wants = {
        ["Tool"] = 1.3,
        ["Water"] = 1.2,
        ["Fuel"] = 1.2
    },
    forbid = { "Gun", "Ammo", "Electronics" }
})

end

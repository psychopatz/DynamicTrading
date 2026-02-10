require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Farmer", {
    name = "Farmer",
    allocations = {
        ["Vegetable"] = 6,
        ["Fruit"] = 4,
        ["Grain"] = 4,
        ["Farming"] = 3,
        ["Farmer"] = 2
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

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Herbalist", {
    name = "Herbalist",
    allocations = {
        { tags = {"Herb"}, count = 8 },
        { tags = {"Vegetable"}, count = 4 },
        { tags = {"Preservation"}, count = 4 },
        { tags = {"Tea"}, count = 2 }
    },
    wants = {
        ["Container"] = 1.5,
        ["Backpack"] = 1.2,
        ["Literature"] = 1.3
    },
    forbid = { "Canned", "Gun", "Electronics" }
})

end
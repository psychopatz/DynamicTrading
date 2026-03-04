require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then
DynamicTrading.RegisterArchetype("Blacksmith", {
    name = "Blacksmith",
    allocations = {
        { tags = {"Smithing"}, count = 8 },
        { tags = {"Metal"}, count = 6 },
        { tags = {"Heavy"}, count = 4 },
        { tags = {"Charcoal"}, count = 3 }
    },
    wants = {
        ["Fuel"] = 1.4,
        ["Water"] = 1.2,
        ["Leather"] = 1.2
    },
    forbid = { "Plastic", "Electronics", "Paper" }
})

end

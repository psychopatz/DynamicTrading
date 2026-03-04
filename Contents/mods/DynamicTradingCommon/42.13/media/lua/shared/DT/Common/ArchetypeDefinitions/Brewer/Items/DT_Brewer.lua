require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Brewer", {
    name = "Moonshiner",
    allocations = {
        { tags = {"Alcohol"}, count = 8 },
        { tags = {"Sugar"}, count = 4 },
        { tags = {"Water"}, count = 4 },
        { tags = {"Glass"}, count = 3 }
    },
    wants = {
        ["Fruit"] = 1.4,
        ["Grain"] = 1.4,
        ["Fuel"] = 1.3
    },
    forbid = { "Police", "Law", "Book" }
})

end
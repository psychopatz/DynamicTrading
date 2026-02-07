DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Brewer", {
    name = "Moonshiner",
    allocations = {
        ["Alcohol"] = 8,
        ["Sugar"] = 4,
        ["Water"] = 4,
        ["Glass"] = 3
    },
    wants = {
        ["Fruit"] = 1.4,
        ["Grain"] = 1.4,
        ["Fuel"] = 1.3
    },
    forbid = { "Police", "Law", "Book" }
})

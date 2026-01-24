DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Blacksmith", {
    name = "Blacksmith",
    allocations = {
        ["Smithing"] = 8,
        ["Metal"] = 6,
        ["Heavy"] = 4,
        ["Charcoal"] = 3
    },
    wants = {
        ["Fuel"] = 1.4,
        ["Water"] = 1.2,
        ["Leather"] = 1.2
    },
    forbid = { "Plastic", "Electronics", "Paper" }
})

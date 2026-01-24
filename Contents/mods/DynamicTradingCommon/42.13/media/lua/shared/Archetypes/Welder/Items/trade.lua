DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Welder", {
    name = "Metalworker",
    allocations = {
        ["Metal"] = 8,
        ["Smithing"] = 6,
        ["Tool"] = 4
    },
    wants = {
        ["Fuel"] = 2.0,
        ["Electronics"] = 1.2,
        ["Heavy"] = 1.3
    },
    forbid = { "Farming", "Bedding" }
})

DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Mechanic", {
    name = "Mechanic",
    allocations = {
        ["CarPart"] = 8,
        ["Mechanic"] = 5,
        ["Fuel"] = 3,
        ["Tool"] = 4
    },
    wants = {
        ["Electronics"] = 1.3,
        ["Junk"] = 1.1,
        ["Drink"] = 1.2
    },
    forbid = { "Clothing", "Medical", "Farming" }
})

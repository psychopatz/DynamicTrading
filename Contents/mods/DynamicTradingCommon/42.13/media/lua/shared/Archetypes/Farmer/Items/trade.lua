DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Farmer", {
    name = "Farmer",
    allocations = {
        ["Vegetable"] = 6,
        ["Fruit"] = 4,
        ["Grain"] = 4,
        ["Farming"] = 3,
        ["Farmer"] = 2
    },
    wants = {
        ["Tool"] = 1.3,
        ["Water"] = 1.2,
        ["Fuel"] = 1.2
    },
    forbid = { "Gun", "Ammo", "Electronics" }
})
print("[DynamicTrading] Registered archetype: Farmer")

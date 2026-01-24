DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Athlete", {
    name = "Coach",
    allocations = {
        ["Sport"] = 8,
        ["Clothing"] = 4,
        ["Protein"] = 4,
        ["Water"] = 4
    },
    wants = {
        ["Medical"] = 1.3,
        ["HighCalorie"] = 1.2,
        ["Vitamin"] = 1.4
    },
    forbid = { "Alcohol", "Tobacco", "Junk" }
})
print("[DynamicTrading] Athlete Archetype Registered.")

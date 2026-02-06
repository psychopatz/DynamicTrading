DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Carpenter", {
    name = "Carpenter",
    allocations = {
        ["Wood"] = 10,
        ["Woodwork"] = 5,
        ["Carpenter"] = 5,
        ["Build"] = 3
    },
    wants = {
        ["Tool"] = 1.3,
        ["Food"] = 1.2,
        ["Medical"] = 1.1
    },
    forbid = { "Metal", "Electronics", "Jewelry" }
})
print("[DynamicTrading] Registered archetype: Carpenter")
DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Angler", {
    name = "River Trader",
    allocations = {
        ["Fish"] = 6,
        ["Bait"] = 5,
        ["Trapping"] = 4,
        ["Water"] = 4
    },
    wants = {
        ["Tool"] = 1.2,
        ["Textile"] = 1.4,
        ["Spice"] = 1.3
    },
    forbid = { "Electronics", "Gun" }
})
print("[DynamicTrading] Registered archetype: Angler")
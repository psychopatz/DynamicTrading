DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Janitor", {
    name = "The Cleaner",
    allocations = {
        ["Clean"] = 8,
        ["Hygiene"] = 6,
        ["Chemical"] = 3,
        ["Poison"] = 3,
        ["Trash"] = 4
    },
    wants = {
        ["Mask"] = 1.4,
        ["Wearable"] = 1.2,
        ["Water"] = 1.2
    },
    forbid = { "Food", "Fresh", "Luxury" }
})
print("[DynamicTrading] Registered archetype: Janitor")
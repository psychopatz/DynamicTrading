DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Burglar", {
    name = "The Fence",
    allocations = {
        ["Thief"] = 5,
        ["Luxury"] = 4,
        ["Jewelry"] = 4,
        ["Illegal"] = 2,
        ["Weapon"] = 2
    },
    wants = {
        ["Electronics"] = 1.3,
        ["Cash"] = 1.5,
        ["Backpack"] = 1.2
    },
    forbid = { "Heavy", "Furniture", "Farming" }
})
print("[DynamicTrading] Registered archetype: Burglar")

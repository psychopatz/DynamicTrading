DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Hiker", {
    name = "Drifter",
    allocations = {
        ["Camping"] = 8,
        ["Travel"] = 5,
        ["Backpack"] = 4,
        ["Shelter"] = 3
    },
    wants = {
        ["Canned"] = 1.3,
        ["Sweets"] = 1.2,
        ["Clothing"] = 1.2
    },
    forbid = { "Heavy", "Generator", "Furniture" }
})
print("[DynamicTrading] Registered archetype: Hiker")

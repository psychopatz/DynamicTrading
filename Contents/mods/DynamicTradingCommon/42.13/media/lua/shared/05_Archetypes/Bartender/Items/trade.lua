DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Bartender", {
    name = "Barkeep",
    allocations = {
        ["Alcohol"] = 8,
        ["Drink"] = 6,
        ["Glass"] = 4,
        ["Fun"] = 2
    },
    wants = {
        ["Fruit"] = 1.3,
        ["Clean"] = 1.2,
        ["Junk"] = 1.1
    },
    forbid = { "Weapon", "Ammo" }
})
print("[DynamicTrading] Registered archetype: Bartender")
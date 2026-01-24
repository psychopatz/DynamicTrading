DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Chef", {
    name = "Chef",
    allocations = {
        ["Cooking"] = 6,
        ["Food"] = 6,
        ["Fresh"] = 4,
        ["Spice"] = 3,
        ["Ingredient"] = 3
    },
    wants = {
        ["Preservation"] = 1.5,
        ["Fuel"] = 1.2,
        ["Water"] = 1.2
    },
    forbid = { "Weapon", "Ammo", "Junk" }
})

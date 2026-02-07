DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Survivalist", {
    name = "Prepper",
    allocations = {
        ["Canned"] = 6,
        ["Survival"] = 5,
        ["Ammo"] = 4,
        ["Battery"] = 2
    },
    wants = {
        ["Weapon"] = 1.3,
        ["Fuel"] = 1.5,
        ["Generator"] = 1.4
    },
    forbid = { "Fresh", "Luxury", "Toy" }
})

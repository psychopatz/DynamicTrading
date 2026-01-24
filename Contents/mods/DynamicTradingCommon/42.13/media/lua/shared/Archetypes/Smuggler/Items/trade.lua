DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Smuggler", {
    name = "Night Trader",
    allocations = {
        ["Alcohol"] = 5,
        ["Tobacco"] = 5,
        ["Luxury"] = 3,
        ["Illegal"] = 3
    },
    wants = {
        ["Gun"] = 1.5,
        ["Ammo"] = 1.3,
        ["Jewelry"] = 1.4
    },
    forbid = { "Junk", "Material", "Farming" }
})

DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Foreman", {
    name = "Site Foreman",
    allocations = {
        ["Material"] = 8,
        ["Build"] = 6,
        ["Wood"] = 4,
        ["Heavy"] = 2
    },
    wants = {
        ["Tool"] = 1.4,
        ["Alcohol"] = 1.2,
        ["HighCalorie"] = 1.2
    },
    forbid = { "Literature", "Jewelry" }
})

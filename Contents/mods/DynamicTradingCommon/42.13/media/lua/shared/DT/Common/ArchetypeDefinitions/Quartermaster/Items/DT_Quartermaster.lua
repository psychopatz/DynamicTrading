DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Quartermaster", {
    name = "Deserter",
    allocations = {
        ["Military"] = 8,
        ["Tactical"] = 5,
        ["Stockpile"] = 4,
        ["MRE"] = 3,
        ["Canned"] = 3
    },
    wants = {
        ["Alcohol"] = 1.5,
        ["Tobacco"] = 1.5,
        ["Luxury"] = 1.2
    },
    forbid = { "Farming", "Decor", "Toy" }
})

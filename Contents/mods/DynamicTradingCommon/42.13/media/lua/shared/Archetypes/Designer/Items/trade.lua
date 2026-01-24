DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Designer", {
    name = "Home Stager",
    allocations = {
        ["Decor"] = 10,
        ["Furniture"] = 4,
        ["Light"] = 4,
        ["Organizer"] = 3
    },
    wants = {
        ["Clean"] = 1.3,
        ["Textile"] = 1.2,
        ["Paint"] = 1.1
    },
    forbid = { "Weapon", "Trash", "Junk" }
})

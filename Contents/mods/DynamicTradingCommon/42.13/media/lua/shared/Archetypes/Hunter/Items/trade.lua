DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Hunter", {
    name = "Trapper",
    allocations = {
        ["Trapping"] = 5,
        ["Game"] = 5,
        ["Leather"] = 4,
        ["Hunting"] = 3,
        ["Bone"] = 2
    },
    wants = {
        ["Spice"] = 1.3,
        ["Camping"] = 1.4,
        ["Blade"] = 1.2
    },
    forbid = { "Electronics", "Office", "Toy" }
})

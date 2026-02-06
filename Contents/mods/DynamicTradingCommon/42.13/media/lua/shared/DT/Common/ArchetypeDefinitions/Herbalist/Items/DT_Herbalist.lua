DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Herbalist", {
    name = "Herbalist",
    allocations = {
        ["Herb"] = 8,
        ["Vegetable"] = 4,
        ["Preservation"] = 4,
        ["Tea"] = 2
    },
    wants = {
        ["Container"] = 1.5,
        ["Backpack"] = 1.2,
        ["Literature"] = 1.3
    },
    forbid = { "Canned", "Gun", "Electronics" }
})
print("[DynamicTrading] Registered archetype: Herbalist")
DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Scavenger", {
    name = "Scavenger",
    allocations = {
        ["Junk"] = 10,
        ["Trash"] = 5,
        ["Scavenger"] = 5,
        ["Material"] = 3
    },
    wants = {
        ["Backpack"] = 1.5,
        ["Water"] = 1.2,
        ["Food"] = 1.2
    },
    forbid = {}
})
print("[DynamicTrading] Registered archetype: Scavenger")

DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("RoadWarrior", {
    name = "Road Warrior",
    allocations = {
        ["Improvised"] = 6,
        ["CarPart"] = 5,
        ["Fuel"] = 5,
        ["Armor"] = 3
    },
    wants = {
        ["Mechanic"] = 1.4,
        ["Gun"] = 1.3,
        ["Canned"] = 1.2
    },
    forbid = { "Decor", "Toy", "Fragile" }
})
print("[DynamicTrading] Registered archetype: RoadWarrior")
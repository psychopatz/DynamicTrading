DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Teacher", {
    name = "Teacher",
    allocations = {
        ["Scholastic"] = 8,
        ["Paper"] = 6,
        ["Office"] = 5,
        ["Literature"] = 3
    },
    wants = {
        ["Toy"] = 1.5,
        ["Sweets"] = 1.2,
        ["Medical"] = 1.2
    },
    forbid = { "Alcohol", "Tobacco", "Weapon" }
})

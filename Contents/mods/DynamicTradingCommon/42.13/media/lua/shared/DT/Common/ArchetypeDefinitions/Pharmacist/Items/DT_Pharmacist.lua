DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Pharmacist", {
    name = "Pharmacist",
    allocations = {
        ["Pill"] = 8,
        ["Pharmacist"] = 5,
        ["Medical"] = 4,
        ["Clean"] = 3
    },
    wants = {
        ["Herb"] = 1.3,
        ["Paper"] = 1.2,
        ["Container"] = 1.2
    },
    forbid = { "Weapon", "Dirty", "Rotten" }
})

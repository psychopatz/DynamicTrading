DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Musician", {
    name = "DJ / Musician",
    allocations = {
        ["Music"] = 10,
        ["Electronics"] = 4,
        ["Fun"] = 4,
        ["Leisure"] = 2
    },
    wants = {
        ["Battery"] = 1.5,
        ["Generator"] = 1.2,
        ["Alcohol"] = 1.2
    },
    forbid = { "Weapon", "Medical", "Farming" }
})

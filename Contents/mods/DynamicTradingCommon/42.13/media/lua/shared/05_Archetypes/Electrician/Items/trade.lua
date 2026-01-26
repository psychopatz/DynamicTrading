DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Electrician", {
    name = "Electrician",
    allocations = {
        ["Electronics"] = 8,
        ["Communication"] = 4,
        ["Light"] = 3,
        ["Generator"] = 2
    },
    wants = {
        ["Tool"] = 1.3,
        ["Copper"] = 1.4,
        ["SkillBook"] = 1.4
    },
    forbid = { "Fresh", "Clothing" }
})
print("[DynamicTrading] Registered archetype: Electrician")

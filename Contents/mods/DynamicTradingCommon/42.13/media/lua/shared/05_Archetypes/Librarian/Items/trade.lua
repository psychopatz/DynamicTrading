DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Librarian", {
    name = "Archivist",
    allocations = {
        ["Literature"] = 10,
        ["SkillBook"] = 6,
        ["Cartography"] = 4,
        ["Scholastic"] = 3
    },
    wants = {
        ["Electronics"] = 1.3,
        ["Light"] = 1.2,
        ["Music"] = 1.2
    },
    forbid = { "Weapon", "Alcohol" }
})
print("[DynamicTrading] Registered archetype: Librarian")

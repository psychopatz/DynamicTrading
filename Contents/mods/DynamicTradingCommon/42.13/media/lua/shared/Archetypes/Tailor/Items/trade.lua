DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Tailor", {
    name = "Tailor",
    allocations = {
        ["Clothing"] = 8,
        ["Textile"] = 5,
        ["Tailor"] = 4,
        ["Organizer"] = 2
    },
    wants = {
        ["Tool"] = 1.2,
        ["Jewelry"] = 1.3,
        ["SkillBook"] = 1.3
    },
    forbid = { "Fuel", "CarPart", "Heavy" }
})

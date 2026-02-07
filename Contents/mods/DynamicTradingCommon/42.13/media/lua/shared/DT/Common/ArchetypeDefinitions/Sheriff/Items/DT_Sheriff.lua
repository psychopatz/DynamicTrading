DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Sheriff", {
    name = "Constable",
    allocations = {
        ["Police"] = 5,
        ["Gun"] = 4,
        ["Ammo"] = 4,
        ["Weapon"] = 3
    },
    wants = {
        ["Communication"] = 1.5,
        ["Donut"] = 2.0,
        ["Sweets"] = 1.5,
        ["Coffee"] = 1.5
    },
    forbid = { "Illegal", "Heavy" }
})

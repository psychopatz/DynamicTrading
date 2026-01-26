DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Pyro", {
    name = "Firebug",
    allocations = {
        ["Fuel"] = 8,
        ["Fire"] = 6,
        ["Burnable"] = 4,
        ["Explosive"] = 2
    },
    wants = {
        ["Alcohol"] = 1.3,
        ["Textile"] = 1.2,
        ["Glass"] = 1.2
    },
    forbid = { "Water", "FireExtinguisher", "Ice" }
})
print("[DynamicTrading] Registered archetype: Pyro")

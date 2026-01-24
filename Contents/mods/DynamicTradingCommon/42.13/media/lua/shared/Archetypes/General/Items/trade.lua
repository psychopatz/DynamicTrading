DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

print("[DynamicTrading] Loading Archetype Data: General")

DynamicTrading.RegisterArchetype("General", {
    name = "General Trader",
    allocations = {
        ["Food"] = 4,
        ["Drink"] = 3,
        ["Material"] = 3,
        ["Junk"] = 4,
        ["Clothing"] = 2,
        ["General"] = 2
    },
    wants = {
        ["Luxury"] = 1.1,
        ["Jewelry"] = 1.2
    }, 
    forbid = { "Illegal", "Legendary" }
})

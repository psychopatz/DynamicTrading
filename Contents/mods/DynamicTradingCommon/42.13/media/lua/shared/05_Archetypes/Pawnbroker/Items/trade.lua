DynamicTrading = DynamicTrading or {}
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}

DynamicTrading.RegisterArchetype("Pawnbroker", {
    name = "Fence",
    allocations = {
        ["Jewelry"] = 6,
        ["Gold"] = 4,
        ["Silver"] = 4,
        ["Luxury"] = 5,
        ["Rare"] = 3
    },
    wants = {
        ["Electronics"] = 1.2,
        ["Gun"] = 1.2,
        ["Antique"] = 1.5
    },
    forbid = { "Trash", "Junk", "Rotten" }
})
print("[DynamicTrading] Registered archetype: Pawnbroker")
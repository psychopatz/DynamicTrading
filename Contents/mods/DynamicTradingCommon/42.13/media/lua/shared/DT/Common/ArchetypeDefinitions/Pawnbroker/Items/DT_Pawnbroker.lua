require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Pawnbroker", {
    name = "Pawnbroker",
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

end

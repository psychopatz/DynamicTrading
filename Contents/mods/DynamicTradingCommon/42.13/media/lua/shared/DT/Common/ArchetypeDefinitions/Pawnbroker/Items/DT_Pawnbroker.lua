require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Pawnbroker", {
    name = "Pawnbroker",
    allocations = {
        { tags = {"Jewelry"}, count = 6 },
        { tags = {"Gold"}, count = 4 },
        { tags = {"Silver"}, count = 4 },
        { tags = {"Luxury"}, count = 5 },
        { tags = {"Rare"}, count = 3 }
    },
    wants = {
        ["Electronics"] = 1.2,
        ["Gun"] = 1.2,
        ["Antique"] = 1.5
    },
    forbid = { "Trash", "Junk", "Rotten" }
})

end

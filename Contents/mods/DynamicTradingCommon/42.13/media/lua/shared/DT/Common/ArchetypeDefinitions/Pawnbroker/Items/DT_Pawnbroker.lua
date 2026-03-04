require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Pawnbroker", {
    name = "Pawnbroker",
    allocations = {
        { tags={"Luxury.Jewelry"}, count = 6 },
        { tags={"Resource.Material.Precious"}, count = 4 },
        { tags={"Resource.Material.Precious"}, count = 4 },
        { tags={"Luxury"}, count = 5 },
        { tags={"Rarity.Rare"}, count = 3 }
    },
    wants = {
        ["Electronics"] = 1.2,
        ["Weapon.Ranged.Firearm"] = 1.2,
        ["Antique"] = 1.5
    },
    forbid = { "Junk.Trash", "Quality.Junk", "Rotten" }
})

end

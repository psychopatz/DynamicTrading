require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Pawnbroker", {
    name = "Pawnbroker",
    allocations = {
        { tags={"Misc.Cosmetic"}, count = 6 },
        { tags={"Resource.Material.Precious"}, count = 4 },
        { tags={"Resource.Material.Precious"}, count = 4 },
        { tags={"Quality.Luxury"}, count = 5 },
        { tags={"Rarity.Rare"}, count = 3 }
    },
    wants = {
        ["Electronics.General"] = 1.2,
        ["Weapon.Ranged.Firearm"] = 1.2,
        ["Misc.Artifact"] = 1.5
    },
    forbid = { "Misc.Artifact.Trash", "Quality.Waste", "Quality.Rotten" }
})

end

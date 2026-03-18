require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Pawnbroker", {
    name = "Pawnbroker",
    allocations = {
        { tags={"Clothing.Accessory.Jewelry"}, count = 6 },
        { tags={"Resource.Material.MetalFamily"}, count = 4 },
        { tags={"Resource.Material.MetalFamily"}, count = 4 },
        { tags={"Quality.Luxury"}, count = 5 },
        { tags={"Rarity.Rare"}, count = 3 }
    },
    wants = {
        ["Electronics"] = 1.2,
        ["Weapon.Ranged.Firearm"] = 1.2,
        ["Misc.General"] = 1.5
    },
    forbid = { "Quality.Waste", "Quality.Waste", "Quality.Waste" }
})

end

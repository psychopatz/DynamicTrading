require "DT/Common/Config"
if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Burglar", {
    name = "The Fence",
    allocations = {
        { tags={"Rarity.Rare"}, count = 5 },
        { tags={"Quality.Luxury"}, count = 4 },
        { tags={"Clothing.Accessory.Jewelry"}, count = 4 },
        { tags={"Rarity.Rare"}, count = 2 },
        { tags={"Weapon"}, count = 2 }
    },
    wants = {
        ["Electronics"] = 1.3,
        ["Quality.Luxury"] = 1.5,
        ["Container.Bag.Backpack"] = 1.2
    },
    forbid = { "Clothing.Armor.Heavy", "Resource.Material.Hardware", "Resource.Material.Paper" }
})
end
require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Pawnbroker", {
    module = "DynamicTradingCommon",
    name = "Pawnbroker",
    allocations = {
        { tags={"Clothing.Accessory.Jewelry"}, count = 10 },
        { tags={"Quality.Luxury"}, count = 8 },
        { tags={"Electronics"}, count = 5 },
        { tags={"Rarity.Rare"}, count = 4 },
        { tags={"Weapon.Melee.Blade"}, count = 3 },
        { module = "DynamicTradingCommon",  item = "Base.WristWatch_Left_ClassicGold", count = 1 }
    },
    expertTags = { "Clothing.Accessory.Jewelry", "Quality.Luxury", "Electronics", "Rarity.Rare", "Weapon.Melee.Blade" },
    wants = {
        ["Electronics"] = 1.3,
        ["Literature.Media"] = 1.25,
        ["Medical.General.Drug"] = 1.2,
        ["Weapon.Ranged.Ammo"] = 1.15,
        ["Quality.Luxury"] = 1.1
    },
    forbid = { "Quality.Waste", "Food.Perishable", "Resource.Material", "Building.Garden", "Building.Furniture.General" }
})

end

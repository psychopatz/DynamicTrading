require "DT/Common/Config"
if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Burglar", {
    module = "DynamicTradingCommon",
    name = "The Fence",
    allocations = {
        { tags={"Rarity.Rare"}, count = 5 },
        { tags={"Quality.Luxury"}, count = 5 },
        { tags={"Clothing.Accessory.Jewelry"}, count = 6 },
        { tags={"Electronics"}, count = 3 },
        { tags={"Tool.General"}, count = 4 },
        { module = "DynamicTradingCommon",  item = "Base.Screwdriver", count = 1 }
    },
    expertTags = { "Clothing.Accessory.Jewelry", "Quality.Luxury", "Electronics", "Tool.General", "Electronics" },
    wants = {
        ["Weapon.Melee.Blade"] = 1.35,
        ["Clothing.Accessory.Utility"] = 1.3,
        ["Medical.General.Drug"] = 1.25,
        ["Literature.Media"] = 1.2,
        ["Container"] = 1.15
    },
    forbid = { "Building.Furniture.General", "Resource.Material.Wood", "Tool.Farming", "Building.Garden", "Food.Perishable" }
})
end
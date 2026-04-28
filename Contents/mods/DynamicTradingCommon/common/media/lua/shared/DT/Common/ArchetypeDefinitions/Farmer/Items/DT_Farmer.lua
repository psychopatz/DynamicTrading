require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Farmer", {
    module = "DynamicTradingCommon",
    name = "Farmer",
    allocations = {
        { tags={"Building.Garden"}, count = 8 },
        { tags={"Tool.Farming"}, count = 4 },
        { tags={"Food.Perishable.Vegetable"}, count = 10 },
        { tags={"Food.Perishable.Fruit"}, count = 6 },
        { tags={"Resource.Material"}, count = 5 },
        { module = "DynamicTradingCommon",  item = "Base.HandShovel", count = 1 }
    },
    expertTags = { "Building.Garden", "Tool.Farming", "Food.Perishable.Vegetable", "Resource.Material.Wood", "Resource.Material" },
    wants = {
        ["Container.Liquid"] = 1.3,
        ["Tool.Farming"] = 1.3,
        ["Resource.Fuel"] = 1.25,
        ["Literature.SkillBook"] = 1.2,
        ["Tool.General"] = 1.1
    },
    forbid = { "Electronics", "Quality.Luxury", "Weapon.Ranged.Firearm", "Clothing.Accessory.Jewelry", "Theme.Clinical" }
})

end

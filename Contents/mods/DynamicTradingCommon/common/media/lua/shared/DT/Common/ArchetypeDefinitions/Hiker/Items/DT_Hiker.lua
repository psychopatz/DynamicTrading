require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Hiker", {
    module = "DynamicTradingCommon",
    name = "Drifter",
    allocations = {
        { tags={"Theme.Survival"}, count = 8 },
        { tags={"Container.Bag.Backpack"}, count = 4 },
        { tags={"Food.NonPerishable"}, count = 6 },
        { tags={"Tool.General"}, count = 5 },
        { tags={"Clothing"}, count = 3 },
        { module = "DynamicTradingCommon",  item = "Base.FirstAidKit", count = 1 }
    },
    expertTags = { "Container.Bag.Backpack", "Food.NonPerishable", "Clothing", "Tool.General", "Theme.Survival" },
    wants = {
        ["Container.Liquid"] = 1.3,
        ["Literature.SkillBook"] = 1.25,
        ["Medical.Consumable"] = 1.2,
        ["Resource.Fuel"] = 1.15,
        ["Electronics.LightSource"] = 1.1
    },
    forbid = { "Building.Furniture.General", "Electronics.Generator", "Quality.Waste", "Weapon.Explosive", "Building.Vehicle" }
})

end

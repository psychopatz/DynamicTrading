require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Butcher", {
    module = "DynamicTradingCommon",
    name = "Butcher",
    allocations = {
        { tags={"Food.Perishable.Meat"}, count = 10 },
        { tags={"Tool.Cookware"}, count = 5 },
        { tags={"Tool.General"}, count = 3 },
        { tags={"Container.Capacity"}, count = 2 },
        { tags={"Weapon.Melee.Blade"}, count = 2 },
        { module = "DynamicTradingCommon",  item = "Base.KitchenKnife", count = 1 }
    },
    expertTags = { "Food.Perishable.Meat", "Weapon.Melee.Blade", "Tool.General", "Container.Capacity", "Weapon.Melee.Blade" },
    wants = {
        ["Food.Cooking.Spice"] = 1.3,
        ["Container.Liquid"] = 1.25,
        ["Misc.General"] = 1.2,
        ["Resource.Material.Paper"] = 1.15,
        ["Food.Drink"] = 1.1
    },
    forbid = { "Building.Garden", "Literature.SkillBook", "Clothing.Dress", "Electronics", "Theme.Clinical" }
})

end

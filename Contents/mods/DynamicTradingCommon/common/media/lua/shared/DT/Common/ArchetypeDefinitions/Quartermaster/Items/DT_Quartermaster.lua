require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Quartermaster", {
    module = "DynamicTradingCommon",
    name = "Deserter",
    allocations = {
        { tags={"Theme.Combat"}, count = 10 },
        { tags={"Clothing"}, count = 5 },
        { tags={"Container.Bag.Backpack"}, count = 4 },
        { tags={"Food.NonPerishable"}, count = 8 },
        { tags={"Tool.General"}, count = 6 },
        { module = "DynamicTradingCommon",  item = "Base.FirstAidKit", count = 1 }
    },
    expertTags = { "Building.Survival", "Food.NonPerishable", "Clothing", "Tool.General", "Weapon.Melee.Blunt" },
    wants = {
        ["Resource.Fuel"] = 1.35,
        ["Weapon.Ranged.Ammo"] = 1.3,
        ["Medical.Consumable"] = 1.25,
        ["Literature.SkillBook"] = 1.2,
        ["Container.Bag.General"] = 1.15
    },
    forbid = { "Quality.Luxury", "Clothing.Accessory.Cosmetic", "Building.Furniture.Decor", "Misc.General", "Building.Garden" }
})

end

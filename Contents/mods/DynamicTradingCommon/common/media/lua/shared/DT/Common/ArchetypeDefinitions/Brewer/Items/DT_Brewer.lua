require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Brewer", {
    module = "DynamicTradingCommon",
    name = "Moonshiner",
    allocations = {
        { tags={"Food.Drink.Alcohol"}, count = 10 },
        { tags={"Container.Liquid"}, count = 6 },
        { tags={"Resource.Material.Glass"}, count = 5 },
        { tags={"Food.NonPerishable.Sweets"}, count = 4 },
        { tags={"Tool.Cookware"}, count = 3 },
        { module = "DynamicTradingCommon",  item = "Base.Sugar", count = 5 }
    },
    expertTags = { "Food.Drink.Alcohol", "Container.Liquid", "Resource.Material.Glass", "Food.NonPerishable.Sweets", "Tool.Cookware" },
    wants = {
        ["Food.Perishable.Fruit"] = 1.35,
        ["Container.Liquid"] = 1.3,
        ["Resource.Fuel"] = 1.25,
        ["Literature.SkillBook"] = 1.15,
        ["Misc.General"] = 1.1
    },
    forbid = { "Theme.Combat", "Weapon.Explosive", "Medical.General.Drug", "Clothing", "Electronics.Generator" }
})

end

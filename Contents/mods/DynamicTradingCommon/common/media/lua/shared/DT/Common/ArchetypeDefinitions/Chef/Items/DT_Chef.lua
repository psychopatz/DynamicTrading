require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Chef", {
    module = "DynamicTradingCommon",
    name = "Chef",
    allocations = {
        { tags={"Food.Perishable.Meat"}, count = 5 },
        { tags={"Food.Perishable.Vegetable"}, count = 8 },
        { tags={"Tool.Cookware"}, count = 4 },
        { tags={"Food.NonPerishable"}, count = 6 },
        { tags={"Container.Liquid"}, count = 5 },
        { module = "DynamicTradingCommon",  item = "Base.Pan", count = 1 }
    },
    expertTags = { "Food.Perishable.Meat", "Food.Perishable.Vegetable", "Weapon.Melee.Blade", "Food.NonPerishable", "Container.Liquid" },
    wants = {
        ["Food.Cooking.Spice"] = 1.3,
        ["Resource.Fuel.Gas"] = 1.25,
        ["Misc.General"] = 1.2,
        ["Literature.SkillBook"] = 1.15,
        ["Container.Liquid"] = 1.1
    },
    forbid = { "Resource.Material.Hardware", "Weapon.Ranged.Firearm", "Clothing", "Medical.General.Vitamin", "Quality.Waste" }
})

end

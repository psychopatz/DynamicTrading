require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Chef", {
    name = "Chef",
    allocations = {
        { tags={"Food.Perishable.Meat"}, count = 5 },
        { tags={"Food.Perishable.Vegetable"}, count = 8 },
        { tags={"Tool.Kitchen"}, count = 4 },
        { tags={"Food.NonPerishable"}, count = 6 },
        { tags={"Container.Liquid"}, count = 5 },
        { item = "Base.Pan", count = 1 }
    },
    expertTags = { "Food.Perishable.Meat", "Food.Perishable.Vegetable", "Tool.Kitchen", "Food.NonPerishable", "Container.Liquid" },
    wants = {
        ["Spice.General"] = 1.3,
        ["Resource.Fuel.Wood"] = 1.25,
        ["Misc.General"] = 1.2,
        ["Literature.SkillBook"] = 1.15,
        ["Container.Liquid"] = 1.1
    },
    forbid = { "Resource.Material.Hardware", "Weapon.Ranged.Firearm", "Clothing", "Electronics.Parts", "Quality.Waste" }
})

end

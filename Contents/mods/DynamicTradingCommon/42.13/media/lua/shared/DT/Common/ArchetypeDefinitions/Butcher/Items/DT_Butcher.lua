require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Butcher", {
    name = "Butcher",
    allocations = {
        { tags={"Food.Perishable.Meat"}, count = 10 },
        { tags={"Tool.Kitchen"}, count = 5 },
        { tags={"Tool.General"}, count = 3 },
        { tags={"Container.Capacity"}, count = 2 },
        { tags={"Weapon.Melee.Blade"}, count = 2 },
        { item = "Base.Cleaver", count = 1 }
    },
    expertTags = { "Food.Perishable.Meat", "Tool.Kitchen", "Tool.General", "Container.Capacity", "Weapon.Melee.Blade" },
    wants = {
        ["Spice.General"] = 1.3,
        ["Container.Liquid"] = 1.25,
        ["Misc.General"] = 1.2,
        ["Resource.Material.Paper"] = 1.15,
        ["Food.Drink"] = 1.1
    },
    forbid = { "Building.Garden", "Literature.SkillBook", "Clothing.Dress", "Electronics", "Theme.Clinical" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Hunter", {
    module = "DynamicTradingCommon",
    name = "Trapper",
    allocations = {
        { tags={"Weapon.Ranged"}, count = 3 },
        { tags={"Weapon.Ranged.Ammo"}, count = 10 },
        { tags={"Food.Perishable.Meat"}, count = 8 },
        { tags={"Clothing"}, count = 3 },
        { tags={"Building.Survival.Trap"}, count = 5 },
        { module = "DynamicTradingCommon",  item = "Base.TrapMouse", count = 2 }
    },
    expertTags = { "Weapon.Ranged", "Weapon.Ranged.Ammo", "Food.Perishable.Meat", "Clothing", "Tool.General" },
    wants = {
        ["Container.Capacity"] = 1.3,
        ["Weapon.Part"] = 1.25,
        ["Literature.SkillBook"] = 1.2,
        ["Medical.Consumable"] = 1.15,
        ["Resource.Fuel"] = 1.1
    },
    forbid = { "Building.Furniture.Decor", "Electronics", "Clothing.Accessory.Jewelry", "Building.Garden", "Theme.Clinical" }
})
end
require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Sheriff", {
    module = "DynamicTradingCommon",
    name = "Constable",
    allocations = {
        { tags={"Theme.Police"}, count = 5 },
        { tags={"Weapon.Ranged.Firearm"}, count = 4 },
        { tags={"Weapon.Ranged.Ammo"}, count = 8 },
        { tags={"Clothing"}, count = 3 },
        { tags={"Weapon.Melee.Blunt"}, count = 2 },
        { module = "DynamicTradingCommon",  item = "Base.PistolCase1", count = 1 }
    },
    expertTags = { "Weapon.Ranged.Firearm", "Weapon.Ranged.Ammo", "Clothing", "Tool.Security", "Theme.Combat" },
    wants = {
        ["Medical.Consumable"] = 1.35,
        ["Food.NonPerishable"] = 1.3,
        ["Clothing.Accessory.Utility"] = 1.25,
        ["Literature.SkillBook"] = 1.2,
        ["Resource.Fuel"] = 1.15
    },
    forbid = { "Building.Furniture.Decor", "Misc.General", "Clothing.Accessory.Cosmetic", "Building.Garden", "Food.Drink.Alcohol" }
})

end

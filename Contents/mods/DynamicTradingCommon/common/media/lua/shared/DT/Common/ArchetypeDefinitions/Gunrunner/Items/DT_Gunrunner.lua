require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Gunrunner", {
    module = "DynamicTradingCommon",
    name = "Gunrunner",
    allocations = {
        { tags={"Weapon.Ranged"}, count = 5 },
        { tags={"Weapon.Ranged.Ammo"}, count = 10 },
        { tags={"Weapon.Part"}, count = 5 },
        { tags={"Theme.Militia"}, count = 4 },
        { tags={"Rarity.Rare"}, count = 3 },
        { module = "DynamicTradingCommon",  item = "Base.Bag_ALICEpack_Army", count = 1 }
    },
    expertTags = { "Weapon.Ranged", "Weapon.Ranged.Ammo", "Weapon.Part", "Theme.Militia", "Theme.Combat" },
    wants = {
        ["Quality.Luxury"] = 1.35,
        ["Medical.General.Drug"] = 1.3,
        ["Food.Drink.Alcohol"] = 1.25,
        ["Resource.Fuel"] = 1.2,
        ["Clothing"] = 1.15
    },
    forbid = { "Building.Furniture.General", "Tool.Farming", "Clothing.Dress", "Literature.Book", "Food.Perishable" }
})

end

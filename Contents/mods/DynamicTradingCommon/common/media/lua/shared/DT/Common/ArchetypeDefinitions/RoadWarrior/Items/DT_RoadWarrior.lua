require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("RoadWarrior", {
    module = "DynamicTradingCommon",
    name = "Road Warrior",
    allocations = {
        { tags={"Resource.Parts"}, count = 8 },
        { tags={"Resource.Fuel"}, count = 6 },
        { tags={"Weapon.Melee.Blunt"}, count = 4 },
        { tags={"Clothing"}, count = 3 },
        { tags={"Theme.Combat"}, count = 5 },
        { module = "DynamicTradingCommon",  item = "Base.Wrench", count = 1 }
    },
    expertTags = { "Building.Vehicle", "Resource.Parts", "Weapon.Melee.Blunt", "Clothing", "Theme.Combat" },
    wants = {
        ["Resource.Fuel"] = 1.4,
        ["Electronics.Battery"] = 1.3,
        ["Food.NonPerishable"] = 1.25,
        ["Medical.General.Drug"] = 1.2,
        ["Rarity.Rare"] = 1.15
    },
    forbid = { "Building.Garden", "Clothing.Dress", "Literature.Book", "Theme.Clinical", "Quality.Waste" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Office", {
    module = "DynamicTradingCommon",
    name = "White Collar",
    allocations = {
        { tags={"Resource.Material.Paper"}, count = 15 },
        { tags={"Literature.Media"}, count = 8 },
        { tags={"Electronics"}, count = 5 },
        { tags={"Clothing.Accessory.Wrist.Watch"}, count = 3 },
        { tags={"Misc.General"}, count = 10 },
        { module = "DynamicTradingCommon",  item = "Base.Journal", count = 2 }
    },
    expertTags = { "Literature.Media", "Resource.Material.Paper", "Electronics", "Misc.General", "Clothing.Accessory.Wrist.Watch" },
    wants = {
        ["Food.Drink.NonAlcoholic"] = 1.35,
        ["Food.NonPerishable.Sweets"] = 1.3,
        ["Quality.Luxury"] = 1.25,
        ["Misc.General"] = 1.15,
        ["Medical.General.Vitamin"] = 1.1
    },
    forbid = { "Building.Garden", "Tool.Farming", "Weapon.Melee.Blunt", "Clothing", "Quality.Waste" }
})

end

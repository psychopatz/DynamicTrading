require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("General", {
    module = "DynamicTradingCommon",
    name = "General Trader",
    allocations = {
        { tags={"Food.NonPerishable"}, count = 8 },
        { tags={"Food.Drink"}, count = 6 },
        { tags={"Resource.Material.General"}, count = 10 },
        { tags={"Tool.General"}, count = 4 },
        { tags={"Clothing"}, count = 4 },
        { tags={"Misc.General"}, count = 5 }
    },
    expertTags = { "Food.NonPerishable", "Resource.Material.General", "Misc.General", "Clothing", "Tool.General" },
    wants = {
        ["Quality.Luxury"] = 1.15,
        ["Rarity.Rare"] = 1.1,
        ["Rarity.Rare"] = 1.2,
        ["Resource.Fuel"] = 1.1,
        ["Medical.General"] = 1.05
    },
    forbid = { "Quality.Waste", "Weapon.Explosive", "Resource.Material", "Theme.Militia", "Misc.General" }
})

end

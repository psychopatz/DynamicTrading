require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Janitor", {
    module = "DynamicTradingCommon",
    name = "The Cleaner",
    allocations = {
        { tags={"Misc.General"}, count = 10 },
        { tags={"Tool.General"}, count = 6 },
        { tags={"Resource.Material.Packaging"}, count = 5 },
        { tags={"Clothing.Accessory.Utility"}, count = 4 },
        { tags={"Container.Liquid"}, count = 8 },
        { module = "DynamicTradingCommon",  item = "Base.Mop", count = 1 }
    },
    expertTags = { "Misc.General", "Tool.General", "Resource.Material.Packaging", "Clothing.Accessory.Utility", "Misc.General" },
    wants = {
        ["Clothing"] = 1.3,
        ["Container.Liquid"] = 1.25,
        ["Medical.General.Pills"] = 1.2,
        ["Resource.Fuel"] = 1.15,
        ["Food.Drink"] = 1.1
    },
    forbid = { "Quality.Luxury", "Weapon.Ranged", "Electronics", "Literature.Media", "Theme.Combat" }
})

end

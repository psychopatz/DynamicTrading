require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Foreman", {
    module = "DynamicTradingCommon",
    name = "Site Foreman",
    allocations = {
        { tags={"Building.Fixture.General"}, count = 5 },
        { tags={"Building.Furniture.General"}, count = 5 },
        { tags={"Resource.Material.Hardware"}, count = 10 },
        { tags={"Resource.Material.Metal"}, count = 4 },
        { tags={"Tool.General"}, count = 6 },
        { module = "DynamicTradingCommon",  item = "Base.Sledgehammer", count = 1 }
    },
    expertTags = { "Building.Fixture.General", "Building.Furniture", "Resource.Material.Hardware", "Resource.Material.Metal", "Tool.General" },
    wants = {
        ["Clothing.Armor.Head"] = 1.3,
        ["Clothing"] = 1.25,
        ["Resource.Fuel"] = 1.2,
        ["Literature.SkillBook"] = 1.15,
        ["Food.HighNutrition"] = 1.1
    },
    forbid = { "Clothing.Accessory.Jewelry", "Electronics", "Medical.General.Drug", "Literature.Media", "Theme.Clinical" }
})

end

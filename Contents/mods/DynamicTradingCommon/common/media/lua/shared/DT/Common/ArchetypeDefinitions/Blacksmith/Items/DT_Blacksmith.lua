require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then
DynamicTrading.RegisterArchetype("Blacksmith", {
    module = "DynamicTradingCommon",
    name = "Blacksmith",
    allocations = {
        { tags={"Resource.Material.Metal"}, count = 8 },
        { tags={"Resource.Material.MetalForm"}, count = 4 },
        { tags={"Resource.Fuel"}, count = 5 },
        { tags={"Weapon.Melee.General"}, count = 2 },
        { tags={"Tool.General"}, count = 3 },
        { module = "DynamicTradingCommon",  item = "Base.Charcoal", count = 1 }
    },
    expertTags = { "Resource.Material.Metal", "Tool.General", "Weapon.Melee.General", "Resource.Material.Hardware", "Building.Fixture.Hardware" },
    wants = {
        ["Resource.Fuel"] = 3.4,
        ["Clothing"] = 1.3,
        ["Tool.Cookware"] = 1.25,
        ["Quality.Waste"] = 1.2,
        ["Food.Drink"] = 1.1
    },
    forbid = { "Clothing.Accessory.Jewelry", "Electronics", "Medical.General.Drug", "Literature.SkillBook", "Theme.Clinical" }
})

end

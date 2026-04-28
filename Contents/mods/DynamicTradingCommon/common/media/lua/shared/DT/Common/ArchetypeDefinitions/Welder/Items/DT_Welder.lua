require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Welder", {
    module = "DynamicTradingCommon",
    name = "Metalworker",
    allocations = {
        { tags={"Resource.Material.Metal"}, count = 8 },
        { tags={"Resource.Material.MetalForm"}, count = 6 },
        { tags={"Resource.Material.Hardware"}, count = 4 },
        { tags={"Resource.Material.Adhesive"}, count = 4 },
        { tags={"Tool.General"}, count = 3 },
        { module = "DynamicTradingCommon",  item = "Base.WeldingMask", count = 1 }
    },
    expertTags = { "Resource.Material.Metal", "Tool.General", "Resource.Material.Hardware", "Resource.Material.Adhesive", "Building.Fixture.Hardware" },
    wants = {
        ["Resource.Fuel"] = 1.4,
        ["Clothing"] = 1.3,
        ["Clothing"] = 1.25,
        ["Quality.Waste"] = 1.2,
        ["Food.Drink"] = 1.1
    },
    forbid = { "Clothing.Dress", "Building.Garden", "Medical.General.Drug", "Literature.SkillBook", "Theme.Clinical" }
})

end

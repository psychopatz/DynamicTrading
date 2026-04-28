require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Mechanic", {
    module = "DynamicTradingCommon",
    name = "Mechanic",
    allocations = {
        { tags={"Building.Vehicle"}, count = 3 },
        { tags={"Building.Vehicle"}, count = 3 },
        { tags={"Resource.Parts"}, count = 10 },
        { tags={"Resource.Fuel"}, count = 2 },
        { tags={"Tool.General"}, count = 4 },
        { module = "DynamicTradingCommon",  item = "Base.Wrench", count = 1 }
    },
    expertTags = { "Building.Vehicle", "Resource.Parts", "Tool.General", "Resource.Material.Hardware", "Building.Fixture.Utility" },
    wants = {
        ["Resource.Fuel"] = 1.3,
        ["Electronics.Battery"] = 1.25,
        ["Quality.Waste"] = 1.15,
        ["Misc.General"] = 1.1,
        ["Food.Drink"] = 1.05
    },
    forbid = { "Clothing.Accessory.Jewelry", "Building.Garden", "Medical.General.Drug", "Literature.SkillBook", "Theme.Clinical" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Carpenter", {
    module = "DynamicTradingCommon",
    name = "Carpenter",
    allocations = {
        { tags={"Resource.Material.Wood"}, count = 10 },
        { tags={"Building.Furniture.General"}, count = 5 },
        { tags={"Building.Fixture.General"}, count = 3 },
        { tags={"Resource.Material.Hardware"}, count = 5 },
        { tags={"Tool.General"}, count = 4 },
        { module = "DynamicTradingCommon",  item = "Base.Hammer", count = 1 }
    },
    expertTags = { "Resource.Material.Wood", "Tool.General", "Resource.Material.Hardware", "Building.Furniture.General", "Building.Fixture.General" },
    wants = {
        ["Resource.Material.Adhesive"] = 1.3,
        ["Clothing"] = 1.25,
        ["Misc.General"] = 1.15,
        ["Literature.SkillBook.Carpentry"] = 1.1,
        ["Food.Drink"] = 1.05
    },
    forbid = { "Electronics", "Building.Vehicle", "Medical.General.Drug", "Literature.SkillBook", "Theme.Combat" }
})

end

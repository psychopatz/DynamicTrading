require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Electrician", {
    module = "DynamicTradingCommon",
    name = "Electrician",
    allocations = {
        { tags={"Electronics.Battery"}, count = 10 },
        { tags={"Electronics"}, count = 4 },
        { tags={"Electronics"}, count = 5 },
        { tags={"Electronics"}, count = 8 },
        { tags={"Electronics"}, count = 3 },
        { module = "DynamicTradingCommon",  item = "Base.Screwdriver", count = 1 }
    },
    expertTags = { "Electronics.Battery", "Electronics", "Electronics", "Electronics.Generator", "Electronics.PowerGenerator" },
    wants = {
        ["Resource.Material.Adhesive"] = 1.3,
        ["Tool.General"] = 1.25,
        ["Resource.Parts"] = 1.2,
        ["Electronics"] = 1.15,
        ["Food.Drink"] = 1.1
    },
    forbid = { "Building.Garden", "Clothing.Dress", "Medical.General.Drug", "Literature.SkillBook", "Theme.Primitive" }
})

end

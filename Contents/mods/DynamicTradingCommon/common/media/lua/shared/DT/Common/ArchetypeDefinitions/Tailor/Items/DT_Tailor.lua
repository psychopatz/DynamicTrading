require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Tailor", {
    module = "DynamicTradingCommon",
    name = "Tailor",
    allocations = {
        { tags={"Clothing"}, count = 3 },
        { tags={"Clothing.Accessory.Utility"}, count = 5 },
        { tags={"Resource.Material.Textile"}, count = 10 },
        { tags={"Resource.Material.Textile"}, count = 4 },
        { tags={"Tool.General"}, count = 4 },
        { module = "DynamicTradingCommon",  item = "Base.Scissors", count = 1 }
    },
    expertTags = { "Clothing", "Clothing.Accessory.Utility", "Clothing.Bottom", "Clothing.Face", "Clothing.Feet" },
    wants = {
        ["Tool.Crafting"] = 1.3,
        ["Resource.Material"] = 1.25,
        ["Misc.General"] = 1.2,
        ["Literature.SkillBook"] = 1.15,
        ["Clothing.Accessory.Cosmetic"] = 1.1
    },
    forbid = { "Resource.Material.Metal", "Weapon.Ranged.Firearm", "Building.Vehicle", "Electronics.Generator", "Theme.Industrial" }
})

end
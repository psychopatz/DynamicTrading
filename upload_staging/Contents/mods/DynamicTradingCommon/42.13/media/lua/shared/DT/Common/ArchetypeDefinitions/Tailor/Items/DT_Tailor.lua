require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Tailor", {
    name = "Tailor",
    allocations = {
        { tags={"Clothing"}, count = 8 },
        { tags={"Resource.Material.Textile"}, count = 5 },
        { tags={"Tool.General"}, count = 4 },
        { tags={"Container.Bag.General"}, count = 2 }
    },
    wants = {
        ["Tool.General"] = 1.2,
        ["Clothing.Accessory.Jewelry"] = 1.3,
        ["Literature.SkillBook"] = 1.3
    },
    forbid = { "Resource.Fuel", "Resource.Parts", "Clothing.Armor.Heavy" }
})

end
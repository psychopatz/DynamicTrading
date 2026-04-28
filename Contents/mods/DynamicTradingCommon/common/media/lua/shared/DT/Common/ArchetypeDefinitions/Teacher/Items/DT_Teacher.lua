require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Teacher", {
    module = "DynamicTradingCommon",
    name = "Teacher",
    allocations = {
        { tags={"Literature.SkillBook"}, count = 8 },
        { tags={"Literature.Book"}, count = 10 },
        { tags={"Literature.Media"}, count = 6 },
        { tags={"Resource.Material.Paper"}, count = 15 },
        { tags={"Literature.Recipe"}, count = 5 },
        { module = "DynamicTradingCommon",  item = "Base.BluePen", count = 3 }
    },
    expertTags = { "Literature.SkillBook", "Literature.Book", "Literature.Media", "Resource.Material.Paper", "Literature.Recipe" },
    wants = {
        ["Electronics.LightSource"] = 1.3,
        ["Building.Furniture.Counter"] = 1.25,
        ["Misc.General"] = 1.2,
        ["Quality.Luxury"] = 1.15,
        ["Misc.General"] = 1.1
    },
    forbid = { "Weapon.Explosive", "Food.Drink.Alcohol", "Medical.General.Drug", "Resource.Fuel", "Quality.Waste" }
})

end
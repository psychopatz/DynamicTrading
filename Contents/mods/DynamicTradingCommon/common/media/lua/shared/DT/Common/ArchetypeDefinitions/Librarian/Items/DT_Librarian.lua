require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Librarian", {
    module = "DynamicTradingCommon",
    name = "Archivist",
    allocations = {
        { tags={"Literature.Book"}, count = 10 },
        { tags={"Literature.SkillBook"}, count = 6 },
        { tags={"Literature.Media"}, count = 5 },
        { tags={"Resource.Material.Paper"}, count = 12 },
        { tags={"Literature.Recipe"}, count = 4 },
        { module = "DynamicTradingCommon",  item = "Base.Pencil", count = 3 }
    },
    expertTags = { "Literature.Book", "Literature.SkillBook", "Literature.Media", "Resource.Material.Paper", "Literature.Recipe" },
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

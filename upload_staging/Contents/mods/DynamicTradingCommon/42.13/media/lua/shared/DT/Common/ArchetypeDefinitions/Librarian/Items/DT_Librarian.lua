require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Librarian", {
    name = "Archivist",
    allocations = {
        { tags={"Literature.Book"}, count = 10 },
        { tags={"Literature.SkillBook"}, count = 6 },
        { tags={"Literature.Book"}, count = 4 },
        { tags={"Container"}, count = 3 }
    },
    expertTags = { "Literature.Book" },
    wants = {
        ["Electronics"] = 1.3,
        ["Electronics.Light.Component"] = 1.2,
        ["Literature.Media"] = 1.2
    },
    forbid = { "Weapon", "Food.Drink.Alcohol" }
})

end

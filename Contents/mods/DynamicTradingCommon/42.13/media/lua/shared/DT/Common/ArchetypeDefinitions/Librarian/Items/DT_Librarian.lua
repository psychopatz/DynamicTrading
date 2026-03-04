require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Librarian", {
    name = "Archivist",
    allocations = {
        { tags={"Literature.Book"}, count = 10 },
        { tags={"Literature.SkillBook"}, count = 6 },
        { tags={"Literature.Map"}, count = 4 },
        { tags={"Container.Misc"}, count = 3 }
    },
    wants = {
        ["Electronics"] = 1.3,
        ["Electronics.Component.Light"] = 1.2,
        ["Music"] = 1.2
    },
    forbid = { "Weapon", "Food.Drink.Alcohol" }
})

end

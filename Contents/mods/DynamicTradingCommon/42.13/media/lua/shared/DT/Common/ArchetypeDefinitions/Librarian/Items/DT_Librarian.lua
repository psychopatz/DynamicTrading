require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Librarian", {
    name = "Archivist",
    allocations = {
        { tags = {"Literature"}, count = 10 },
        { tags = {"SkillBook"}, count = 6 },
        { tags = {"Cartography"}, count = 4 },
        { tags = {"Scholastic"}, count = 3 }
    },
    wants = {
        ["Electronics"] = 1.3,
        ["Light"] = 1.2,
        ["Music"] = 1.2
    },
    forbid = { "Weapon", "Alcohol" }
})

end

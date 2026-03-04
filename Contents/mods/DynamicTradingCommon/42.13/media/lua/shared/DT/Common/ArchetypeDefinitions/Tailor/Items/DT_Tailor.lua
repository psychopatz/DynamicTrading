require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Tailor", {
    name = "Tailor",
    allocations = {
        { tags = {"Clothing"}, count = 8 },
        { tags = {"Textile"}, count = 5 },
        { tags = {"Tailor"}, count = 4 },
        { tags = {"Organizer"}, count = 2 }
    },
    wants = {
        ["Tool"] = 1.2,
        ["Jewelry"] = 1.3,
        ["SkillBook"] = 1.3
    },
    forbid = { "Fuel", "CarPart", "Heavy" }
})

end
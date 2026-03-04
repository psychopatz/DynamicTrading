require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Tailor", {
    name = "Tailor",
    allocations = {
        { tags={"Clothing.General"}, count = 8 },
        { tags={"Resource.Textile"}, count = 5 },
        { tags={"Tool.Crafting.Tailor"}, count = 4 },
        { tags={"Container.Organizer"}, count = 2 }
    },
    wants = {
        ["Tool.General"] = 1.2,
        ["Misc.Cosmetic"] = 1.3,
        ["Literature.SkillBook"] = 1.3
    },
    forbid = { "Resource.Fuel", "Vehicle.Part", "Quality.Heavy" }
})

end
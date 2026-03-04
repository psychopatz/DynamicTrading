require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Tailor", {
    name = "Tailor",
    allocations = {
        { tags={"Clothing"}, count = 8 },
        { tags={"Resource.Textile"}, count = 5 },
        { tags={"Tool.Crafting.Tailor"}, count = 4 },
        { tags={"Container.Organizer"}, count = 2 }
    },
    wants = {
        ["Tool"] = 1.2,
        ["Jewelry"] = 1.3,
        ["Literature.SkillBook"] = 1.3
    },
    forbid = { "Fuel", "Vehicle.Part", "Quality.Heavy" }
})

end
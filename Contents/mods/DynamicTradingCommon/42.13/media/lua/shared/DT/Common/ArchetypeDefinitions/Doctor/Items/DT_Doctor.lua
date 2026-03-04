require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Doctor", {
    name = "Field Medic",
    allocations = {
        { tags={"Medical.General"}, count = 8 },
        { tags={"Medical.General.Pills"}, count = 4 },
        { tags={"Quality.Sterile"}, count = 3 },
        { tags={"Medical.Tool"}, count = 2 }
    },
    expertTags = { "Medical.General", "Medical.Healthcare" },
    wants = {
        ["Tool.Cleaning"] = 1.5,
        ["Food.Drink.Alcohol"] = 1.3,
        ["Quality.Luxury"] = 1.2
    },
    forbid = { "Quality.Waste", "Resource.Material.Build", "Vehicle.Part" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Doctor", {
    name = "Field Medic",
    allocations = {
        { tags={"Medical"}, count = 8 },
        { tags={"Medical.Utility.Pill"}, count = 4 },
        { tags={"Quality.Sterile"}, count = 3 },
        { tags={"Medical.Tool"}, count = 2 }
    },
    expertTags = { "Medical" },
    wants = {
        ["Tool.Cleaning"] = 1.5,
        ["Food.Drink.Alcohol"] = 1.3,
        ["Luxury"] = 1.2
    },
    forbid = { "Quality.Junk", "Resource.Material.Build", "Vehicle.Part" }
})

end

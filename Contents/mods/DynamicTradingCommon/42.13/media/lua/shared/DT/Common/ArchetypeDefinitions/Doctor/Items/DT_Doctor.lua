require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Doctor", {
    name = "Field Medic",
    allocations = {
        { tags = {"Medical"}, count = 8 },
        { tags = {"Pill"}, count = 4 },
        { tags = {"Sterile"}, count = 3 },
        { tags = {"Pharmacist"}, count = 2 }
    },
    expertTags = { "Medical" },
    wants = {
        ["Clean"] = 1.5,
        ["Alcohol"] = 1.3,
        ["Luxury"] = 1.2
    },
    forbid = { "Junk", "Build", "CarPart" }
})

end

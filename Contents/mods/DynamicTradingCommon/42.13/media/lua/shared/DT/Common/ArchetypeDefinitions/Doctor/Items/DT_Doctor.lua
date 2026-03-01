require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Doctor", {
    name = "Field Medic",
    allocations = {
        ["Medical"] = 8,
        ["Pill"] = 4,
        ["Sterile"] = 3,
        ["Pharmacist"] = 2
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

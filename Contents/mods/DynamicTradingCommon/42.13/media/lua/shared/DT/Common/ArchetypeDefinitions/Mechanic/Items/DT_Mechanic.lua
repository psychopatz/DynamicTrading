require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Mechanic", {
    name = "Mechanic",
    allocations = {
        { tags = {"CarPart"}, count = 8 },
        { tags = {"Mechanic"}, count = 5 },
        { tags = {"Fuel"}, count = 3 },
        { tags = {"Tool"}, count = 4 }
    },
    expertTags = { "CarPart", "Mechanic" },
    wants = {
        ["Electronics"] = 1.3,
        ["Junk"] = 1.1,
        ["Drink"] = 1.2
    },
    forbid = { "Clothing", "Medical", "Farming" }
})

end

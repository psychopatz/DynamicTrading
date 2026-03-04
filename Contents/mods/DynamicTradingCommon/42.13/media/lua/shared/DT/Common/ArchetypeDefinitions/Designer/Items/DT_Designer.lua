require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Designer", {
    name = "Home Stager",
    allocations = {
        { tags = {"Decor"}, count = 10 },
        { tags = {"Furniture"}, count = 4 },
        { tags = {"Light"}, count = 4 },
        { tags = {"Organizer"}, count = 3 }
    },
    wants = {
        ["Clean"] = 1.3,
        ["Textile"] = 1.2,
        ["Paint"] = 1.1
    },
    forbid = { "Weapon", "Trash", "Junk" }
})

end

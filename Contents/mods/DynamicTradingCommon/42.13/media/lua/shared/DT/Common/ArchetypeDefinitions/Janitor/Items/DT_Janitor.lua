require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Janitor", {
    name = "The Cleaner",
    allocations = {
        { tags = {"Clean"}, count = 8 },
        { tags = {"Hygiene"}, count = 6 },
        { tags = {"Chemical"}, count = 3 },
        { tags = {"Poison"}, count = 3 },
        { tags = {"Trash"}, count = 4 }
    },
    wants = {
        ["Mask"] = 1.4,
        ["Wearable"] = 1.2,
        ["Water"] = 1.2
    },
    forbid = { "Food", "Fresh", "Luxury" }
})

end

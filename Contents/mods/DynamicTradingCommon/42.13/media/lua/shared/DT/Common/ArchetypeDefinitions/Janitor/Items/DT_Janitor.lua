require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Janitor", {
    name = "The Cleaner",
    allocations = {
        ["Clean"] = 8,
        ["Hygiene"] = 6,
        ["Chemical"] = 3,
        ["Poison"] = 3,
        ["Trash"] = 4
    },
    wants = {
        ["Mask"] = 1.4,
        ["Wearable"] = 1.2,
        ["Water"] = 1.2
    },
    forbid = { "Food", "Fresh", "Luxury" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Hiker", {
    name = "Drifter",
    allocations = {
        ["Camping"] = 8,
        ["Travel"] = 5,
        ["Backpack"] = 4,
        ["Shelter"] = 3
    },
    wants = {
        ["Canned"] = 1.3,
        ["Sweets"] = 1.2,
        ["Clothing"] = 1.2
    },
    forbid = { "Heavy", "Generator", "Furniture" }
})

end

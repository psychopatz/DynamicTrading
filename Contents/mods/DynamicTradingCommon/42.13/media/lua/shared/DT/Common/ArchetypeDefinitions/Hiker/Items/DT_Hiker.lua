require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Hiker", {
    name = "Drifter",
    allocations = {
        { tags = {"Camping"}, count = 8 },
        { tags = {"Travel"}, count = 5 },
        { tags = {"Backpack"}, count = 4 },
        { tags = {"Shelter"}, count = 3 }
    },
    wants = {
        ["Canned"] = 1.3,
        ["Sweets"] = 1.2,
        ["Clothing"] = 1.2
    },
    forbid = { "Heavy", "Generator", "Furniture" }
})

end

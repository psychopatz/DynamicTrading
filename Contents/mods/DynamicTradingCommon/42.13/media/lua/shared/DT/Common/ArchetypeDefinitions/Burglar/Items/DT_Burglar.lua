require "DT/Common/Config"
if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Burglar", {
    name = "The Fence",
    allocations = {
        { tags = {"Thief"}, count = 5 },
        { tags = {"Luxury"}, count = 4 },
        { tags = {"Jewelry"}, count = 4 },
        { tags = {"Illegal"}, count = 2 },
        { tags = {"Weapon"}, count = 2 }
    },
    wants = {
        ["Electronics"] = 1.3,
        ["Cash"] = 1.5,
        ["Backpack"] = 1.2
    },
    forbid = { "Heavy", "Furniture", "Farming" }
})
end
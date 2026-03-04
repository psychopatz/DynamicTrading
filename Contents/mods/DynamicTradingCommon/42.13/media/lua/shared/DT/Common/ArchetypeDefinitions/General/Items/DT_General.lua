require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("General", {
    name = "General Trader",
    allocations = {
        { tags = {"Food"}, count = 4 },
        { tags = {"Drink"}, count = 3 },
        { tags = {"Material"}, count = 3 },
        { tags = {"Junk"}, count = 4 },
        { tags = {"Clothing"}, count = 2 },
        { tags = {"General"}, count = 2 }
    },
    wants = {
        ["Luxury"] = 1.1,
        ["Jewelry"] = 1.2
    }, 
    forbid = { "Illegal", "Legendary" }
})

end

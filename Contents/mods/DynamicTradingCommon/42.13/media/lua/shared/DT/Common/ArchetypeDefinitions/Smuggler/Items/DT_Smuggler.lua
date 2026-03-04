require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Smuggler", {
    name = "Night Trader",
    allocations = {
        { tags = {"Alcohol"}, count = 5 },
        { tags = {"Tobacco"}, count = 5 },
        { tags = {"Luxury"}, count = 3 },
        { tags = {"Illegal"}, count = 3 }
    },
    wants = {
        ["Gun"] = 1.5,
        ["Ammo"] = 1.3,
        ["Jewelry"] = 1.4
    },
    forbid = { "Junk", "Material", "Farming" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Office", {
    name = "White Collar",
    allocations = {
        { tags = {"Office"}, count = 8 },
        { tags = {"Paper"}, count = 6 },
        { tags = {"Electronics"}, count = 4 },
        { tags = {"Suit"}, count = 2 }
    },
    wants = {
        ["Coffee"] = 2.0,
        ["Sweets"] = 1.3,
        ["Tobacco"] = 1.2
    },
    forbid = { "Farm", "Heavy", "Dirty" }
})

end

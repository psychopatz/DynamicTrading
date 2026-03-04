require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Athlete", {
    name = "Coach",
    allocations = {
        { tags = {"Sport"}, count = 8 },
        { tags = {"Clothing"}, count = 4 },
        { tags = {"Protein"}, count = 4 },
        { tags = {"Water"}, count = 4 }
    },
    wants = {
        ["Medical"] = 1.3,
        ["HighCalorie"] = 1.2,
        ["Vitamin"] = 1.4
    },
    forbid = { "Alcohol", "Tobacco", "Junk" }
})

end

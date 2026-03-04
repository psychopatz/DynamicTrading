require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Electrician", {
    name = "Electrician",
    allocations = {
        { tags = {"Electronics"}, count = 8 },
        { tags = {"Communication"}, count = 4 },
        { tags = {"Light"}, count = 3 },
        { tags = {"Generator"}, count = 2 }
    },
    wants = {
        ["Tool"] = 1.3,
        ["Copper"] = 1.4,
        ["SkillBook"] = 1.4
    },
    forbid = { "Fresh", "Clothing" }
})

end

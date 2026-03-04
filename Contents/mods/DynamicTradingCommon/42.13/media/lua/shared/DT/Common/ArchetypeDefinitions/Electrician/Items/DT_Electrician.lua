require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Electrician", {
    name = "Electrician",
    allocations = {
        { tags={"Electronics"}, count = 8 },
        { tags={"Electronics.Communication"}, count = 4 },
        { tags={"Electronics.Component.Light"}, count = 3 },
        { tags={"Electronics.Generator"}, count = 2 }
    },
    wants = {
        ["Tool"] = 1.3,
        ["Copper"] = 1.4,
        ["Literature.SkillBook"] = 1.4
    },
    forbid = { "Food.Perishable", "Clothing" }
})

end

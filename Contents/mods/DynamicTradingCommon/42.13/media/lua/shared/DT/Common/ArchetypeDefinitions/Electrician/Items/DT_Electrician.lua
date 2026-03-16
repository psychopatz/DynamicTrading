require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Electrician", {
    name = "Electrician",
    allocations = {
        { tags={"Electronics"}, count = 8 },
        { tags={"Electronics.Radio"}, count = 4 },
        { tags={"Electronics.Light.Component"}, count = 3 },
        { tags={"Electronics.PowerGenerator"}, count = 2 }
    },
    wants = {
        ["Tool.General"] = 1.3,
        ["Resource.Material.Metal"] = 1.4,
        ["Literature.SkillBook"] = 1.4
    },
    forbid = { "Food.Perishable", "Clothing" }
})

end

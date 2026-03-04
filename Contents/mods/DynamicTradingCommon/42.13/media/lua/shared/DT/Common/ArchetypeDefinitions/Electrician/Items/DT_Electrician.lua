require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Electrician", {
    name = "Electrician",
    allocations = {
        { tags={"Electronics.General"}, count = 8 },
        { tags={"Electronics.Gadget.Radio"}, count = 4 },
        { tags={"Electronics.Component.Light"}, count = 3 },
        { tags={"Appliance.Generator"}, count = 2 }
    },
    wants = {
        ["Tool.General"] = 1.3,
        ["Resource.Material.Metal"] = 1.4,
        ["Literature.SkillBook"] = 1.4
    },
    forbid = { "Food.Perishable", "Clothing.General" }
})

end

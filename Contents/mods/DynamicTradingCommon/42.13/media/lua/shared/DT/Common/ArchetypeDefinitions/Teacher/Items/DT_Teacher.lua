require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Teacher", {
    name = "Teacher",
    allocations = {
        { tags = {"Scholastic"}, count = 8 },
        { tags = {"Paper"}, count = 6 },
        { tags = {"Office"}, count = 5 },
        { tags = {"Literature"}, count = 3 }
    },
    wants = {
        ["Toy"] = 1.5,
        ["Sweets"] = 1.2,
        ["Medical"] = 1.2
    },
    forbid = { "Alcohol", "Tobacco", "Weapon" }
})

end
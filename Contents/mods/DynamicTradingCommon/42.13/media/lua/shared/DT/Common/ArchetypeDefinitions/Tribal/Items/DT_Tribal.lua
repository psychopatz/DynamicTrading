require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Tribal", {
    name = "Primitive Survivor",
    allocations = {
        { tags = {"Primitive"}, count = 8 },
        { tags = {"Spear"}, count = 6 },
        { tags = {"Bone"}, count = 4 },
        { tags = {"Leather"}, count = 3 }
    },
    wants = {
        ["Blade"] = 1.3,
        ["Textile"] = 1.2,
        ["Medicine"] = 1.4
    },
    forbid = { "Electronics", "Gun", "Computer" }
})

end
require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then


DynamicTrading.RegisterArchetype("Tribal", {
    name = "Primitive Survivor",
    allocations = {
        ["Primitive"] = 8,
        ["Spear"] = 6,
        ["Bone"] = 4,
        ["Leather"] = 3
    },
    wants = {
        ["Blade"] = 1.3,
        ["Textile"] = 1.2,
        ["Medicine"] = 1.4
    },
    forbid = { "Electronics", "Gun", "Computer" }
})

end
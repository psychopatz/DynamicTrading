require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Painter", {
    name = "Renovator",
    allocations = {
        { tags = {"Painter"}, count = 8 },
        { tags = {"Decor"}, count = 5 },
        { tags = {"Material"}, count = 4 },
        { tags = {"Tool"}, count = 3 }
    },
    wants = {
        ["Water"] = 1.2,
        ["Wearable"] = 1.1,
        ["Food"] = 1.1
    },
    forbid = { "Weapon", "Rotten", "Dirty" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Painter", {
    name = "Renovator",
    allocations = {
        ["Painter"] = 8,
        ["Decor"] = 5,
        ["Material"] = 4,
        ["Tool"] = 3
    },
    wants = {
        ["Water"] = 1.2,
        ["Wearable"] = 1.1,
        ["Food"] = 1.1
    },
    forbid = { "Weapon", "Rotten", "Dirty" }
})

end

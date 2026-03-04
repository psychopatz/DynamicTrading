require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Scavenger", {
    name = "Scavenger",
    allocations = {
        { tags = {"Junk"}, count = 10 },
        { tags = {"Trash"}, count = 5 },
        { tags = {"Scavenger"}, count = 5 },
        { tags = {"Material"}, count = 3 }
    },
    wants = {
        ["Backpack"] = 1.5,
        ["Water"] = 1.2,
        ["Food"] = 1.2
    },
    forbid = {}
})

end

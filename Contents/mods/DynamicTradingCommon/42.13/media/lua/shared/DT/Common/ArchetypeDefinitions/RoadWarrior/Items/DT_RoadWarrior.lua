require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("RoadWarrior", {
    name = "Road Warrior",
    allocations = {
        { tags = {"Improvised"}, count = 6 },
        { tags = {"CarPart"}, count = 5 },
        { tags = {"Fuel"}, count = 5 },
        { tags = {"Armor"}, count = 3 }
    },
    wants = {
        ["Mechanic"] = 1.4,
        ["Gun"] = 1.3,
        ["Canned"] = 1.2
    },
    forbid = { "Decor", "Toy", "Fragile" }
})

end

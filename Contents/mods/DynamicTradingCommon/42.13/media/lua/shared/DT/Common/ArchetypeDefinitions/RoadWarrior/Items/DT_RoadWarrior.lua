require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("RoadWarrior", {
    name = "Road Warrior",
    allocations = {
        ["Improvised"] = 6,
        ["CarPart"] = 5,
        ["Fuel"] = 5,
        ["Armor"] = 3
    },
    wants = {
        ["Mechanic"] = 1.4,
        ["Gun"] = 1.3,
        ["Canned"] = 1.2
    },
    forbid = { "Decor", "Toy", "Fragile" }
})

end

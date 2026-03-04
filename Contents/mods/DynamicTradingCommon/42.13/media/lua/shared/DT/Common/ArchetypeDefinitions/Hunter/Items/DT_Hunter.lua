require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Hunter", {
    name = "Trapper",
    allocations = {
        { tags = {"Trapping"}, count = 5 },
        { tags = {"Game"}, count = 5 },
        { tags = {"Leather"}, count = 4 },
        { tags = {"Hunting"}, count = 3 },
        { tags = {"Bone"}, count = 2 }
    },
    expertTags = { "Game", "Trapping", "Leather" },
    wants = {
        ["Spice"] = 1.3,
        ["Camping"] = 1.4,
        ["Blade"] = 1.2
    },
    forbid = { "Electronics", "Office", "Toy" }
})
end
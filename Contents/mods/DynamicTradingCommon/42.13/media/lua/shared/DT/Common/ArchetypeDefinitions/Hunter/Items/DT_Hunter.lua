require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Hunter", {
    name = "Trapper",
    allocations = {
        { tags={"Tool.Trap"}, count = 5 },
        { tags={"Food.Meat"}, count = 5 },
        { tags={"Resource.Material.Leather"}, count = 4 },
        { tags={"Theme.Hunting"}, count = 3 },
        { tags={"Resource.Material.Bone"}, count = 2 }
    },
    expertTags = { "Game", "Trapping", "Leather" },
    wants = {
        ["Spice"] = 1.3,
        ["Tool.Camping"] = 1.4,
        ["Blade"] = 1.2
    },
    forbid = { "Electronics", "Theme.Office", "Junk.Toy" }
})
end
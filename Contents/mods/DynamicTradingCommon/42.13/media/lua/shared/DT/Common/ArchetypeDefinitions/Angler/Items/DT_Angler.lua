require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

    DynamicTrading.RegisterArchetype("Angler", {
        name = "River Trader",
        allocations = {
        { tags = {"Fish"}, count = 6 },
        { tags = {"Bait"}, count = 5 },
        { tags = {"Trapping"}, count = 4 },
        { tags = {"Water"}, count = 4 }
    },
        expertTags = { "Fish", "Fishing", "Bait" },
        wants = {
            ["Tool"] = 1.2,
            ["Textile"] = 1.4,
            ["Spice"] = 1.3
        },
        forbid = { "Electronics", "Gun", "Rotten" }
    })

end

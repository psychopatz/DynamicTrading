require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

    DynamicTrading.RegisterArchetype("Angler", {
        name = "River Trader",
        allocations = {
            ["Fish"] = 6,
            ["Bait"] = 5,
            ["Trapping"] = 4,
            ["Water"] = 4
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

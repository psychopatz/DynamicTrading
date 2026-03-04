require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Carpenter", {
    name = "Carpenter",
    allocations = {
        { tags = {"Wood"}, count = 10 },
        { tags = {"Woodwork"}, count = 5 },
        { tags = {"Carpenter"}, count = 5 },
        { tags = {"Build"}, count = 3 }
    },
    expertTags = { "Wood", "Build" },
    wants = {
        ["Tool"] = 1.3,
        ["Food"] = 1.2,
        ["Medical"] = 1.1
    },
    forbid = { "Metal", "Electronics", "Jewelry" }
})

end

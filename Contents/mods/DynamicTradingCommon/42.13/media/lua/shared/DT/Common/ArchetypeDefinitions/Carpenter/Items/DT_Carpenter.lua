require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Carpenter", {
    name = "Carpenter",
    allocations = {
        ["Wood"] = 10,
        ["Woodwork"] = 5,
        ["Carpenter"] = 5,
        ["Build"] = 3
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

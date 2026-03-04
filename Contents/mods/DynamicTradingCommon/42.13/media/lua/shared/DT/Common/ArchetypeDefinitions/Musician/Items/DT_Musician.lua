require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Musician", {
    name = "DJ / Musician",
    allocations = {
        { tags = {"Music"}, count = 10 },
        { tags = {"Electronics"}, count = 4 },
        { tags = {"Fun"}, count = 4 },
        { tags = {"Leisure"}, count = 2 }
    },
    wants = {
        ["Battery"] = 1.5,
        ["Generator"] = 1.2,
        ["Alcohol"] = 1.2
    },
    forbid = { "Weapon", "Medical", "Farming" }
})

end

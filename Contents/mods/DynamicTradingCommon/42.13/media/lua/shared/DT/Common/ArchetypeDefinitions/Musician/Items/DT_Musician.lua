require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Musician", {
    name = "DJ / Musician",
    allocations = {
        { tags={"Literature.Music"}, count = 10 },
        { tags={"Electronics"}, count = 4 },
        { tags={"Luxury.Fun"}, count = 4 },
        { tags={"Theme.Leisure"}, count = 2 }
    },
    wants = {
        ["Electronics.Battery"] = 1.5,
        ["Electronics.Generator"] = 1.2,
        ["Food.Drink.Alcohol"] = 1.2
    },
    forbid = { "Weapon", "Medical", "Theme.Farming" }
})

end

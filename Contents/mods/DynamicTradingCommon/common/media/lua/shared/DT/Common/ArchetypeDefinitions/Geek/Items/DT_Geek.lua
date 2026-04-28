require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Geek", {
    module = "DynamicTradingCommon",
    name = "Collector",
    allocations = {
        { tags={"Electronics"}, count = 5 },
        { tags={"Literature.Media"}, count = 10 },
        { tags={"Electronics.Battery"}, count = 8 },
        { tags={"Electronics"}, count = 3 },
        { module = "DynamicTradingCommon",  item = "Base.VideoGame", count = 1 }
    },
    expertTags = { "Electronics", "Literature.Media", "Electronics.Battery", "Electronics", "Electronics.LightSource" },
    wants = {
        ["Food.NonPerishable.Sweets"] = 1.35,
        ["Food.Drink.NonAlcoholic"] = 1.3,
        ["Quality.Luxury"] = 1.25,
        ["Literature.Book"] = 1.2,
        ["Electronics"] = 1.1
    },
    forbid = { "Building.Garden", "Tool.Farming", "Weapon.Melee.Blunt", "Clothing", "Theme.Industrial" }
})

end

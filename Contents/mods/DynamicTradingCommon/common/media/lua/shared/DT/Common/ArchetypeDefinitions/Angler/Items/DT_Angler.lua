require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

    DynamicTrading.RegisterArchetype("Angler", {
    module = "DynamicTradingCommon",
        name = "River Trader",
    allocations = {
        { tags={"Resource.Fishing"}, count = 8 },
        { tags={"Tool.Fishing"}, count = 5 },
        { tags={"Food.Perishable.Fish"}, count = 8 },
        { tags={"Container.Utility"}, count = 4 },
        { tags={"Clothing"}, count = 2 },
        { module = "DynamicTradingCommon",  item = "Base.FishingRod", count = 1 }
    },
        expertTags = { "Resource.Fishing", "Tool.Fishing", "Food.Perishable.Fish", "Container.Utility", "Clothing" },
        wants = {
            ["Container.Liquid"] = 1.3,
            ["Weapon.Melee.Blade"] = 1.25,
            ["Misc.General"] = 1.2,
            ["Literature.SkillBook"] = 1.15,
            ["Food.Drink"] = 1.1
        },
        forbid = { "Electronics.Generator", "Building.Garden", "Clothing.Dress", "Building.Furniture", "Weapon.Explosive" }
    })

end

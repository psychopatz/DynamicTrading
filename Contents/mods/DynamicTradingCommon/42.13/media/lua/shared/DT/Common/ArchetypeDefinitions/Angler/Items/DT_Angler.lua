require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

    DynamicTrading.RegisterArchetype("Angler", {
        name = "River Trader",
        allocations = {
        { tags={"Food.Perishable.Fish"}, count = 6 },
        { tags={"Resource.Fishing"}, count = 5 },
        { tags={"Tool.Fishing"}, count = 4 },
        { tags={"Container.Liquid"}, count = 4 }
    },
        expertTags = { "Food.Perishable.Fish", "Tool.Fishing", "Resource.Fishing" },
        wants = {
            ["Tool.General"] = 1.2,
            ["Resource.Material.Textile"] = 1.4,
            ["Food.Cooking.Spice"] = 1.3
        },
        forbid = { "Electronics", "Weapon.Ranged.Firearm", "Quality.Waste" }
    })

end

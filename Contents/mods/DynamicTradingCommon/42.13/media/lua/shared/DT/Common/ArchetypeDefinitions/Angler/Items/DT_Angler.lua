require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

    DynamicTrading.RegisterArchetype("Angler", {
        name = "River Trader",
        allocations = {
        { tags={"Food.Meat"}, count = 6 },
        { tags={"Food.Perishable.Bait"}, count = 5 },
        { tags={"Tool.Trap"}, count = 4 },
        { tags={"Container.Fluid"}, count = 4 }
    },
        expertTags = { "Fish", "Fishing", "Bait" },
        wants = {
            ["Tool"] = 1.2,
            ["Resource.Textile"] = 1.4,
            ["Spice"] = 1.3
        },
        forbid = { "Electronics", "Weapon.Ranged.Firearm", "Rotten" }
    })

end

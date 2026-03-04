require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("General", {
    name = "General Trader",
    allocations = {
        { tags={"Food.General"}, count = 4 },
        { tags={"Food.Drink"}, count = 3 },
        { tags={"Resource.Material.General"}, count = 3 },
        { tags={"Quality.Waste"}, count = 4 },
        { tags={"Clothing.General"}, count = 2 },
        { tags={"Misc.General"}, count = 2 }
    },
    wants = {
        ["Quality.Luxury"] = 1.1,
        ["Misc.Cosmetic"] = 1.2
    }, 
    forbid = { "Quality.Illegal", "Rarity.Legendary" }
})

end

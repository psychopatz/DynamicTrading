require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("General", {
    name = "General Trader",
    allocations = {
        { tags={"Food"}, count = 4 },
        { tags={"Food.Drink"}, count = 3 },
        { tags={"Resource.Material.General"}, count = 3 },
        { tags={"Quality.Waste"}, count = 4 },
        { tags={"Clothing"}, count = 2 },
        { tags={"Misc.General"}, count = 2 }
    },
    wants = {
        ["Quality.Luxury"] = 1.1,
        ["Clothing.Accessory.Jewelry"] = 1.2
    }, 
    forbid = { "Rarity.Rare", "Quality.Luxury" }
})

end

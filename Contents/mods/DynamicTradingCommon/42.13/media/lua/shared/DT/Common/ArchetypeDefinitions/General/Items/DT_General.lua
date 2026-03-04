require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("General", {
    name = "General Trader",
    allocations = {
        { tags={"Food"}, count = 4 },
        { tags={"Food.Drink"}, count = 3 },
        { tags={"Resource.Material"}, count = 3 },
        { tags={"Quality.Junk"}, count = 4 },
        { tags={"Clothing"}, count = 2 },
        { tags={"Misc.General"}, count = 2 }
    },
    wants = {
        ["Luxury"] = 1.1,
        ["Jewelry"] = 1.2
    }, 
    forbid = { "Quality.Illegal", "Rarity.Legendary" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Foreman", {
    name = "Site Foreman",
    allocations = {
        { tags={"Resource.Material.General"}, count = 8 },
        { tags={"Resource.Material.Hardware"}, count = 6 },
        { tags={"Resource.Material.Wood"}, count = 4 },
        { tags={"Clothing.Armor.Heavy"}, count = 2 },
        { item = "Base.Axe", count = 1 },
        { item = "Base.Woodglue", count = 2 }
    },
    wants = {
        ["Tool.General"] = 1.4,
        ["Food.Drink.Alcohol"] = 1.2,
        ["Food.HighNutrition"] = 1.2
    },
    forbid = { "Literature.Media", "Clothing.Accessory.Jewelry" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Foreman", {
    name = "Site Foreman",
    allocations = {
        { tags={"Resource.Material"}, count = 8 },
        { tags={"Resource.Material.Build"}, count = 6 },
        { tags={"Resource.Material.Wood"}, count = 4 },
        { tags={"Quality.Heavy"}, count = 2 },
        { item = "Base.Axe", count = 1 },
        { item = "Base.Woodglue", count = 2 }
    },
    wants = {
        ["Tool"] = 1.4,
        ["Food.Drink.Alcohol"] = 1.2,
        ["HighCalorie"] = 1.2
    },
    forbid = { "Literature.Book", "Jewelry" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Office", {
    name = "White Collar",
    allocations = {
        { tags={"Resource.Material.Paper"}, count = 8 },
        { tags={"Resource.Material.Paper"}, count = 6 },
        { tags={"Electronics"}, count = 4 },
        { tags={"Container.Bag.General"}, count = 2 }
    },
    wants = {
        ["Food.Drink.NonAlcoholic"] = 2.0,
        ["Food.NonPerishable.Sweets"] = 1.3,
        ["Medical.General.Drug"] = 1.2
    },
    forbid = { "Building.Garden", "Clothing.Armor.Heavy", "Quality.Waste" }
})

end

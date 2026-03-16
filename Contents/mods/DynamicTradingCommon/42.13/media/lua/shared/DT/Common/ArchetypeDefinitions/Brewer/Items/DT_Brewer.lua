require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Brewer", {
    name = "Moonshiner",
    allocations = {
        { tags={"Food.Drink.Alcohol"}, count = 8 },
        { tags={"Food.NonPerishable.Sweets"}, count = 4 },
        { tags={"Container.Liquid"}, count = 4 },
        { tags={"Resource.Material.Glass"}, count = 3 }
    },
    wants = {
        ["Food.Perishable.Fruit"] = 1.4,
        ["Food.NonPerishable.Grain"] = 1.4,
        ["Resource.Fuel"] = 1.3
    },
    forbid = { "Theme.Combat", "Literature.Book", "Literature.Book" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Brewer", {
    name = "Moonshiner",
    allocations = {
        { tags={"Food.Drink.Alcohol"}, count = 8 },
        { tags={"Food.NonPerishable.Sweets"}, count = 4 },
        { tags={"Container.Fluid"}, count = 4 },
        { tags={"Resource.Material.Glass"}, count = 3 }
    },
    wants = {
        ["Fruit"] = 1.4,
        ["Grain"] = 1.4,
        ["Fuel"] = 1.3
    },
    forbid = { "Origin.Police", "Law", "Book" }
})

end
require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Pyro", {
    name = "Firebug",
    allocations = {
        { tags={"Resource.Fuel"}, count = 8 },
        { tags={"Misc.General"}, count = 6 },
        { tags={"Resource.Material.Wood"}, count = 4 },
        { tags={"Weapon.Explosive"}, count = 2 }
    },
    wants = {
        ["Food.Drink.Alcohol"] = 1.3,
        ["Resource.Material.Textile"] = 1.2,
        ["Resource.Material.Glass"] = 1.2
    },
    forbid = { "Container.Liquid", "Misc.General", "Food.LowNutrition" }
})

end

require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Herbalist", {
    name = "Herbalist",
    allocations = {
        { tags={"Medical.Healthcare.Botanical"}, count = 8 },
        { tags={"Food.Perishable.Vegetable"}, count = 4 },
        { tags={"Resource.Material.Packaging"}, count = 4 },
        { tags={"Food.Drink.NonAlcoholic"}, count = 2 }
    },
    wants = {
        ["Container"] = 1.5,
        ["Container.Bag.Backpack"] = 1.2,
        ["Literature.Book"] = 1.3
    },
    forbid = { "Food.NonPerishable.Canned", "Weapon.Ranged.Firearm", "Electronics" }
})

end
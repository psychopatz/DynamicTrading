require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Herbalist", {
    name = "Herbalist",
    allocations = {
        { tags={"Medical.Herb"}, count = 8 },
        { tags={"Food.Perishable.Vegetable"}, count = 4 },
        { tags={"Resource.Storage.Preservation"}, count = 4 },
        { tags={"Food.NonPerishable.Drink"}, count = 2 }
    },
    wants = {
        ["Container"] = 1.5,
        ["Container.Backpack"] = 1.2,
        ["Literature.Book"] = 1.3
    },
    forbid = { "Food.Perishable.Canned", "Weapon.Ranged.Firearm", "Electronics" }
})

end
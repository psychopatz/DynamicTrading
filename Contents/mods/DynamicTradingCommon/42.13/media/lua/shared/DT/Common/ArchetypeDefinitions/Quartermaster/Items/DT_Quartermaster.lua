require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Quartermaster", {
    name = "Deserter",
    allocations = {
        { tags={"Origin.Military"}, count = 8 },
        { tags={"Clothing.Utility.Belt"}, count = 5 },
        { tags={"Container.Bag"}, count = 4 },
        { tags={"Food.NonPerishable.Meat"}, count = 3 },
        { tags={"Food.Perishable.Canned"}, count = 3 }
    },
    wants = {
        ["Food.Drink.Alcohol"] = 1.5,
        ["Tobacco"] = 1.5,
        ["Luxury"] = 1.2
    },
    forbid = { "Theme.Farming", "Luxury.Decor", "Junk.Toy" }
})

end

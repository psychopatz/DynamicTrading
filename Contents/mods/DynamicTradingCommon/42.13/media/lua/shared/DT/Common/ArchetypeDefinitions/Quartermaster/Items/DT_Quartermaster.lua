require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Quartermaster", {
    name = "Deserter",
    allocations = {
        { tags={"Theme.Combat"}, count = 8 },
        { tags={"Clothing.Accessory.Utility"}, count = 5 },
        { tags={"Container.Bag.Backpack"}, count = 4 },
        { tags={"Food.NonPerishable.Meat"}, count = 3 },
        { tags={"Food.NonPerishable.Canned"}, count = 3 }
    },
    wants = {
        ["Food.Drink.Alcohol"] = 1.5,
        ["Medical.General.Drug"] = 1.5,
        ["Quality.Luxury"] = 1.2
    },
    forbid = { "Building.Garden", "Building.Furniture.Decor", "Misc.General" }
})

end

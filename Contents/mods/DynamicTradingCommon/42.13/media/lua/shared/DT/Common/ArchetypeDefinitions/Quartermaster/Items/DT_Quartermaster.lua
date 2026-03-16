require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Quartermaster", {
    name = "Deserter",
    allocations = {
        { tags={"Theme.Militia"}, count = 8 },
        { tags={"Clothing.Accessory.Belt"}, count = 5 },
        { tags={"Container.Backpack"}, count = 4 },
        { tags={"Food.NonPerishable.Meat"}, count = 3 },
        { tags={"Food.NonPerishable.Canned"}, count = 3 }
    },
    wants = {
        ["Food.Drink.Alcohol"] = 1.5,
        ["Medical.Tobacco"] = 1.5,
        ["Quality.Luxury"] = 1.2
    },
    forbid = { "Theme.Farming", "Misc.Decor", "Misc.General" }
})

end

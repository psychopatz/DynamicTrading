require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Bartender", {
    module = "DynamicTradingCommon",
    name = "Barkeep",
    allocations = {
        { tags={"Food.Drink.Alcohol"}, count = 10 },
        { tags={"Food.NonPerishable.Sweets"}, count = 6 },
        { tags={"Container.Liquid"}, count = 8 },
        { tags={"Misc.General"}, count = 5 },
        { tags={"Clothing.Accessory.Cosmetic"}, count = 2 },
        { module = "DynamicTradingCommon",  item = "Base.GlassWine", count = 2 }
    },
    expertTags = { "Food.Drink.Alcohol", "Food.NonPerishable.Sweets", "Container.Liquid", "Misc.General", "Clothing.Accessory.Cosmetic" },
    wants = {
        ["Food.Drink.NonAlcoholic"] = 1.3,
        ["Literature.Book"] = 1.25,
        ["Literature.Media"] = 1.2,
        ["Misc.General"] = 1.15,
        ["Weapon.Melee.Blunt"] = 1.1
    },
    forbid = { "Building.Garden", "Tool.General", "Resource.Material.Hardware", "Resource.Fuel", "Building.Survival" }
})

end

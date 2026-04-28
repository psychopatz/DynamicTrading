require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Athlete", {
    module = "DynamicTradingCommon",
    name = "Coach",
    allocations = {
        { tags={"Clothing"}, count = 5 },
        { tags={"Clothing"}, count = 4 },
        { tags={"Food.HighNutrition"}, count = 5 },
        { tags={"Container.Liquid"}, count = 4 },
        { tags={"Medical.General.Vitamin"}, count = 3 },
        { module = "DynamicTradingCommon",  item = "Base.WaterBottle", count = 1 }
    },
    expertTags = { "Clothing", "Building.Survival", "Food.HighNutrition", "Medical.General.Vitamin", "Clothing.Feet" },
    wants = {
        ["Food.Drink.NonAlcoholic"] = 1.35,
        ["Container.Bag.Backpack"] = 1.3,
        ["Medical.Consumable"] = 1.25,
        ["Tool.General"] = 1.15,
        ["Clothing.Accessory.Wrist.Watch"] = 1.1
    },
    forbid = { "Food.Drink.Alcohol", "Food.NonPerishable.Sweets", "Literature.Media", "Weapon.Explosive", "Quality.Waste" }
})

end

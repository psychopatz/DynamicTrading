require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Survivalist", {
    module = "DynamicTradingCommon",
    name = "Prepper",
    allocations = {
        { tags={"Food.NonPerishable"}, count = 10 },
        { tags={"Theme.Survival"}, count = 8 },
        { tags={"Weapon.Ranged.Ammo"}, count = 5 },
        { tags={"Building.Survival"}, count = 4 },
        { tags={"Medical.Healthcare.Botanical"}, count = 2 },
        { module = "DynamicTradingCommon",  item = "Base.TentGreen_Packed", count = 1 }
    },
    expertTags = { "Building.Survival", "Theme.Survival", "Weapon.Melee.Axe", "Tool.General", "Food.NonPerishable" },
    wants = {
        ["Container.Liquid"] = 1.35,
        ["Building.Garden"] = 1.3,
        ["Resource.Fuel"] = 1.25,
        ["Medical.Healthcare.Botanical"] = 1.2,
        ["Container"] = 1.15
    },
    forbid = { "Quality.Luxury", "Clothing.Accessory.Jewelry", "Electronics", "Theme.Clinical", "Food.Drink.Alcohol" }
})

end

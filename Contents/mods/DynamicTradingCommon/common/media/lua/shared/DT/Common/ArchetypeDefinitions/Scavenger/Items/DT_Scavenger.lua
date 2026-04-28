require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Scavenger", {
    module = "DynamicTradingCommon",
    name = "Scavenger",
    allocations = {
        { tags={"Quality.Waste"}, count = 15 },
        { tags={"Misc.General"}, count = 10 },
        { tags={"Building.Survival.Trap"}, count = 5 },
        { tags={"Resource.Material.General"}, count = 8 },
        { tags={"Tool.General"}, count = 4 },
        { module = "DynamicTradingCommon",  item = "Base.TinOpener", count = 1 }
    },
    expertTags = { "Quality.Waste", "Misc.General", "Building.Survival.Trap", "Resource.Material.General", "Tool.General" },
    wants = {
        ["Food.NonPerishable"] = 1.35,
        ["Medical.Healthcare.Botanical"] = 1.3,
        ["Container.Bag.Backpack"] = 1.25,
        ["Resource.Fuel"] = 1.2,
        ["Weapon.Melee.Blunt"] = 1.15
    },
    forbid = { "Quality.Luxury", "Clothing.Accessory.Jewelry", "Electronics.Generator", "Theme.Clinical", "Electronics" }
})

end

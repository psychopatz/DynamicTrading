require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Musician", {
    module = "DynamicTradingCommon",
    name = "DJ / Musician",
    allocations = {
        { tags={"Literature.Media"}, count = 15 },
        { tags={"Electronics"}, count = 5 },
        { tags={"Literature.Book"}, count = 6 },
        { tags={"Clothing.Accessory.Cosmetic"}, count = 4 },
        { tags={"Electronics.Battery"}, count = 8 },
        { module = "DynamicTradingCommon",  item = "Base.CDplayer", count = 1 }
    },
    expertTags = { "Literature.Media", "Electronics", "Misc.General", "Literature.Book", "Clothing.Accessory.Cosmetic" },
    wants = {
        ["Food.Drink.Alcohol"] = 1.3,
        ["Quality.Luxury"] = 1.25,
        ["Electronics.Battery"] = 1.2,
        ["Clothing.Accessory.Jewelry"] = 1.15,
        ["Medical.General.Vitamin"] = 1.1
    },
    forbid = { "Building.Furniture.General", "Resource.Material.Wood", "Tool.Farming", "Weapon.Explosive", "Resource.Parts" }
})

end

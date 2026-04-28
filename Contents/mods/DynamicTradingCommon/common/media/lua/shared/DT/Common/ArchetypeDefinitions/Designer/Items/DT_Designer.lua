require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Designer", {
    module = "DynamicTradingCommon",
    name = "Home Stager",
    allocations = {
        { tags={"Building.Furniture.Decor"}, count = 10 },
        { tags={"Building.Fixture.Appliance"}, count = 5 },
        { tags={"Building.Furniture.Counter"}, count = 4 },
        { tags={"Resource.Material.Hardware"}, count = 6 },
        { tags={"Clothing.Accessory.Cosmetic"}, count = 3 },
        { module = "DynamicTradingCommon",  item = "Base.Paintbrush", count = 1 }
    },
    expertTags = { "Building.Furniture.Decor", "Clothing.Accessory.Cosmetic", "Misc.General", "Literature.Media", "Quality.Luxury" },
    wants = {
        ["Misc.General"] = 1.3,
        ["Literature.Book"] = 1.25,
        ["Electronics.LightSource"] = 1.2,
        ["Resource.Material.Adhesive"] = 1.15,
        ["Food.Drink.NonAlcoholic"] = 1.1
    },
    forbid = { "Weapon.Explosive", "Resource.Fuel", "Building.Survival.Trap", "Medical.General.Drug", "Tool.Farming" }
})

end

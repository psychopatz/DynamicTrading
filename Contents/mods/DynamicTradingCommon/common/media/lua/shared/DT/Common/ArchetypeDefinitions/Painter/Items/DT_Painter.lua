require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Painter", {
    module = "DynamicTradingCommon",
    name = "Renovator",
    allocations = {
        { tags={"Building.Furniture.Decor"}, count = 8 },
        { tags={"Resource.Material.Textile"}, count = 10 },
        { tags={"Resource.Material.General"}, count = 6 },
        { tags={"Tool.General"}, count = 5 },
        { tags={"Misc.General"}, count = 4 },
        { module = "DynamicTradingCommon",  item = "Base.Paintbrush", count = 2 }
    },
    expertTags = { "Building.Furniture.Decor", "Resource.Material.Textile", "Resource.Material.General", "Tool.General", "Misc.General" },
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

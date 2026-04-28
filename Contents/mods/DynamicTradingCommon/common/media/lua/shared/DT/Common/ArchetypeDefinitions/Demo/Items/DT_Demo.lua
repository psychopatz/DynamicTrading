require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Demo", {
    module = "DynamicTradingCommon",
    name = "Demo Expert",
    allocations = {
        { tags={"Weapon.Explosive"}, count = 5 },
        { tags={"Resource.Fuel"}, count = 6 },
        { tags={"Resource.Material.Metal"}, count = 8 },
        { tags={"Electronics"}, count = 5 },
        { tags={"Resource.Material.Adhesive"}, count = 10 },
        { module = "DynamicTradingCommon",  item = "Base.Lighter", count = 2 }
    },
    expertTags = { "Weapon.Explosive", "Resource.Fuel", "Tool.General", "Resource.Material.Adhesive", "Theme.Combat" },
    wants = {
        ["Electronics.Battery"] = 1.4,
        ["Electronics"] = 1.35,
        ["Resource.Material.Adhesive"] = 1.3,
        ["Clothing"] = 1.25,
        ["Food.Drink"] = 1.15
    },
    forbid = { "Literature.Book", "Building.Garden", "Medical.Healthcare.Botanical", "Clothing.Dress", "Building.Furniture.Decor" }
})

end

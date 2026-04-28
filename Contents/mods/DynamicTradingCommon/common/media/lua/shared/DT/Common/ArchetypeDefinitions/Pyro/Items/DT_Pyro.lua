require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Pyro", {
    module = "DynamicTradingCommon",
    name = "Firebug",
    allocations = {
        { tags={"Weapon.Explosive"}, count = 3 },
        { tags={"Resource.Fuel"}, count = 5 },
        { tags={"Resource.Fuel"}, count = 5 },
        { tags={"Resource.Material.Wood"}, count = 8 },
        { tags={"Theme.Industrial"}, count = 4 },
        { module = "DynamicTradingCommon",  item = "Base.Lighter", count = 2 }
    },
    expertTags = { "Weapon.Explosive", "Resource.Fuel", "Resource.Fuel", "Theme.Industrial", "Building.Survival.Trap" },
    wants = {
        ["Resource.Material.Adhesive"] = 1.35,
        ["Electronics.Battery"] = 1.3,
        ["Tool.General"] = 1.25,
        ["Clothing"] = 1.2,
        ["Food.Drink"] = 1.15
    },
    forbid = { "Literature.Book", "Medical.Healthcare", "Clothing.Dress", "Building.Furniture.Decor", "Building.Garden" }
})

end

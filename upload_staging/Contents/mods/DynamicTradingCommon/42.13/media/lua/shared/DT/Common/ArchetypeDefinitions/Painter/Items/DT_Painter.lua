require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Painter", {
    name = "Renovator",
    allocations = {
        { tags={"Resource.Material.Textile"}, count = 8 },
        { tags={"Building.Furniture.Decor"}, count = 5 },
        { tags={"Resource.Material.General"}, count = 4 },
        { tags={"Tool.General"}, count = 3 }
    },
    wants = {
        ["Container.Liquid"] = 1.2,
        ["Clothing"] = 1.1,
        ["Food"] = 1.1
    },
    forbid = { "Weapon", "Quality.Waste", "Quality.Waste" }
})

end

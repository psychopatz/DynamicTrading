require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Designer", {
    name = "Home Stager",
    allocations = {
        { tags={"Building.Furniture.Decor"}, count = 10 },
        { tags={"Resource.Material.Hardware"}, count = 4 },
        { tags={"Building.Fixture.Appliance"}, count = 4 },
        { tags={"Container.Bag.General"}, count = 3 },
        { tags={"Building.Fixture.Appliance"}, count = 1 },
        { tags={"Building.Furniture.Counter"}, count = 4 },
        { tags={"Building.Furniture.Bed"}, count = 1 },
        { tags={"Building.Furniture.General"}, count = 1 }
    },
    wants = {
        ["Container.Liquid"] = 1.3,
        ["Resource.Material.Textile"] = 1.2,
        ["Resource.Material.Textile"] = 1.1
    },
    forbid = { "Weapon", "Quality.Waste", "Quality.Waste" }
})

end

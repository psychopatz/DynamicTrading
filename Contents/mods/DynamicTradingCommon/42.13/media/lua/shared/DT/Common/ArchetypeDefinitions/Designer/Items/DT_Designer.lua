require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Designer", {
    name = "Home Stager",
    allocations = {
        { tags={"Misc.Decor"}, count = 10 },
        { tags={"Resource.Material.Build"}, count = 4 },
        { tags={"Appliance.General"}, count = 4 },
        { tags={"Container.Organizer"}, count = 3 },
        { tags={"Building.Fixture.Appliance"}, count = 1 },
        { tags={"Building.Furniture.Counter"}, count = 4 },
        { tags={"Building.Furniture.Bed"}, count = 1 },
        { tags={"Building.Furniture.General"}, count = 1 }
    },
    wants = {
        ["Tool.Cleaning"] = 1.3,
        ["Resource.Material.Textile"] = 1.2,
        ["Resource.Material.Textile"] = 1.1
    },
    forbid = { "Weapon.General", "Misc.Artifact.Trash", "Quality.Waste" }
})

end

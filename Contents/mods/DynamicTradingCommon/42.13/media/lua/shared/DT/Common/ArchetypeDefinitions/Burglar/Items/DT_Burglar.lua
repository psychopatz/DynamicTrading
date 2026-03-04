require "DT/Common/Config"
if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Burglar", {
    name = "The Fence",
    allocations = {
        { tags={"Quality.Illegal"}, count = 5 },
        { tags={"Luxury"}, count = 4 },
        { tags={"Luxury.Jewelry"}, count = 4 },
        { tags={"Quality.Illegal"}, count = 2 },
        { tags={"Weapon"}, count = 2 }
    },
    wants = {
        ["Electronics"] = 1.3,
        ["Cash"] = 1.5,
        ["Container.Backpack"] = 1.2
    },
    forbid = { "Quality.Heavy", "Resource.Material.Build", "Theme.Farming" }
})
end
require "DT/Common/Config"
if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Burglar", {
    name = "The Fence",
    allocations = {
        { tags={"Quality.Illegal"}, count = 5 },
        { tags={"Quality.Luxury"}, count = 4 },
        { tags={"Misc.Cosmetic"}, count = 4 },
        { tags={"Quality.Illegal"}, count = 2 },
        { tags={"Weapon.General"}, count = 2 }
    },
    wants = {
        ["Electronics.General"] = 1.3,
        ["Resource.Money"] = 1.5,
        ["Container.Backpack"] = 1.2
    },
    forbid = { "Quality.Heavy", "Resource.Material.Build", "Theme.Business" }
})
end
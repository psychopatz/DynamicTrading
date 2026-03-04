require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Hiker", {
    name = "Drifter",
    allocations = {
        { tags={"Tool.Utility.Survival"}, count = 8 },
        { tags={"Container.General"}, count = 5 },
        { tags={"Container.Backpack"}, count = 4 },
        { tags={"Tool.Utility.Survival"}, count = 3 }
    },
    wants = {
        ["Food.NonPerishable.Canned"] = 1.3,
        ["Food.NonPerishable.Sweets"] = 1.2,
        ["Clothing.General"] = 1.2
    },
    forbid = { "Quality.Heavy", "Appliance.Generator", "Resource.Material.Build" }
})

end

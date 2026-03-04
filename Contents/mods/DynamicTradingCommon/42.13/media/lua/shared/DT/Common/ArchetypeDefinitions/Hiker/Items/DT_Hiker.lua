require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Hiker", {
    name = "Drifter",
    allocations = {
        { tags={"Tool.Camping"}, count = 8 },
        { tags={"Container.Misc"}, count = 5 },
        { tags={"Container.Backpack"}, count = 4 },
        { tags={"Tool.Camping.Shelter"}, count = 3 }
    },
    wants = {
        ["Food.Perishable.Canned"] = 1.3,
        ["Sweets"] = 1.2,
        ["Clothing"] = 1.2
    },
    forbid = { "Quality.Heavy", "Electronics.Generator", "Resource.Material.Build" }
})

end

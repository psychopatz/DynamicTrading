require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Carpenter", {
    name = "Carpenter",
    allocations = {
        { tags={"Resource.Material.Wood"}, count = 10 },
        { tags={"Building.Furniture"}, count = 5 },
        { tags={"Tool"}, count = 5 },
        { tags={"Resource"}, count = 3 }
    },
    expertTags = { "Resource.Material.Wood", "Resource.Material.Hardware" },
    wants = {
        ["Tool.General"] = 1.3,
        ["Food"] = 1.2,
        ["Medical.General"] = 1.1
    },
    forbid = { "Resource.Material.Metal", "Electronics", "Clothing.Accessory.Cosmetic" }
})

end

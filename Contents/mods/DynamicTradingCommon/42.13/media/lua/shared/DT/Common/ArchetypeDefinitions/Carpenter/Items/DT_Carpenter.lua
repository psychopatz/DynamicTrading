require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Carpenter", {
    name = "Carpenter",
    allocations = {
        { tags={"Resource.Material.Wood"}, count = 10 },
        { tags={"Tool.Resource.Wood"}, count = 5 },
        { tags={"Tool.Crafting.Carpenter"}, count = 5 },
        { tags={"Resource.Material.Build"}, count = 3 }
    },
    expertTags = { "Wood", "Build" },
    wants = {
        ["Tool"] = 1.3,
        ["Food"] = 1.2,
        ["Medical"] = 1.1
    },
    forbid = { "Resource.Material.Metal", "Electronics", "Jewelry" }
})

end

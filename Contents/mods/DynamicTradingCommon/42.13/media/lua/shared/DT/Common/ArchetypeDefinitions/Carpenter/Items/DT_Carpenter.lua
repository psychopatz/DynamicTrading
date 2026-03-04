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
    expertTags = { "Resource.Material.Wood", "Resource.Material.Build" },
    wants = {
        ["Tool.General"] = 1.3,
        ["Food.General"] = 1.2,
        ["Medical.General"] = 1.1
    },
    forbid = { "Resource.Material.Metal", "Electronics.General", "Misc.Cosmetic" }
})

end

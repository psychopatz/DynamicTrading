require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Janitor", {
    name = "The Cleaner",
    allocations = {
        { tags={"Tool.Cleaning.General"}, count = 8 },
        { tags={"Tool.Cleaning.Hygiene"}, count = 6 },
        { tags={"Resource.Material.Chemical"}, count = 3 },
        { tags={"Medical.General.Poison"}, count = 3 },
        { tags={"Misc.Artifact.Trash"}, count = 4 }
    },
    wants = {
        ["Clothing.Protection"] = 1.4,
        ["Clothing.General"] = 1.2,
        ["Container.Fluid"] = 1.2
    },
    forbid = { "Food.General", "Food.Perishable", "Quality.Luxury" }
})

end

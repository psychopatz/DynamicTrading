require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Janitor", {
    name = "The Cleaner",
    allocations = {
        { tags={"Tool.Cleaning"}, count = 8 },
        { tags={"Tool.Cleaning.Hygiene"}, count = 6 },
        { tags={"Resource.Material.Chemical"}, count = 3 },
        { tags={"Resource.Poison"}, count = 3 },
        { tags={"Junk.Trash"}, count = 4 }
    },
    wants = {
        ["Mask"] = 1.4,
        ["Wearable"] = 1.2,
        ["Container.Fluid"] = 1.2
    },
    forbid = { "Food", "Food.Perishable", "Luxury" }
})

end

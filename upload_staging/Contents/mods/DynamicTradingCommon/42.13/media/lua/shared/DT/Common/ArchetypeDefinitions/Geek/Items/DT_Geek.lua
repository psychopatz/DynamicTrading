require "DT/Common/Config"

if DynamicTrading and DynamicTrading.RegisterArchetype then

DynamicTrading.RegisterArchetype("Geek", {
    name = "Collector",
    allocations = {
        { tags={"Misc.General"}, count = 6 },
        { tags={"Misc.General"}, count = 5 },
        { tags={"Electronics"}, count = 5 },
        { tags={"Literature.Book"}, count = 4 }
    },
    wants = {
        ["Resource.Craftable"] = 1.5,
        ["Food.NonPerishable.Sweets"] = 1.4,
        ["Food.Drink"] = 1.2
    },
    forbid = { "Food.Drink.Alcohol", "Building.Garden", "Tool.General" }
})

end
